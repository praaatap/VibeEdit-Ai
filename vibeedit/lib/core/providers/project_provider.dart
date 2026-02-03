/// Project provider for VibeEdit AI
/// State management for projects using Riverpod
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';

/// State class for projects
class ProjectsState {
  const ProjectsState({
    this.projects = const [],
    this.currentProject,
    this.isLoading = false,
    this.error,
  });

  final List<Project> projects;
  final Project? currentProject;
  final bool isLoading;
  final String? error;

  ProjectsState copyWith({
    List<Project>? projects,
    Project? currentProject,
    bool? isLoading,
    String? error,
  }) {
    return ProjectsState(
      projects: projects ?? this.projects,
      currentProject: currentProject ?? this.currentProject,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Projects state notifier
class ProjectsNotifier extends StateNotifier<ProjectsState> {
  ProjectsNotifier() : super(const ProjectsState());

  /// Load all projects
  Future<void> loadProjects() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Load from local storage
      // For now, using mock data
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(projects: _mockProjects, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load projects',
      );
    }
  }

  /// Create a new project
  Future<Project> createProject(String name) async {
    final project = Project.create(name: name);
    state = state.copyWith(
      projects: [project, ...state.projects],
      currentProject: project,
    );
    return project;
  }

  /// Select a project for editing
  void selectProject(Project project) {
    state = state.copyWith(currentProject: project);
  }

  /// Update a project
  void updateProject(Project updatedProject) {
    final updatedList = state.projects.map((p) {
      return p.id == updatedProject.id ? updatedProject : p;
    }).toList();
    state = state.copyWith(
      projects: updatedList,
      currentProject: state.currentProject?.id == updatedProject.id
          ? updatedProject
          : null,
    );
  }

  /// Delete a project
  void deleteProject(String projectId) {
    state = state.copyWith(
      projects: state.projects.where((p) => p.id != projectId).toList(),
      currentProject: state.currentProject?.id == projectId
          ? null
          : state.currentProject,
    );
  }

  /// Clear current project
  void clearCurrentProject() {
    state = state.copyWith(currentProject: null);
  }
}

/// Projects provider
final projectsProvider = StateNotifierProvider<ProjectsNotifier, ProjectsState>(
  (ref) {
    return ProjectsNotifier();
  },
);

/// Current project provider (convenience)
final currentProjectProvider = Provider<Project?>((ref) {
  return ref.watch(projectsProvider).currentProject;
});

/// Recent projects provider (sorted by update date)
final recentProjectsProvider = Provider<List<Project>>((ref) {
  final projects = ref.watch(projectsProvider).projects;
  final sorted = [...projects];
  sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return sorted;
});

// Mock data for development
final _mockProjects = [
  Project(
    id: '1',
    name: 'Travel Vlog 2024',
    thumbnailPath: null,
    duration: const Duration(minutes: 4, seconds: 20),
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    status: ProjectStatus.completed,
  ),
  Project(
    id: '2',
    name: 'Product Demo',
    thumbnailPath: null,
    duration: const Duration(minutes: 1, seconds: 15),
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    status: ProjectStatus.completed,
  ),
  Project(
    id: '3',
    name: 'Untitled Project 3',
    thumbnailPath: null,
    duration: const Duration(minutes: 30, seconds: 30),
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    status: ProjectStatus.draft,
  ),
  Project(
    id: '4',
    name: 'Night Shoot',
    thumbnailPath: null,
    duration: const Duration(minutes: 12, seconds: 45),
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
    updatedAt: DateTime.now().subtract(const Duration(days: 6)),
    status: ProjectStatus.completed,
  ),
];
