import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hearhere/features/settings/data/ai_settings_repository.dart';
import 'package:hearhere/services/ai_service.dart';

class ModelSelectionDialog extends ConsumerStatefulWidget {
  final VoidCallback onRetry;

  const ModelSelectionDialog({super.key, required this.onRetry});

  @override
  ConsumerState<ModelSelectionDialog> createState() => _ModelSelectionDialogState();
}

class _ModelSelectionDialogState extends ConsumerState<ModelSelectionDialog> {
  List<String> _models = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchModels();
  }

  Future<void> _fetchModels() async {
    try {
      final models = await ref.read(aiServiceProvider).fetchAvailableModels();
      if (models.isEmpty) {
        // Fallback list if fetching fails but we want to offer choices
        setState(() {
          _models = [
            'gemini-2.0-flash',
            'gemini-1.5-flash',
            'gemini-1.0-pro',
            'gemini-pro',
          ];
          _isLoading = false;
        });
      } else {
        setState(() {
          _models = models;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectModel(String modelName) async {
    await ref.read(aiSettingsRepositoryProvider).setModelName(modelName);
    // Reload model in service
    // Casting to implementation to access restart, or we can just invalidate provider
    // ref.invalidate(aiServiceProvider); // This works if we restart the app or if provider re-builds
    // To be safe, let's inform user or just retry. 
    // Since aiService is @Riverpod(keepAlive: true), invalidating it is good.
    ref.invalidate(aiServiceProvider);

    if (mounted) {
      Navigator.of(context).pop();
      widget.onRetry();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select AI Model'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The current AI model is unavailable or deprecated. Please select a compatible model from the list below.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _models.length,
                  itemBuilder: (context, index) {
                    final model = _models[index];
                    return ListTile(
                      title: Text(model),
                      leading: const Icon(Icons.psychology),
                      onTap: () => _selectModel(model),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
