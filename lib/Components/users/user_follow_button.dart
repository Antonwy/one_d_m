import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:provider/provider.dart';

class UserFollowButton extends StatefulWidget {
  final String? followerId;
  final User? user;
  final Color? color;
  final double backOpacity;

  UserFollowButton({
    required this.followerId,
    this.user,
    this.color,
    this.backOpacity = .5,
  });

  @override
  _UserFollowButtonState createState() => _UserFollowButtonState();
}

class _UserFollowButtonState extends State<UserFollowButton> {
  bool _loading = false;
  bool? _subscribed;
  late Color _textColor;

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    _textColor = widget.color == null
        ? _theme.colorScheme.onPrimary
        : _theme.correctColorFor(widget.color ?? _theme.primaryColor);
    UserManager _um = context.watch<UserManager>();

    if (_um.uid == widget.followerId)
      return Container(
        height: 25,
        child: Material(
            clipBehavior: Clip.antiAlias,
            color: (widget.color ?? _theme.primaryColor),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
              child: FittedBox(
                child: Text(
                  "Ich",
                  style: _theme.textTheme.bodyText1!
                      .copyWith(fontSize: 11, color: _textColor),
                ),
              ),
            )),
      );

    return FutureBuilder<User?>(
        future: widget.user == null
            ? Api().users().getOne(widget.followerId)
            : Future.value(widget.user),
        builder: (context, snapshot) {
          if (snapshot.hasData && _subscribed == null)
            _subscribed = snapshot.data?.subscribed;

          return Container(
            height: 25,
            child: Material(
                clipBehavior: Clip.antiAlias,
                color: (widget.color ?? _theme.primaryColor),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: !snapshot.hasData || _loading
                      ? null
                      : () async {
                          setState(() {
                            _loading = true;
                          });

                          try {
                            await (_subscribed!
                                ? Api().users().unsubscribe(widget.followerId)
                                : Api().users().subscribe(widget.followerId));
                            setState(() {
                              _loading = false;
                              _subscribed = !_subscribed!;
                            });
                          } catch (e) {
                            print(e);
                            setState(() {
                              _loading = false;
                            });
                          }
                        },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 12),
                    child: AnimatedSize(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.fastLinearToSlowEaseIn,
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 125),
                        child: _loading
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child:
                                    LoadingIndicator(size: 12, strokeWidth: 2))
                            : FittedBox(
                                child: Text(
                                  (_subscribed ?? false)
                                      ? "Entfolgen"
                                      : "Folgen",
                                  maxLines: 1,
                                  style: _theme.textTheme.bodyText1!
                                      .copyWith(color: _textColor),
                                ),
                              ),
                      ),
                    ),
                  ),
                )),
          );
        });
  }
}
