import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/BottomDialog.dart';
import 'package:one_d_m/Components/CampaignButton.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Components/UserButton.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/Numeral.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Pages/NewCampaignPage.dart';
import 'package:one_d_m/Pages/UserPage.dart';
import 'package:timeago/timeago.dart' as timeago;

class DonationWidget extends StatelessWidget {
  final Donation donation;
  final bool campaignPage, withUsername, backgroundLight;
  Color textColor;

  DonationWidget(this.donation,
      {this.campaignPage = false,
      this.withUsername = true,
      this.backgroundLight = true,
      this.textColor});
  TextTheme _textTheme;

  Future _future;

  MediaQueryData _mq;

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    _mq = MediaQuery.of(context);
    if (_future == null) _future = DatabaseService.getUser(donation.userId);

    return campaignPage ? _campaignPage() : _noCampaignPage();
  }

  Widget _campaignPage() {
    return FutureBuilder<User>(
      future: _future,
      builder: (context, snapshot) {
        User user = snapshot.data;
        return CustomOpenContainer(
          openBuilder: (context, close, controller) =>
              UserPage(user, scrollController: controller),
          closedElevation: 0,
          closedBuilder: (context, open) => ListTile(
            leading: user == null
                ? CircularProgressIndicator()
                : RoundedAvatar(
                    donation.anonym ? null : user.imgUrl,
                    backgroundLight: backgroundLight,
                  ),
            title: AutoSizeText(
              snapshot.hasData
                  ? donation.anonym
                      ? "Anonym"
                      : "${user.name}"
                  : "Laden...",
              maxLines: 1,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: textColor ??
                      (backgroundLight
                          ? ColorTheme.blue
                          : ColorTheme.whiteBlue)),
            ),
            subtitle: AutoSizeText(
              "${donation.campaignName} (${timeago.format(donation.createdAt)})",
              maxLines: 1,
              style: TextStyle(
                  color: textColor ??
                      (backgroundLight
                          ? ColorTheme.blue.withOpacity(.7)
                          : ColorTheme.whiteBlue.withOpacity(.7))),
            ),
            trailing: Text(
              "${Numeral(donation.amount).value()} DV",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor ??
                      (backgroundLight
                          ? ColorTheme.blue
                          : ColorTheme.whiteBlue)),
            ),
            onTap: () {
              if (donation.anonym) return;
              open();
            },
          ),
        );
      },
    );
  }

  Widget _noCampaignPage() {
    if (!withUsername)
      return CustomOpenContainer(
        openBuilder: (context, close, controller) => NewCampaignPage(
          Campaign(
              id: donation.campaignId,
              name: donation.campaignName,
              imgUrl: donation.campaignImgUrl),
          scrollController: controller,
        ),
        tappable: !donation.campaignDeleted,
        closedElevation: 0,
        closedColor: Colors.transparent,
        closedBuilder: (context, open) => ListTile(
          leading: RoundedAvatar(
            donation.campaignImgUrl,
            backgroundLight: backgroundLight,
            deleted: donation.campaignDeleted,
          ),
          subtitle: Text(
            timeago.format(donation.createdAt),
            style: TextStyle(
                color: textColor ??
                    (backgroundLight
                        ? ColorTheme.blue.withOpacity(.5)
                        : ColorTheme.whiteBlue.withOpacity(.5))),
          ),
          title: AutoSizeText(donation.campaignName,
              maxLines: 1,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: textColor ??
                      (backgroundLight
                          ? ColorTheme.blue
                          : ColorTheme.whiteBlue))),
          trailing: Text(
            "${Numeral(donation.amount).value()} DV",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor ??
                    (backgroundLight ? ColorTheme.blue : ColorTheme.whiteBlue)),
          ),
        ),
      );

    return FutureBuilder<User>(
      future: _future,
      builder: (context, snapshot) {
        User user = snapshot.data;
        return ListTile(
          leading: user == null
              ? CircularProgressIndicator()
              : RoundedAvatar(
                  user.imgUrl,
                  backgroundLight: backgroundLight,
                ),
          title: AutoSizeText(
            snapshot.hasData
                ? donation.anonym
                    ? "Anonym"
                    : "${user.name}"
                : "Laden...",
            maxLines: 1,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                color: textColor ??
                    (backgroundLight ? ColorTheme.blue : ColorTheme.whiteBlue)),
          ),
          subtitle: AutoSizeText(
            "${donation.campaignName} (${timeago.format(donation.createdAt)})",
            maxLines: 1,
            style: TextStyle(
                color: textColor ??
                    (backgroundLight
                        ? ColorTheme.blue.withOpacity(.7)
                        : ColorTheme.whiteBlue.withOpacity(.7))),
          ),
          trailing: Text(
            "${Numeral(donation.amount).value()} DV",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor ??
                    (backgroundLight ? ColorTheme.blue : ColorTheme.whiteBlue)),
          ),
          onTap: () {
            if (!withUsername) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) => NewCampaignPage(Campaign(
                          id: donation.campaignId,
                          imgUrl: donation.campaignImgUrl,
                          name: donation.campaignName))));
              return;
            }
            _showBottomDialog(context, user);
          },
        );
      },
    );
  }

  void _showBottomDialog(BuildContext context, User user) {
    BottomDialog(context, duration: Duration(milliseconds: 125)).show(Material(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      clipBehavior: Clip.antiAlias,
      color: ColorTheme.navBar,
      child: Padding(
        padding: EdgeInsets.only(
            top: 10,
            bottom: _mq.padding.bottom == 0 ? 10 : _mq.padding.bottom,
            left: 10,
            right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CampaignButton(
              donation.campaignId,
              color: ColorTheme.navBar,
              textStyle: _textTheme.headline6,
              elevation: 0,
            ),
            UserButton(
              user.id,
              user: user,
              color: ColorTheme.navBar,
              elevation: 0,
              textStyle: _textTheme.headline6,
            )
          ],
        ),
      ),
    ));
  }
}

