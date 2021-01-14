import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';

class ProfileWidget extends StatelessWidget {
  final imgUrl;
  final Color color;
  final double radius;
  final double size;

  const ProfileWidget({Key key, this.imgUrl, this.color, this.radius, this.size,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    BaseTheme _bTheme = ThemeManager.of(context).colors;
    return CircleAvatar(
      radius: radius,
      backgroundColor: color ?? _bTheme.dark,
      child: CachedNetworkImage(
        imageUrl: imgUrl??'',
        imageBuilder: (context, imageProvider) => Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) => _buildError(context),
        errorWidget: (context, url, error) => _buildError(context),
      ),
    );
  }

  Widget _buildError(BuildContext context) => Icon(
        Icons.person,
        color: ThemeManager.of(context).colors.contrast,
      );
}
