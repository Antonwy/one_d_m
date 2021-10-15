import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/components/donation_widget.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/views/users/user_page.dart';

import 'user_follow_button.dart';

class VerticalUserButton extends StatelessWidget {
  final User user;
  final Color? backgroundColor, followButtonColor, avatarColor;
  final String? additionalText;
  const VerticalUserButton(this.user,
      {this.backgroundColor,
      this.followButtonColor,
      this.avatarColor,
      this.additionalText});

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);

    return Container(
      width: 85,
      child: Card(
        color: backgroundColor ?? _theme.cardColor,
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (c) => UserPage(
                          user,
                        )));
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                RoundedAvatar(
                  user.imgUrl,
                  blurHash: user.imgUrl,
                  height: 30,
                  color: avatarColor,
                  iconColor: avatarColor?.textColor,
                ),
                YMargin(6),
                Container(
                  width: 76,
                  height: 20,
                  child: Center(
                    child: AutoSizeText(user.name ?? "Laden...",
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: _theme.textTheme.headline6!.copyWith(
                            fontSize: 14,
                            color: backgroundColor == null
                                ? null
                                : backgroundColor!.textColor)),
                  ),
                ),
                YMargin(6),
                additionalText == null
                    ? UserFollowButton(
                        followerId: user.id,
                        color: followButtonColor,
                      )
                    : FittedBox(
                        child: Text(additionalText!,
                            style: _theme.textTheme.bodyText1!.copyWith(
                                fontSize: 14,
                                color: backgroundColor == null
                                    ? null
                                    : backgroundColor!.textColor))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
