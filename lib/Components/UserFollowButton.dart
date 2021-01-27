import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';

class UserFollowButton extends StatefulWidget {
  final String followerId;
  final Color color;
  final double backOpacity;

  UserFollowButton({this.followerId, this.color, this.backOpacity = .5});

  @override
  _UserFollowButtonState createState() => _UserFollowButtonState();
}

class _UserFollowButtonState extends State<UserFollowButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    UserManager _um = context.watch<UserManager>();

    if (_um.uid == widget.followerId)
      return Material(
          clipBehavior: Clip.antiAlias,
          color: (widget.color ?? _theme.colors.contrast)
              .withOpacity(widget.backOpacity),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
            child: Text(
              "Ich",
              style: _theme.textTheme.dark.bodyText1.copyWith(fontSize: 11),
            ),
          ));

    return StreamBuilder<bool>(
        initialData: false,
        stream: this.widget.followerId == null
            ? null
            : DatabaseService.getFollowStream(_um.uid, this.widget.followerId),
        builder: (context, snapshot) {
          return Material(
              clipBehavior: Clip.antiAlias,
              color: (widget.color ?? _theme.colors.contrast)
                  .withOpacity(widget.backOpacity)
                  .withOpacity(widget.backOpacity),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: widget.followerId == null && _loading
                    ? null
                    : () async {
                        setState(() {
                          _loading = true;
                        });
                        await (snapshot.data
                            ? DatabaseService.deleteFollow(
                                _um.uid, widget.followerId)
                            : DatabaseService.createFollow(
                                _um.uid, widget.followerId));
                        setState(() {
                          _loading = false;
                        });
                      },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                  child: _loading
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Container(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(_theme.colors.dark),
                              )),
                        )
                      : Text(
                          snapshot.data ? "Entfolgen" : "Folgen",
                          style: _theme.textTheme.dark.bodyText1
                              .copyWith(fontSize: 11),
                        ),
                ),
              ));
        });
  }
}
