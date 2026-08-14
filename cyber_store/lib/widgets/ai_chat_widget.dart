import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class AiChatWidget extends StatefulWidget {
  const AiChatWidget({super.key});

  @override
  State<AiChatWidget> createState() => _AiChatWidgetState();
}

class _AiChatWidgetState extends State<AiChatWidget> {
  void _openChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AiChatSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _openChat(context),
      backgroundColor: AppTheme.black,
      foregroundColor: AppTheme.white,
      shape: const CircleBorder(),
      child: const Icon(Icons.auto_awesome),
    );
  }
}

import 'dart:io';
import 'package:image_picker/image_picker.dart';

class _AiChatSheet extends StatefulWidget {
  const _AiChatSheet();

  @override
  State<_AiChatSheet> createState() => _AiChatSheetState();
}

class _AiChatSheetState extends State<_AiChatSheet> {
  final _ctrl = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'role': 'ai', 'text': 'Hello! I am your Cyber Assistant. How can I help you today?'}
  ];
  bool _loading = false;
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _send() async {
    final msg = _ctrl.text.trim();
    if (msg.isEmpty && _selectedImage == null) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'text': msg,
        'image': _selectedImage?.path,
      });
      _loading = true;
    });

    final imagePath = _selectedImage?.path;
    _ctrl.clear();
    setState(() => _selectedImage = null);

    try {
      final reply = await context.read<ApiService>().aiChat(msg, imagePath: imagePath);
      setState(() {
        _messages.add({'role': 'ai', 'text': reply});
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'ai', 'text': 'Sorry, I am having trouble connecting.'});
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.grey200)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppTheme.black),
                const SizedBox(width: 12),
                const Text('Cyber Assistant', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final m = _messages[i];
                final isAi = m['role'] == 'ai';
                return Align(
                  alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                    children: [
                      if (m['image'] != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(File(m['image'])),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      if (m['text'] != null && (m['text'] as String).isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isAi ? AppTheme.grey100 : AppTheme.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            m['text']!,
                            style: TextStyle(color: isAi ? AppTheme.black : AppTheme.white, fontSize: 14),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_loading) const LinearProgressIndicator(minHeight: 2, color: AppTheme.black, backgroundColor: AppTheme.grey100),
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        right: -10,
                        top: -10,
                        child: IconButton(
                          onPressed: () => setState(() => _selectedImage = null),
                          icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt, color: AppTheme.grey600),
                ),
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: AppTheme.grey100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _send,
                  icon: const Icon(Icons.send),
                  style: IconButton.styleFrom(backgroundColor: AppTheme.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
