import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:transparent_image/transparent_image.dart';

class Avatar extends StatefulWidget {
  String imageUrl;
  IconData icon;
  Function onTap;
  double elevation;

  Avatar(this.imageUrl, {this.icon, this.onTap, this.elevation = 0.0});

  @override
  _AvatarState createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  bool _error = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Material(
          elevation: widget.elevation,
          shape: CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: CircleAvatar(
              backgroundColor: ColorTheme.avatar,
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: widget.imageUrl != null
                        ? FadeInImage(
                            placeholder: MemoryImage(kTransparentImage),
                            image: CachedNetworkImageProvider(widget.imageUrl,
                                errorListener: () {
                              setState(() {
                                _error = true;
                              });
                            }),
                            fit: BoxFit.cover,
                            fadeInDuration: Duration(milliseconds: 300),
                          )
                        : Container(),
                  ),
                  widget.imageUrl == null || _error
                      ? Icon(
                          widget.icon ?? Icons.person,
                          color: Colors.white,
                        )
                      : Container(),
                ],
              ))),
    );
  }
}