class RoundedAvatar extends StatelessWidget {
  final String imgUrl;
  final bool loading, backgroundLight, deleted;
  final double height;
  final double defaultHeight = 20, borderRadius, elevation;
  final Color iconColor, color;
  final String name;
  final BoxFit fit;

  ThemeManager _theme;

  RoundedAvatar(this.imgUrl,
      {this.loading = false,
      this.backgroundLight = true,
      this.height,
      this.elevation = 0,
      this.iconColor,
      this.borderRadius = Constants.radius,
      this.color,
      this.deleted = false,
      this.fit = BoxFit.cover,
      this.name});

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(
          minHeight: (height ?? defaultHeight),
          minWidth: (height ?? defaultHeight),
          maxHeight: (height ?? defaultHeight) + 25,
          maxWidth: (height ?? defaultHeight) + 25),
      child: LayoutBuilder(builder: (context, constraints) {
        return AspectRatio(
          aspectRatio: 1,
          child: Material(
              elevation: elevation,
              color: color ??
                  (backgroundLight
                      ? _theme.colors.dark
                      : _theme.colors.darkerLight),
              borderRadius: BorderRadius.circular(borderRadius),
              clipBehavior: Clip.antiAlias,
              child: _buildImage()),
        );
      }),
    );
  }

  Widget _buildImage() {
    if (deleted)
      return Icon(
        Icons.delete,
        color: iconColor ?? _theme.colors.contrast,
      );

    return imgUrl == null
        ? Center(
            child: loading
                ? Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation(backgroundLight
                            ? _theme.colors.dark
                            : _theme.colors.contrast),
                      ),
                    ),
                  )
                : name != null
                    ? Text(
                        name[0].toUpperCase(),
                        style: TextStyle(
                            color: iconColor ?? _theme.colors.contrast,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      )
                    : Icon(
                        Icons.person,
                        color: iconColor ?? _theme.colors.contrast,
                      ),
          )
        : CachedNetworkImage(
            imageUrl: imgUrl,
            fit: fit,
            errorWidget: (context, error, obj) => Icon(
              Icons.error,
              color: iconColor ?? _theme.colors.contrast,
            ),
          );
  }
}
