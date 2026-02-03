"""
Task Queue Service - Background processing for video operations
"""
import asyncio
import uuid
from typing import Dict, Any, Optional, Callable, List
from datetime import datetime
from enum import Enum
from dataclasses import dataclass, field
import traceback


class TaskStatus(str, Enum):
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"


class TaskPriority(int, Enum):
    LOW = 1
    NORMAL = 5
    HIGH = 10
    URGENT = 20


@dataclass
class Task:
    """Represents a background task"""
    id: str
    name: str
    func: Callable
    args: tuple = field(default_factory=tuple)
    kwargs: dict = field(default_factory=dict)
    status: TaskStatus = TaskStatus.PENDING
    priority: TaskPriority = TaskPriority.NORMAL
    progress: int = 0
    result: Any = None
    error: Optional[str] = None
    created_at: datetime = field(default_factory=datetime.now)
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    user_id: Optional[str] = None
    metadata: dict = field(default_factory=dict)
    
    def to_dict(self) -> Dict[str, Any]:
        return {
            "id": self.id,
            "name": self.name,
            "status": self.status.value,
            "priority": self.priority.value,
            "progress": self.progress,
            "error": self.error,
            "created_at": self.created_at.isoformat(),
            "started_at": self.started_at.isoformat() if self.started_at else None,
            "completed_at": self.completed_at.isoformat() if self.completed_at else None,
            "metadata": self.metadata
        }


class TaskQueue:
    """
    Simple in-memory task queue for background processing
    For production, consider using Celery, Redis Queue, or similar
    """
    
    def __init__(self, max_workers: int = 3):
        """Initialize task queue"""
        self.max_workers = max_workers
        self.tasks: Dict[str, Task] = {}
        self.queue: asyncio.Queue = None
        self.workers: List[asyncio.Task] = []
        self._running = False
        self._callbacks: Dict[str, List[Callable]] = {}
    
    async def start(self):
        """Start the task queue workers"""
        if self._running:
            return
        
        self._running = True
        self.queue = asyncio.Queue()
        
        # Start worker tasks
        for i in range(self.max_workers):
            worker = asyncio.create_task(self._worker(f"worker-{i}"))
            self.workers.append(worker)
        
        print(f"✅ Task queue started with {self.max_workers} workers")
    
    async def stop(self):
        """Stop the task queue"""
        self._running = False
        
        # Cancel all workers
        for worker in self.workers:
            worker.cancel()
        
        await asyncio.gather(*self.workers, return_exceptions=True)
        self.workers.clear()
        
        print("👋 Task queue stopped")
    
    async def _worker(self, worker_id: str):
        """Worker coroutine that processes tasks"""
        while self._running:
            try:
                # Get task from queue with timeout
                try:
                    task_id = await asyncio.wait_for(self.queue.get(), timeout=1.0)
                except asyncio.TimeoutError:
                    continue
                
                task = self.tasks.get(task_id)
                if not task or task.status == TaskStatus.CANCELLED:
                    continue
                
                # Run the task
                task.status = TaskStatus.RUNNING
                task.started_at = datetime.now()
                
                try:
                    # Execute the task function
                    if asyncio.iscoroutinefunction(task.func):
                        task.result = await task.func(*task.args, **task.kwargs, task=task)
                    else:
                        task.result = task.func(*task.args, **task.kwargs, task=task)
                    
                    task.status = TaskStatus.COMPLETED
                    task.progress = 100
                    
                except Exception as e:
                    task.status = TaskStatus.FAILED
                    task.error = f"{type(e).__name__}: {str(e)}"
                    traceback.print_exc()
                
                finally:
                    task.completed_at = datetime.now()
                    
                    # Call completion callbacks
                    await self._trigger_callbacks(task)
                    
            except asyncio.CancelledError:
                break
            except Exception as e:
                print(f"Worker {worker_id} error: {e}")
    
    def submit(
        self,
        name: str,
        func: Callable,
        *args,
        priority: TaskPriority = TaskPriority.NORMAL,
        user_id: Optional[str] = None,
        metadata: Optional[dict] = None,
        **kwargs
    ) -> str:
        """
        Submit a task to the queue
        
        Returns:
            Task ID
        """
        task_id = str(uuid.uuid4())
        
        task = Task(
            id=task_id,
            name=name,
            func=func,
            args=args,
            kwargs=kwargs,
            priority=priority,
            user_id=user_id,
            metadata=metadata or {}
        )
        
        self.tasks[task_id] = task
        
        # Add to queue (fire and forget)
        asyncio.create_task(self._enqueue(task_id))
        
        return task_id
    
    async def _enqueue(self, task_id: str):
        """Add task to the async queue"""
        if self.queue:
            await self.queue.put(task_id)
    
    def get_task(self, task_id: str) -> Optional[Task]:
        """Get task by ID"""
        return self.tasks.get(task_id)
    
    def get_task_status(self, task_id: str) -> Optional[Dict[str, Any]]:
        """Get task status as dict"""
        task = self.tasks.get(task_id)
        return task.to_dict() if task else None
    
    def get_user_tasks(
        self,
        user_id: str,
        status: Optional[TaskStatus] = None
    ) -> List[Dict[str, Any]]:
        """Get all tasks for a user"""
        tasks = [
            t.to_dict() for t in self.tasks.values()
            if t.user_id == user_id
            and (status is None or t.status == status)
        ]
        return sorted(tasks, key=lambda t: t["created_at"], reverse=True)
    
    def cancel_task(self, task_id: str) -> bool:
        """Cancel a pending task"""
        task = self.tasks.get(task_id)
        if task and task.status == TaskStatus.PENDING:
            task.status = TaskStatus.CANCELLED
            return True
        return False
    
    def update_progress(self, task_id: str, progress: int, metadata: Optional[dict] = None):
        """Update task progress (called from within task function)"""
        task = self.tasks.get(task_id)
        if task:
            task.progress = min(max(progress, 0), 100)
            if metadata:
                task.metadata.update(metadata)
    
    def on_complete(self, task_id: str, callback: Callable):
        """Register callback for task completion"""
        if task_id not in self._callbacks:
            self._callbacks[task_id] = []
        self._callbacks[task_id].append(callback)
    
    async def _trigger_callbacks(self, task: Task):
        """Trigger completion callbacks"""
        callbacks = self._callbacks.pop(task.id, [])
        for callback in callbacks:
            try:
                if asyncio.iscoroutinefunction(callback):
                    await callback(task)
                else:
                    callback(task)
            except Exception as e:
                print(f"Callback error: {e}")
    
    def cleanup_old_tasks(self, max_age_hours: int = 24):
        """Remove old completed/failed tasks"""
        cutoff = datetime.now()
        
        to_remove = []
        for task_id, task in self.tasks.items():
            if task.status in [TaskStatus.COMPLETED, TaskStatus.FAILED, TaskStatus.CANCELLED]:
                if task.completed_at:
                    age = (cutoff - task.completed_at).total_seconds() / 3600
                    if age > max_age_hours:
                        to_remove.append(task_id)
        
        for task_id in to_remove:
            del self.tasks[task_id]
        
        return len(to_remove)


