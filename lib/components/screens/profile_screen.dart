import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/habit_focus_theme.dart';
import '../widgets/habit_focus_app_bar.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/profile_menu_section.dart';
import '../widgets/profile/profile_version_info.dart';
import '../../controllers/user_controller.dart';
import '../../models/user.dart';
import '../../routes/app_routes.dart';
import '../../utils/avatar_storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userController = UserController();
  final _picker = ImagePicker();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _userController.addListener(_refresh);
  }

  @override
  void dispose() {
    _userController.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  User? get _user => _userController.getAll().firstOrNull;

  Future<void> _editName() async {
    final user = _user;
    if (user == null) return;
    final controller = TextEditingController(text: user.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit profile name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;
    await _run(() => _userController.updateFields(user.id, {'name': name}));
  }

  /// Picks an image from the device and copies it into local app storage.
  Future<void> _changePhoto() async {
    final user = _user;
    if (user == null) return;
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      final path = await AvatarStorageService.save(
        userId: user.id,
        source: File(picked.path),
      );
      await _userController.updateFields(user.id, {'avatarUrl': path});
    } catch (error) {
      _showMessage('Could not update the photo: $error');
    }
  }

  Future<void> _removePhoto() async {
    final user = _user;
    if (user == null) return;
    final previous = user.avatarUrl;
    await _run(() => _userController.updateFields(user.id, {'avatarUrl': null}));
    await AvatarStorageService.remove(previous);
  }

  Future<void> _deleteProfile() async {
    final user = _user;
    if (user == null) return;
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete profile?'),
        content: const Text(
          'The profile, its photo and stats are removed from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await AvatarStorageService.removeForUser(user.id);
    await _userController.delete(user.id);
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.onboarding, (route) => false);
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (error) {
      _showMessage('Could not save the profile: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const HabitFocusAppBar(overrideTitle: 'Profile'),
      body: ListView(
        padding: const EdgeInsets.all(HabitFocusTheme.mobilePadding),
        children: user == null
            ? [_buildEmptyState(context)]
            : [
                ProfileHeader(
                  name: user.name,
                  avatarPath: user.avatarUrl,
                  avatarColor: user.avatarColorValue == null
                      ? null
                      : Color(user.avatarColorValue!),
                  busy: _busy,
                  onEditName: _editName,
                  onChangePhoto: _changePhoto,
                  onRemovePhoto: _removePhoto,
                ),
                const SizedBox(height: HabitFocusTheme.sectionGap),
                ProfileMenuSection(onDeleteProfile: _deleteProfile),
                const SizedBox(height: HabitFocusTheme.sectionGap),
                const ProfileVersionInfo(),
              ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(HabitFocusTheme.cardRadius),
        boxShadow: [HabitFocusTheme.ambientShadow],
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_add_alt_outlined,
            size: 40,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'No profile on this device yet.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.onboarding),
            child: const Text('Create profile'),
          ),
        ],
      ),
    );
  }
}
