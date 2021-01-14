import 'package:flutter/material.dart';

class ImageWidgetPlaceholder extends StatelessWidget {
  const ImageWidgetPlaceholder({
    Key key,
    this.image,
    this.placeholder,
  }) : super(key: key);
  final ImageProvider image;
  final Widget placeholder;
  @override
  Widget build(BuildContext context) {
    return Image(
      image: image,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        } else {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: frame != null ? child : placeholder,
          );
        }
      },
    );
  }
}
