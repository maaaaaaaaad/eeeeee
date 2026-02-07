import 'package:flutter/material.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';
import 'package:mobile_owner/shared/utils/validators.dart';

class ShopImageUrlList extends StatefulWidget {
  static const int maxImages = 5;

  final List<String> initialUrls;
  final ValueChanged<List<String>> onChanged;

  const ShopImageUrlList({
    super.key,
    this.initialUrls = const [],
    required this.onChanged,
  });

  @override
  State<ShopImageUrlList> createState() => _ShopImageUrlListState();
}

class _ShopImageUrlListState extends State<ShopImageUrlList> {
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.initialUrls
        .map((url) => TextEditingController(text: url))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _notifyChanged() {
    final urls = _controllers
        .map((c) => c.text.trim())
        .where((url) => url.isNotEmpty)
        .toList();
    widget.onChanged(urls);
  }

  void _addField() {
    if (_controllers.length >= ShopImageUrlList.maxImages) return;
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _removeField(int index) {
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
    _notifyChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(_controllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controllers[index],
                    decoration: InputDecoration(
                      hintText: 'https://example.com/image.jpg',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: const OutlineInputBorder(),
                      errorText: _controllers[index].text.isNotEmpty
                          ? ImageUrlValidator.validate(_controllers[index].text)
                          : null,
                    ),
                    style: const TextStyle(fontSize: 14),
                    onChanged: (_) {
                      setState(() {});
                      _notifyChanged();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _removeField(index),
                  icon: const Icon(Icons.remove_circle_outline),
                  color: AppColors.error,
                  iconSize: 20,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          );
        }),
        if (_controllers.length < ShopImageUrlList.maxImages)
          TextButton.icon(
            onPressed: _addField,
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              '이미지 URL 추가 (${_controllers.length}/${ShopImageUrlList.maxImages})',
              style: const TextStyle(fontSize: 13),
            ),
          ),
      ],
    );
  }
}
