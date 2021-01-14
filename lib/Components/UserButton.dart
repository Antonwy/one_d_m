import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/profile_widget.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/UserPage.dart';
import 'package:provider/provider.dart';

import 'AnimatedFutureBuilder.dart';
import 'Avatar.dart';
import 'CustomOpenContainer.dart';

class UserButton extends StatelessWidget {
  final String id;
  final User user;
  final Color color, avatarColor;
  final TextStyle textStyle;
  final double elevation;
  final bool withAddButton;

  UserButton(
    this.id, {
    this.user,
    this.color = Colors.white,
    this.avatarColor = ColorTheme.blue,
    this.textStyle = const TextStyle(color: Colors.black),
    this.elevation = 1,
    this.withAddButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key(id),
      height: 60,
      child: CustomOpenContainer(
        openBuilder: (context, close, controller) =>
            UserPage(user, scrollController: controller),
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        closedElevation: elevation,
        closedColor: color,
        closedBuilder: (context, open) => Material(
          color: color,
          child: InkWell(
            onTap: open,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        ProfileWidget(
                            imgUrl: user.thumbnailUrl ?? user.imgUrl,
                            radius: 20,
                            size: 40,
                            color: avatarColor),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: double.infinity,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: AutoSizeText(
                                  "${user?.name ?? "Gelöschter Account"}",
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
                      ? Consumer<UserManager>(
                          builder: (context, um, child) => StreamBuilder<bool>(
                              initialData: false,
                              stream:
                                  DatabaseService.getFollowStream(um.uid, id),
                              builder: (context, snapshot) {
                                return TurningAddButton(
                                  selected: snapshot.data,
                                  onPressed: () {
                                    if (snapshot.data)
                                      DatabaseService.deleteFollow(um.uid, id);
                                    else
                                      DatabaseService.createFollow(um.uid, id);
                                  },
                                );
                              }),
                        )
                      : Container()
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
