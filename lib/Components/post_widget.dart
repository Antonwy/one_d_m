import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostWidget extends StatelessWidget {
  final News post;

  const PostWidget({Key key, this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BaseTheme _bTheme = ThemeManager.of(context).colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0,),
      width: context.screenWidth(percent: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        color: Colors.white,
        border: Border.all(width: 0.5, color: _bTheme.dark.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: _bTheme.dark.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(4, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostImage(_bTheme.dark),
          _buildTitle(context),
          _buildExpandableContent(context)
        ],
      ),
    );
  }

  Widget _buildPostImage(Color color) => ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.0), topRight: Radius.circular(12.0)),
        child: CachedNetworkImage(
          imageUrl: post.imageUrl ?? '',
          height: 215,
          width: double.infinity,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => Container(
            height: 215,
            child: Center(
                child: Icon(
              Icons.error,
              color: color,
            )),
          ),
          placeholder: (_, __) => Container(
            height: 215,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          alignment: Alignment.center,
        ),
      );

  Widget _buildTitle(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
        child: Row(
          children: [
            Text(
              post.title,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.clip,
              style: Theme.of(context).textTheme.headline6.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
            const Expanded(
              child: SizedBox(),
            ),
            Text(
              timeago.format(post.createdAt, locale: "de"),
              style: Theme.of(context).textTheme.bodyText1.copyWith(
                  fontSize: 12,
                  color: Helper.hexToColor('#707070'),
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );

  Widget _buildExpandableContent(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
        child: ExpandableNotifier(
          child: Column(
            children: [
              Expandable(
                collapsed: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.text,
                      maxLines: 3,
                      softWrap: true,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                          fontSize: 15,
                          color: Helper.hexToColor('#707070'),
                          fontWeight: FontWeight.w400),
                    ),
                    post.text.length > 90
                        ? Align(
                            alignment: Alignment.bottomRight,
                            child: ExpandableButton(
                                child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'mehr',
                                  textAlign: TextAlign.start,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(
                                          fontSize: 15,
                                          color: Helper.hexToColor('#707070'),
                                          fontWeight: FontWeight.w400),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                  color: Helper.hexToColor('#707070'),
                                )
                              ],
                            )),
                          )
                        : SizedBox.shrink()
                  ],
                ),
                expanded: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.text,
                      maxLines: null,
                      softWrap: true,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                          fontSize: 15,
                          color: Helper.hexToColor('#707070'),
                          fontWeight: FontWeight.w400),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ExpandableButton(
                          child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'weniger',
                            textAlign: TextAlign.start,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(
                                    fontSize: 15,
                                    color: Helper.hexToColor('#707070'),
                                    fontWeight: FontWeight.w400),
                          ),
                          Icon(
                            Icons.keyboard_arrow_up_outlined,
                            color: Helper.hexToColor('#707070'),
                          )
                        ],
                      )),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      );
}
