import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Helper.dart';

class FollowButton extends StatefulWidget {
  Future<void> Function() onPressed;
  bool followed;

  FollowButton({this.onPressed, this.followed});

  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  final Duration _duration = Duration(milliseconds: 125);
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return OfflineBuilder(
        child: Container(),
        connectivityBuilder: (context, connection, child) {
          bool activated = connection != ConnectivityResult.none;
          return Material(
            shape: CircleBorder(),
            clipBehavior: Clip.antiAlias,
            elevation: 4,
            child: InkWell(
              onTap: activated
                  ? (_loading
                      ? null
                      : () async {
                          if (widget.onPressed == null) return;

                          setState(() {
                            _loading = true;
                          });
                          await widget.onPressed();
                          setState(() {
                            _loading = false;
                          });
                        })
                  : () {
                      Helper.showConnectionSnackBar(context);
                    },
              child: AnimatedContainer(
                width: 56,
                height: 56,
                duration: _duration,
                color: activated
                    ? (widget.followed ? ColorTheme.orange : ColorTheme.whiteBlue)
                    : Colors.grey,
                child: TweenAnimationBuilder(
                    duration: _duration,
                    tween: Tween<double>(
                        begin: 0,
                        end: widget.followed ? degreesToRads(45) : 0.0),
                    builder: (context, value, child) =>
                        Transform.rotate(angle: value, child: child),
                    child: TweenAnimationBuilder(
                        tween: ColorTween(
                            begin: ColorTheme.blue,
                            end: widget.followed
                                ? ColorTheme.whiteBlue
                                : ColorTheme.blue),
                        duration: _duration,
                        builder: (context, color, child) => Stack(
                              children: <Widget>[
                                Center(
                                    child: Container(
                                        width: 30,
                                        height: 30,
                                        child: _loading
                                            ? CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        color),
                                              )
                                            : Container())),
                                Center(child: Icon(Icons.add, color: color)),
                              ],
                            ))),
              ),
            ),
          );
        });
  }

  double degreesToRads(double deg) {
    return (deg * pi) / 180.0;
  }
}
