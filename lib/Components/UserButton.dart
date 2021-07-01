import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/UserFollowButton.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Pages/UserPage.dart';
import 'CustomOpenContainer.dart';
import 'DonationWidget.dart';

class UserButton extends StatelessWidget {
  final String id, additionalText;
  final User user;
  final Color color, avatarColor;
  final TextStyle textStyle;
  final double elevation;
  final bool withAddButton;
  final void Function(User user) onPressed;

  UserButton(this.id,
      {this.user,
      this.color = ColorTheme.appBg,
      this.avatarColor = ColorTheme.blue,
      this.textStyle = const TextStyle(color: Colors.black),
      this.elevation = 1,
      this.withAddButton = false,
      this.onPressed,
      this.additionalText});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
        future: user == null ? DatabaseService.getUser(id) : Future.value(user),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Material(
              borderRadius: BorderRadius.circular(5),
              clipBehavior: Clip.antiAlias,
              color: color,
              elevation: elevation,
              child: Container(
                key: Key(id),
                height: 60,
                child: InkWell(
                  onTap: () {
                    if (onPressed != null) {
                      onPressed(snapshot.data);
                      return;
                    }

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserPage(snapshot.data)));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Row(
                            children: <Widget>[
                              RoundedAvatar(
                                snapshot.data?.thumbnailUrl ??
                                    snapshot.data?.imgUrl,
                                color: avatarColor,
                                blurHash: snapshot.data?.blurHash,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  height: double.infinity,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: additionalText != null
                                        ? AutoSizeText.rich(
                                            TextSpan(children: [
                                              TextSpan(
                                                  text:
                                                      "${snapshot.data.name ?? "Gelöschter Account"} ",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(text: additionalText)
                                            ]),
                                            maxLines: 1,
                                          )
                                        : AutoSizeText(
                                            "${snapshot.data.name ?? "Gelöschter Account"}",
                                            maxLines: 1,
                                            style: TextStyle(
                                                color: textStyle.color,
                                                fontWeight: FontWeight.w500)),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        withAddButton
                            ? UserFollowButton(followerId: snapshot.data?.id)
                            : Container()
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return Container(
            key: Key("${id}_loading"),
            height: 60,
            child: Material(
              borderRadius: BorderRadius.circular(5),
              clipBehavior: Clip.antiAlias,
              color: color,
              elevation: elevation,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        RoundedAvatar(
                          null,
                          loading: true,
                          color: avatarColor,
                        ),
                        SizedBox(width: 10),
                        AutoSizeText("Laden...",
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(color: textStyle.color))
                      ],
                    ),
                    withAddButton ? UserFollowButton() : Container()
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class TurningAddButton extends StatelessWidget {
  final bool selected;
  final Function onPressed;

  const TurningAddButton({Key key, this.selected, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return IconButton(
        icon: TweenAnimationBuilder(
          duration: Duration(milliseconds: 250),
          tween: Tween<double>(begin: 0, end: selected ? 1 : 0),
          builder: (context, tween, child) => Transform.rotate(
            angle: tween * Helper.degreesToRads(45),
            child: Material(
              shape: CircleBorder(),
              color: ColorTween(
                      begin: _theme.colors.contrast.withOpacity(.3),
                      end: _theme.colors.contrast)
                  .transform(tween),
              child: Center(
                child: Icon(
                  Icons.add,
                  color: ColorTween(
                          begin: _theme.colors.dark,
                          end: _theme.colors.textOnContrast)
                      .transform(tween),
                ),
              ),
            ),
          ),
        ),
        onPressed: onPressed);
  }
}
