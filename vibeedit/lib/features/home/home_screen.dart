/// Home screen for VibeEdit AI
/// Main screen showing projects and AI tools
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme.dart';
import '../../core/constants/constants.dart';
import '../../core/providers/providers.dart';
import '../../data/models/models.dart';
import 'widgets/widgets.dart';

/// Home screen (My Studio)
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.onNavigateToEditor});

  final void Function(Project project)? onNavigateToEditor;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load projects on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(projectsProvider.notifier).loadProjects();
    });
  }

  void _handleCreateProject() async {
    // Show dialog to get project name
    final name = await _showCreateProjectDialog();
    if (name != null && name.isNotEmpty) {
      final project = await ref
          .read(projectsProvider.notifier)
          .createProject(name);
      widget.onNavigateToEditor?.call(project);
    }
  }

  Future<String?> _showCreateProjectDialog() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('New Project', style: AppTextStyles.titleLarge),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTextStyles.bodyLarge,
          decoration: const InputDecoration(hintText: 'Enter project name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(AppStrings.create),
          ),
        ],
      ),
    );
  }

  void _handleToolTap(AITool tool) {
    // Show snackbar for now - would open AI tool flow
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${tool.name}...'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleProjectTap(Project project) {
    ref.read(projectsProvider.notifier).selectProject(project);
    widget.onNavigateToEditor?.call(project);
  }

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(projectsProvider);
    final recentProjects = ref.watch(recentProjectsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.spacing8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: const Icon(
                Icons.movie_edit,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSizes.spacing12),
            Text(AppStrings.myStudio, style: AppTextStyles.titleLarge),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(projectsProvider.notifier).loadProjects(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section title
              Text(
                AppStrings.startCreating,
                style: AppTextStyles.headlineSmall,
              ),
              const SizedBox(height: AppSizes.spacing16),

              // New project card
              NewProjectCard(onCreatePressed: _handleCreateProject),
              const SizedBox(height: AppSizes.spacing32),

              // AI Magic Tools
              AIMagicToolsGrid(onToolTap: _handleToolTap, onViewAllTap: () {}),
              const SizedBox(height: AppSizes.spacing32),

              // Recent projects
              RecentProjectsGrid(
                projects: recentProjects,
                onProjectTap: _handleProjectTap,
                isLoading: projectsState.isLoading,
              ),
              const SizedBox(height: AppSizes.spacing32),
            ],
          ),
        ),
      ),
    );
  }
}
