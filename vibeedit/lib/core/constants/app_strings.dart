/// App string constants for VibeEdit AI
/// Centralized text strings for easy localization
library;

/// String constants for the app
abstract final class AppStrings {
  // App
  static const String appName = 'VibeEdit AI';
  static const String myStudio = 'My Studio';

  // Navigation
  static const String home = 'Home';
  static const String templates = 'Templates';
  static const String assets = 'Assets';
  static const String export = 'Export';

  // Home Screen
  static const String startCreating = 'Start Creating';
  static const String newProject = 'New Project';
  static const String newProjectDescription =
      'Start from scratch or import your footage to begin.';
  static const String create = 'Create';
  static const String aiPowered = 'AI POWERED';
  static const String newTag = 'NEW';
  static const String aiMagicTools = 'AI Magic Tools';
  static const String viewAll = 'View All';
  static const String recentProjects = 'Recent Projects';

  // AI Tools
  static const String autoCut = 'Auto-Cut';
  static const String autoCutDesc = 'Remove silence instantly';
  static const String aiEnhance = 'AI Enhance';
  static const String aiEnhanceDesc = 'Upscale & stabilize';
  static const String smartRemove = 'Smart Remove';
  static const String smartRemoveDesc = 'Erase objects easily';
  static const String autoCaptions = 'Auto Captions';
  static const String autoCaptionsDesc = 'Transcribe in seconds';

  // Editor
  static const String split = 'Split';
  static const String speed = 'Speed';
  static const String volume = 'Volume';
  static const String animation = 'Anim';
  static const String adjust = 'Adjust';
  static const String askAiCopilot = 'Ask AI Copilot...';

  // AI Copilot
  static const String aiCopilot = 'AI Copilot';
  static const String online = 'ONLINE';
  static const String describeYourEdit = 'Describe your edit...';
  static const String cutSilence = 'Cut Silence';
  static const String colorGrade = 'Color Grade';

  // Project
  static const String draft = 'DRAFT';
  static const String editedAgo = 'Edited';

  // Actions
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String undo = 'Undo';
  static const String redo = 'Redo';

  // Loading & Status
  static const String loading = 'Loading...';
  static const String processing = 'Processing...';
  static const String generatingCaptions = 'Generating captions...';

  // Errors
  static const String errorGeneric = 'Something went wrong';
  static const String errorNoVideo = 'No video selected';
  static const String errorLoadFailed = 'Failed to load';
}
