import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/controller_initializer.dart';
import '../../utils/storage_service.dart';

class DataBackupScreen extends StatefulWidget {
  const DataBackupScreen({super.key});

  @override
  State<DataBackupScreen> createState() => _DataBackupScreenState();
}

class _DataBackupScreenState extends State<DataBackupScreen> {
  final _backupController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _backupController.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      _backupController.text = await StorageService().exportBackup();
      if (!mounted) return;
      await Clipboard.setData(ClipboardData(text: _backupController.text));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup copied. Store it somewhere safe.'),
        ),
      );
    } catch (error) {
      _showMessage('Could not export backup: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Replace saved data?'),
        content: const Text('Restoring replaces the current saved records.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Replace data'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() => _busy = true);
    try {
      await StorageService().importBackup(_backupController.text);
      if (!mounted) return;
      await ControllerInitializer.reloadAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Backup restored. Restart the app to refresh all screens.',
          ),
        ),
      );
    } catch (error) {
      _showMessage('Backup could not be restored: $error');
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Data backup')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Export copies every saved JSON record to the clipboard. Import replaces the saved records with the validated backup.',
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _backupController,
          onChanged: (_) => setState(() {}),
          minLines: 8,
          maxLines: 16,
          decoration: const InputDecoration(
            labelText: 'Backup JSON',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _busy ? null : _export,
          icon: const Icon(Icons.download_outlined),
          label: const Text('Copy backup JSON'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _busy || _backupController.text.trim().isEmpty
              ? null
              : _import,
          icon: const Icon(Icons.upload_outlined),
          label: const Text('Restore this backup'),
        ),
        if (_busy) const LinearProgressIndicator(),
      ],
    ),
  );
}
