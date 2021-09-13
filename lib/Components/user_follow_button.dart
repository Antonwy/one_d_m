import 'package:flutter/material.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/helper/database_service.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:provider/provider.dart';

class UserFollowButton extends StatefulWidget {
  final String followerId;
  final User user;
  final Color color, textColor;
  final double backOpacity;

  UserFollowButton({
    @required this.followerId,
    this.user,
    this.color,
    this.textColor,
    this.backOpacity = .5,
  });

  @override
  _UserFollowButtonState createState() => _UserFollowButtonState();
}

class _UserFollowButtonState extends State<UserFollowButton> {
  bool _loading = false;
  bool _subscribed;

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
              style: _theme.textTheme.dark.bodyText1
                  .copyWith(fontSize: 11, color: widget.textColor),
            ),
          ));

    return FutureBuilder<User>(
        future: widget.user == null
            ? Api().users().getOne(widget.followerId)
            : Future.value(widget.user),
        builder: (context, snapshot) {
          if (snapshot.hasData && _subscribed == null)
            _subscribed = snapshot.data?.subscribed;

          return Material(
              clipBehavior: Clip.antiAlias,
              color: (widget.color ?? _theme.colors.contrast)
                  .withOpacity(widget.backOpacity),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: !snapshot.hasData || _loading
                    ? null
                    : () async {
                        setState(() {
                          _loading = true;
                        });

                        try {
                          await (_subscribed
                              ? Api().users().unsubscribe(widget.followerId)
                              : Api().users().subscribe(widget.followerId));
                          setState(() {
                            _loading = false;
                            _subscribed = !_subscribed;
                          });
                        } catch (e) {
                          print(e);
                          setState(() {
                            _loading = false;
                          });
                        }
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
                          (_subscribed ?? false) ? "Entfolgen" : "Folgen",
                          style: _theme.textTheme.dark.bodyText1
                              .copyWith(fontSize: 11, color: widget.textColor),
                        ),
                ),
              ));
        });
  }
}
