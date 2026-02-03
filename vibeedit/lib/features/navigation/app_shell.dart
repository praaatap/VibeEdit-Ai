/// Main navigation shell for VibeEdit AI
/// App shell with bottom navigation
library;

import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/theme.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/widgets.dart';
import '../home/home_screen.dart';
import '../templates/templates_screen.dart';
import '../assets/assets_screen.dart';
import '../export/export_screen.dart';
import '../editor/editor_screen.dart';

/// Main app shell with navigation
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  Project? _editingProject;

  final List<NavItem> _navItems = const [
    NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: AppStrings.home,
    ),
    NavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: AppStrings.templates,
    ),
    NavItem(
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder,
      label: AppStrings.assets,
    ),
    NavItem(
      icon: Icons.upload_outlined,
      activeIcon: Icons.upload,
      label: AppStrings.export,
    ),
  ];

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
      _editingProject = null;
    });
  }

  void _openEditor(Project project) {
    setState(() {
      _editingProject = project;
    });
  }

  void _closeEditor() {
    setState(() {
      _editingProject = null;
    });
  }

  Widget _buildScreen() {
    // Show editor if a project is being edited
    if (_editingProject != null) {
      return EditorScreen(project: _editingProject!, onBack: _closeEditor);
    }

    // Regular navigation
    switch (_currentIndex) {
      case 0:
        return HomeScreen(onNavigateToEditor: _openEditor);
      case 1:
        return const TemplatesScreen();
      case 2:
        return const AssetsScreen();
      case 3:
        return const ExportScreen();
      default:
        return HomeScreen(onNavigateToEditor: _openEditor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildScreen(),
      bottomNavigationBar: _editingProject == null
          ? AppBottomNavBar(
              currentIndex: _currentIndex,
              onTap: _onNavTap,
              items: _navItems,
            )
          : null,
    );
  }
}
