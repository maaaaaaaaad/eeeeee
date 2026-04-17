import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class ShopImagePicker extends StatefulWidget {
  static const int maxImages = 5;

  final List<String> initialUrls;
  final ValueChanged<List<String>> onChanged;
  final Future<String> Function(File file) onUpload;
  final ValueChanged<bool>? onUploadingChanged;

  const ShopImagePicker({
    super.key,
    this.initialUrls = const [],
    required this.onChanged,
    required this.onUpload,
    this.onUploadingChanged,
  });

  @override
  State<ShopImagePicker> createState() => _ShopImagePickerState();
}

class _ImageItem {
  final String? url;
  final File? localFile;
  bool isUploading;

  _ImageItem({this.url, this.localFile, this.isUploading = false});
}

class _ShopImagePickerState extends State<ShopImagePicker> {
  final _picker = ImagePicker();
  late List<_ImageItem> _items;
  int _uploadingCount = 0;

  @override
  void initState() {
    super.initState();
    _items = widget.initialUrls
        .map((url) => _ImageItem(url: url))
        .toList();
  }

  void _notifyChanged() {
    final urls = _items
        .where((item) => item.url != null && !item.isUploading)
        .map((item) => item.url!)
        .toList();
    widget.onChanged(urls);
  }

  void _updateUploadingState(int delta) {
    _uploadingCount += delta;
    widget.onUploadingChanged?.call(_uploadingCount > 0);
  }

  Future<File?> _cropImage(File file) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: file.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '사진 편집',
          toolbarColor: AppColors.pastelPink,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppColors.pastelPink,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: '사진 편집',
          cancelButtonTitle: '취소',
          doneButtonTitle: '완료',
        ),
      ],
    );
    if (cropped == null) return null;
    return File(cropped.path);
  }

  Future<void> _pickAndUploadSingle(ImageSource source) async {
    if (_items.length >= ShopImagePicker.maxImages) return;

    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (picked == null) return;

    final edited = await _cropImage(File(picked.path));
    if (edited == null) return;

    await _uploadFile(edited);
  }

  Future<void> _pickMultipleFromGallery() async {
    final remaining = ShopImagePicker.maxImages - _items.length;
    if (remaining <= 0) return;

    final picked = await _picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
      limit: remaining,
    );
    if (picked.isEmpty) return;

    final filesToUpload = picked.take(remaining).toList();

    for (final xFile in filesToUpload) {
      if (_items.length >= ShopImagePicker.maxImages) break;

      final edited = await _cropImage(File(xFile.path));
      if (edited == null) continue;

      await _uploadFile(edited);
    }
  }

  Future<void> _uploadFile(File file) async {
    final item = _ImageItem(localFile: file, isUploading: true);

    setState(() {
      _items.add(item);
    });
    _updateUploadingState(1);

    try {
      final url = await widget.onUpload(file);
      setState(() {
        final idx = _items.indexOf(item);
        if (idx >= 0) {
          _items[idx] = _ImageItem(url: url);
        }
      });
      _notifyChanged();
    } catch (e) {
      setState(() {
        _items.remove(item);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 업로드에 실패했습니다: $e')),
        );
      }
    } finally {
      _updateUploadingState(-1);
    }
  }

  void _showSourcePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadSingle(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('앨범에서 선택'),
              onTap: () {
                Navigator.pop(context);
                _pickMultipleFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _items.removeAt(index);
    });
    _notifyChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              if (_items.length < ShopImagePicker.maxImages)
                _AddButton(onTap: _showSourcePicker),
              ..._items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _ImageTile(
                  item: item,
                  onRemove: () => _removeImage(index),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_items.where((i) => !i.isUploading).length}/${ShopImagePicker.maxImages}장',
          style: TextStyle(fontSize: 12, color: AppColors.textHint),
        ),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, color: AppColors.textHint, size: 28),
            const SizedBox(height: 4),
            Text(
              '사진 추가',
              style: TextStyle(fontSize: 11, color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  final _ImageItem item;
  final VoidCallback onRemove;

  const _ImageTile({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: item.url != null
                ? CachedNetworkImage(
                    imageUrl: item.url!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.divider,
                      child: const Icon(Icons.broken_image),
                    ),
                  )
                : item.localFile != null
                    ? Image.file(
                        item.localFile!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : Container(color: AppColors.divider),
          ),
          if (item.isUploading)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          if (!item.isUploading)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
