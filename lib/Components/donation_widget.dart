import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/components/users/user_button.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/numeral.dart';
import 'package:one_d_m/models/campaign_models/base_campaign.dart';
import 'package:one_d_m/models/donation.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/views/campaigns/campaign_page.dart';
import 'package:one_d_m/views/users/user_page.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'bottom_dialog.dart';
import 'campaigns/campaign_button.dart';
import 'custom_open_container.dart';

// ignore: must_be_immutable
class DonationWidget extends StatelessWidget {
  final Donation donation;
  final bool campaignPage, withUsername, backgroundLight;
  final Color? textColor;

  DonationWidget(this.donation,
      {this.campaignPage = false,
      this.withUsername = true,
      this.backgroundLight = true,
      this.textColor});

  late final TextTheme _textTheme;

  Future<User?>? _future;

  late final MediaQueryData _mq;

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    _mq = MediaQuery.of(context);
    if (_future == null) _future = Api().users().getOne(donation.userId);

    return campaignPage ? _campaignPage() : _noCampaignPage(context);
  }

  Widget _campaignPage() {
    return FutureBuilder<User?>(
      future: _future,
      builder: (context, snapshot) {
        User? user = snapshot.data;
        return CustomOpenContainer(
          openBuilder: (context, close, controller) =>
              UserPage(user!, scrollController: controller),
          closedElevation: 0,
          closedBuilder: (context, open) => ListTile(
            leading: user == null
                ? CircularProgressIndicator()
                : RoundedAvatar(
                    donation.anonym! ? null : user.imgUrl,
                  ),
            title: AutoSizeText(
              snapshot.hasData
                  ? donation.anonym!
                      ? "Anonym"
                      : "${user!.name}"
                  : "Laden...",
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: AutoSizeText(
              "${donation.campaignName} (${timeago.format(donation.createdAt!, locale: "de")})",
              maxLines: 1,
            ),
            trailing: Text(
              "${Numeral(donation.amount!).value()} DV",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              if (donation.anonym!) return;
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
        ),
        subtitle: Text(
          timeago.format(donation.createdAt!, locale: "de"),
          style: context.theme.textTheme.caption,
        ),
        title: AutoSizeText(donation.campaignName!,
            maxLines: 1,
            style: TextStyle(
              fontWeight: FontWeight.w500,
            )),
        trailing: AutoSizeText(
          "${Numeral(donation.amount!).value()} DV",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      );

    return FutureBuilder<User?>(
      future: _future,
      builder: (context, snapshot) {
        User? user = snapshot.data;
        return ListTile(
          leading: user == null
              ? LoadingIndicator()
              : RoundedAvatar(
                  user.imgUrl,
                ),
          title: AutoSizeText(
            snapshot.hasData
                ? donation.anonym!
                    ? "Anonym"
                    : "${user!.name}"
                : "Laden...",
            maxLines: 1,
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: AutoSizeText(
            "${donation.campaignName} (${timeago.format(donation.createdAt!)})",
            maxLines: 1,
          ),
          trailing: Text(
            "${Numeral(donation.amount!).value()} DV",
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
            _showBottomDialog(context, user!);
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
  final String? imgUrl, name, blurHash;
  final bool? loading, deleted;
  final double? height, defaultHeight = 20, borderRadius, elevation;
  final Color? iconColor, color;
  final BoxFit fit;

  late final ThemeData _theme;

  RoundedAvatar(this.imgUrl,
      {this.loading = false,
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
    _theme = Theme.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(
          minHeight: (height ?? defaultHeight!),
          minWidth: (height ?? defaultHeight!),
          maxHeight: (height ?? defaultHeight)! + 25,
          maxWidth: (height ?? defaultHeight)! + 25),
      child: LayoutBuilder(builder: (context, constraints) {
        return AspectRatio(
          aspectRatio: 1,
          child: Material(
              elevation: elevation!,
              color: color,
              borderRadius: BorderRadius.circular(borderRadius!),
              clipBehavior: Clip.antiAlias,
              child: _buildImage()),
        );
      }),
    );
  }

  Widget _buildImage() {
    if (deleted!)
      return Icon(Icons.delete, color: iconColor ?? _theme.primaryColor);

    Widget _pIndicator = AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
            child: LoadingIndicator(
          color: _theme.primaryColor,
          size: 16,
          strokeWidth: 2.2,
        )),
      ),
    );

    return imgUrl == null
        ? Center(
            child: loading!
                ? _pIndicator
                : name != null
                    ? Text(
                        name![0].toUpperCase(),
                        style: TextStyle(
                            color: iconColor ?? _theme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      )
                    : Icon(
                        Icons.person,
                        color: iconColor ?? _theme.primaryColor,
                      ),
          )
        : CachedNetworkImage(
            imageUrl: imgUrl!,
            fit: fit,
            errorWidget: (context, error, obj) => Icon(
              Icons.error,
              color: iconColor ?? _theme.primaryColor,
            ),
            placeholder: (context, _) =>
                blurHash != null ? BlurHash(hash: blurHash!) : _pIndicator,
          );
  }
}
