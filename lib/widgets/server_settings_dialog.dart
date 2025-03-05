import 'package:flutter/material.dart';
import '../common/util.dart';
import '../core/services/api_config_service.dart';
import 'custom_text_field.dart';
import 'message_widget.dart';

class ServerSettingsDialog extends StatefulWidget {
  const ServerSettingsDialog({super.key});

  @override
  State<ServerSettingsDialog> createState() => _ServerSettingsDialogState();
}

class _ServerSettingsDialogState extends State<ServerSettingsDialog> {
  final TextEditingController _ipController = TextEditingController();
  final ApiConfigService _apiConfigService = ApiConfigService();
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCurrentIp();
  }

  Future<void> _loadCurrentIp() async {
    final savedIp = await getCustomIp();
    if (savedIp != null) {
      _ipController.text = savedIp;
    }
  }

  bool _validateIp(String ipAddress) {
    if (ipAddress.isEmpty) return true; // Empty is valid (uses default)

    // Split IP and port if port is provided
    final parts = ipAddress.split(':');
    final ip = parts[0];
    
    // Validate port if provided
    if (parts.length > 1) {
      try {
        final port = int.parse(parts[1]);
        if (port < 0 || port > 65535) {
          setState(() => _error = 'Invalid port number');
          return false;
        }
      } catch (e) {
        setState(() => _error = 'Invalid port format');
        return false;
      }
    }

    // Validate IP address
    final ipParts = ip.split('.');
    if (ipParts.length != 4) {
      setState(() => _error = 'Invalid IP format');
      return false;
    }

    for (var part in ipParts) {
      try {
        final number = int.parse(part);
        if (number < 0 || number > 255) {
          setState(() => _error = 'IP numbers must be between 0 and 255');
          return false;
        }
      } catch (e) {
        setState(() => _error = 'Invalid IP format');
        return false;
      }
    }

    setState(() => _error = null);
    return true;
  }

  void _showIpHelpDialog() {
    final size = MediaQuery.of(context).size;
    final maxWidth = size.width * 0.9 < 400 ? size.width * 0.9 : 400.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            Icon(
              Icons.help_outline,
              color: Theme.of(context).primaryColor,
            ),
            const Text('How to Find Your IP Address'),
          ],
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        content: Container(
          width: maxWidth,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOSInstructions(
                  'Windows',
                  '1. Open Command Prompt (cmd)\n'
                  '2. Type "ipconfig"\n'
                  '3. Look for "IPv4 Address" under your network adapter',
                ),
                const SizedBox(height: 16),
                _buildOSInstructions(
                  'Mac',
                  '1. Open Terminal\n'
                  '2. Type "ifconfig | grep inet"\n'
                  '3. Look for "inet" followed by your IP',
                ),
                const SizedBox(height: 16),
                _buildOSInstructions(
                  'Linux',
                  '1. Open Terminal\n'
                  '2. Type "ip addr" or "ifconfig"\n'
                  '3. Look for "inet" followed by your IP',
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Note:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '• Make sure both devices are on the same network\n'
                  '• The server must be running on port 8000\n'
                  '• Format: xxx.xxx.xxx.xxx:8000',
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildOSInstructions(String os, String instructions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$os:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          instructions,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.computer,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          const Text('Server Settings'),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showIpHelpDialog,
            tooltip: 'How to find your IP address',
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: _ipController,
            label: 'Server Address',
            icon: Icons.dns,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 8),
          Text(
            'Leave empty to use default server',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            MessageWidget(
              message: _error!,
              type: MessageType.error,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final ip = _ipController.text.trim();
            if (_validateIp(ip)) {
              await _apiConfigService.updateBaseUrl(
                ip.isNotEmpty ? ip : null
              );
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }
} 