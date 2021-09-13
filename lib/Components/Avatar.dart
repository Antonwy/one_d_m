import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/provider/theme_manager.dart';

class Avatar extends StatefulWidget {
  final String imageUrl;
  final IconData icon;
  final Function onTap;
  final double elevation;
  final Color color, iconColor;
  final double radius;

  Avatar(this.imageUrl,
      {this.icon,
      this.onTap,
      this.elevation = 0.0,
      this.color,
      this.iconColor,
      this.radius});

  @override
  _AvatarState createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    BaseTheme _bTheme = ThemeManager.of(context).colors;
    bool _hasImage = widget.imageUrl != null && widget.imageUrl.isNotEmpty;
    return GestureDetector(
      onTap: widget.onTap,
      child: CircleAvatar(
        radius: widget.radius,
        backgroundImage:
            _hasImage ? CachedNetworkImageProvider(widget.imageUrl) : null,
        onBackgroundImageError: _hasImage
            ? (exception, stackTrace) {
                print("ERROR: " + exception.toString());
                setState(() {
                  _hasError = true;
                });
              }
            : null,
        backgroundColor: widget.color ?? _bTheme.dark,
        child: _hasError
            ? Icon(
                Icons.error,
                color: _bTheme.contrast,
              )
            : !_hasImage
                ? Icon(
                    widget.icon ?? Icons.person,
                    color: widget.iconColor ?? _bTheme.contrast,
                  )
                : Container(),
      ),
    );
  }
}

// class Avatar extends StatelessWidget {
//   final String imageUrl;
//   final IconData icon;
//   final Function onTap;
//   final double elevation;
//   final Color color, iconColor;

//   Avatar(this.imageUrl,
//       {this.icon,
//       this.onTap,
//       this.elevation = 0.0,
//       this.color = ColorTheme.blue,
//       this.iconColor = ColorTheme.orange});

//   // The default radius if nothing is specified.
//   static const double _defaultRadius = 20.0;

//   // The default min if only the max is specified.
//   static const double _defaultMinRadius = 0.0;

//   // The default max if only the min is specified.
//   static const double _defaultMaxRadius = double.infinity;

//   double get _minDiameter {
//     return 2.0 * _defaultMinRadius;
//   }

//   double get _maxDiameter {
//     return 2.0 * (_defaultMaxRadius);
//   }

//   @override
//   Widget build(BuildContext context) {
//     assert(debugCheckHasMediaQuery(context));
//     final ThemeData theme = Theme.of(context);
//     final double minDiameter = _minDiameter;
//     final double maxDiameter = _maxDiameter;
//     TextStyle textStyle =
//         theme.primaryTextTheme.subtitle1.copyWith(color: iconColor);
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         constraints: BoxConstraints(
//           minHeight: minDiameter,
//           minWidth: minDiameter,
//           maxWidth: maxDiameter,
//           maxHeight: maxDiameter,
//         ),
//         duration: kThemeChangeDuration,
//         decoration: BoxDecoration(
//           color: color,
//           shape: BoxShape.circle,
//           image: imageUrl != null
//               ? DecorationImage(
//                   image: CachedNetworkImageProvider(imageUrl),
//                   onError: (exception, stackTrace) => print(stackTrace),
//                   fit: BoxFit.cover
//                 )
//               : null,
//         ),
//         child: imageUrl != null
//             ? Container()
//             : Center(
//                 child: MediaQuery(
//                   data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
//                   child: IconTheme(
//                     data: theme.iconTheme.copyWith(color: iconColor),
//                     child: DefaultTextStyle(
//                       style: textStyle,
//                       child: Icon(Icons.person),
//                     ),
//                   ),
//                 ),
//               ),
//       ),
//     );
//   }
// }
