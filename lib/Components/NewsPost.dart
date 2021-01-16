import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'CampaignButton.dart';

class NewsPost extends StatelessWidget {
  News news;
  bool withCampaign;

  NewsPost(this.news, {this.withCampaign = true});

  @override
  Widget build(BuildContext context) {
    var shortText = news.shortText ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: <Widget>[
            withCampaign
                ? CampaignButton(
                    news.campaignId,
                    borderRadius: 0,
                    textStyle: TextStyle(),
                    campaign: Campaign(
                        imgUrl: news.campaignImgUrl,
                        id: news.campaignId,
                        name: news.campaignName),
                  )
                : Container(),
            Container(
              height: 260,
              child: Stack(
                children: <Widget>[
                  CachedNetworkImage(
                    width: double.infinity,
                    height: 260,
                    imageUrl: news.imageUrl ?? '',
                    errorWidget: (_, __, ___) => Center(
                        child: Icon(
                      Icons.error,
                      color: ColorTheme.orange,
                    )),
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(),
                    ),
                    fit: BoxFit.cover,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                            Colors.black.withOpacity(.7),
                            Colors.black.withOpacity(0)
                          ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        timeago.format(news.createdAt, locale: "de"),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  news.text.isEmpty
                      ? Container()
                      : _buildExpandableContent(context, news.text)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableContent(BuildContext context, String post) {
    ThemeManager _theme = ThemeManager.of(context);
    return ExpandableNotifier(
      child: Column(
        children: [
          Expandable(
            collapsed: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    post,
                    maxLines: 3,
                    softWrap: true,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                post.length > 120
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(
                            height: 1,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(6, 12, 12, 12),
                            child: ExpandableButton(
                                child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                              child: Text(
                                'MEHR',
                                textAlign: TextAlign.start,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(
                                        fontSize: 15,
                                        color: _theme.colors.dark,
                                        fontWeight: FontWeight.w700),
                              ),
                            )),
                          ),
                        ],
                      )
                    : SizedBox.shrink()
              ],
            ),
            expanded: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    post,
                    maxLines: null,
                    softWrap: true,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ExpandableButton(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        height: 1,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(6, 12, 12, 12),
                        child: ExpandableButton(
                            child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                          child: Text(
                            'WENIGER',
                            textAlign: TextAlign.start,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(
                                    fontSize: 15,
                                    color: _theme.colors.dark,
                                    fontWeight: FontWeight.w700),
                          ),
                        )),
                      ),
                    ],
                  )),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
