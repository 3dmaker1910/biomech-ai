import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/photo.dart';

class PhotoGridWidget extends StatelessWidget {
  final List<Photo> photos;
  final String apiBaseUrl;

  const PhotoGridWidget({super.key, required this.photos, required this.apiBaseUrl});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.0),
      itemCount: photos.length,
      itemBuilder: (context, index) => _buildPhotoTile(context, photos[index]),
    );
  }

  Widget _buildPhotoTile(BuildContext context, Photo photo) {
    final label = AppConstants.photoTypeLabels[photo.photoType] ?? photo.photoType;
    final imageUrl = '$apiBaseUrl/${photo.filePath}';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(fit: StackFit.expand, children: [
        CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: Colors.grey.shade200, child: const Center(child: CircularProgressIndicator())),
          errorWidget: (context, url, error) => Container(color: Colors.grey.shade200, child: const Center(child: Icon(Icons.broken_image, color: Colors.grey))),
        ),
        Positioned(bottom: 0, left: 0, right: 0, child: Container(
          color: Colors.black54,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
        )),
      ]),
    );
  }
}