# Singleton instance
task_queue = TaskQueue(max_workers=3)


# Example task functions
async def process_video_task(
    video_id: str,
    input_path: str,
    operations: List[Dict[str, Any]],
    task: Task = None
) -> Dict[str, Any]:
    """
    Example video processing task
    """
    from app.services.video_editor import video_editor
    from app.services.effects_service import effects_service
    
    results = []
    total_ops = len(operations)
    current_path = input_path
    
    for i, op in enumerate(operations):
        op_type = op.get("type")
        params = op.get("params", {})
        
        # Update progress
        if task:
            task_queue.update_progress(
                task.id,
                int((i / total_ops) * 100),
                {"current_operation": op_type}
            )
        
        try:
            if op_type == "trim":
                output = video_editor.trim_video(
                    current_path,
                    f"{current_path}_trimmed.mp4",
                    params.get("start", 0),
                    params.get("end", 10)
                )
            elif op_type == "speed":
                output = effects_service.adjust_speed(
                    current_path,
                    f"{current_path}_speed.mp4",
                    params.get("speed", 1.0)
                )
            elif op_type == "filter":
                output = effects_service.apply_filters(
                    current_path,
                    f"{current_path}_filtered.mp4",
                    **params
                )
            else:
                continue
            
            current_path = output
            results.append({"operation": op_type, "status": "success", "output": output})
            
        except Exception as e:
            results.append({"operation": op_type, "status": "error", "error": str(e)})
    
    return {
        "video_id": video_id,
        "final_output": current_path,
        "operations": results
    }
