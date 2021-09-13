import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:one_d_m/components/user_button.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/database_service.dart';
import 'package:one_d_m/helper/numeral.dart';
import 'package:one_d_m/models/campaign_models/base_campaign.dart';
import 'package:one_d_m/models/campaign_models/campaign.dart';
import 'package:one_d_m/models/donation.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/views/campaigns/campaign_page.dart';
import 'package:one_d_m/views/users/user_page.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'bottom_dialog.dart';
import 'campaign_button.dart';
import 'custom_open_container.dart';

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

    return campaignPage ? _campaignPage() : _noCampaignPage(context);
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
              "${donation.campaignName} (${timeago.format(donation.createdAt, locale: "de")})",
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

  Widget _noCampaignPage(BuildContext context) {
    if (!withUsername)
      return ListTile(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (c) => CampaignPage(
                        BaseCampaign(
                            id: donation.campaignId,
                            name: donation.campaignName,
                            imgUrl: donation.campaignImgUrl,
                            blurHash: donation.campaignBlurHash,
                            unit: donation.donationUnit),
                      )));
        },
        leading: RoundedAvatar(
          donation.campaignImgUrl,
          backgroundLight: backgroundLight,
        ),
        subtitle: Text(
          timeago.format(donation.createdAt, locale: "de"),
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
        trailing: AutoSizeText(
          "${Numeral(donation.amount).value()} DV",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor ??
                  (backgroundLight ? ColorTheme.blue : ColorTheme.whiteBlue)),
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
                      builder: (c) => CampaignPage(BaseCampaign(
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
  final String imgUrl, name, blurHash;
  final bool loading, backgroundLight, deleted;
  final double height, defaultHeight = 20, borderRadius, elevation;
  final Color iconColor, color;
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
      this.name,
      this.blurHash});

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

    Widget _pIndicator = AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Container(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(backgroundLight
                  ? _theme.colors.contrast
                  : _theme.colors.dark),
            ),
          ),
        ),
      ),
    );

    return imgUrl == null
        ? Center(
            child: loading
                ? _pIndicator
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
            placeholder: (context, _) =>
                blurHash != null ? BlurHash(hash: blurHash) : _pIndicator,
          );
  }
}
