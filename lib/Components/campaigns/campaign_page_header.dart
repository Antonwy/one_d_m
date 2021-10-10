import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/components/video_or_image.dart';
import 'package:one_d_m/components/discovery_holder.dart';
import 'package:one_d_m/components/donation_widget.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/dynamic_link_manager.dart';
import 'package:one_d_m/models/campaign_models/campaign.dart';
import 'package:one_d_m/provider/campaign_manager.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/views/home/profile_page.dart';
import 'package:one_d_m/views/organizations/organization_page.dart';
import 'package:social_share/social_share.dart';
import 'package:provider/provider.dart';

class CampaignPageHeader extends StatefulWidget {
  const CampaignPageHeader();

  @override
  _CampaignPageHeaderState createState() => _CampaignPageHeaderState();
}

class _CampaignPageHeaderState extends State<CampaignPageHeader> {
  ValueNotifier _show = ValueNotifier<bool>(false);

  Future<void> _shareCampaign(CampaignManager cm) async {
    if ((cm.baseCampaign?.name?.isEmpty ?? true) ||
        (cm.baseCampaign?.imgUrl?.isEmpty ?? true)) return;
    SocialShare.shareOptions((await DynamicLinkManager.of(context)
            .createCampaignLink(cm.baseCampaign as Campaign))
        .toString());
  }

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 500))
        .then((value) => _show.value = true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CampaignManager cm = context.watch<CampaignManager>();
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.width,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
              child: VideoOrImage(
                imageUrl: cm.baseCampaign?.imgUrl,
                videoUrl: cm.baseCampaign?.longVideoUrl,
                blurHash: cm.baseCampaign?.blurHash,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            right: 12,
            left: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppBarButton(
                    elevation: 10,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icons.arrow_back),
                Row(
                  children: [
                    DiscoveryHolder.shareButton(
                      tapTarget: Icon(
                        CupertinoIcons.share,
                        color: ThemeManager.of(context).colors!.contrast,
                      ),
                      child: Center(
                        child: AppBarButton(
                            icon: CupertinoIcons.share,
                            elevation: 10,
                            onPressed: () => _shareCampaign(cm)),
                      ),
                    ),
                    XMargin(6),
                    AppBarButton(
                      elevation: 10,
                      onPressed: cm.loadingCampaign!
                          ? null
                          : () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OrganizationPage(
                                          cm.campaign!.organization)));
                            },
                      child: RoundedAvatar(
                        cm.campaign?.organization.thumbnailUrl ??
                            cm.campaign?.organization.imgUrl,
                        height: 15,
                        color: ColorTheme.appBg,
                        loading: cm.loadingCampaign,
                        fit: BoxFit.contain,
                        borderRadius: 6,
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
