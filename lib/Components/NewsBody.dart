import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/BottomDialog.dart';
import 'package:one_d_m/Helper/News.dart';
import 'package:one_d_m/Pages/NewsPage.dart';
import 'package:timeago/timeago.dart' as timeago;

class NewsBody extends StatelessWidget {
  News news;

  NewsBody(this.news);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          BottomDialog(context,
                  curve: ElasticOutCurve(1.4),
                  duration: Duration(milliseconds: 500))
              .show(NewsPage(news));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 230,
              child: Stack(
                children: <Widget>[
                  CachedNetworkImage(
                    width: double.infinity,
                    imageUrl: news.imageUrl,
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
            LayoutBuilder(builder: (context, constraints) {
              return Container(
                height: 85,
                width: constraints.maxWidth,
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      news.title,
                      style: Theme.of(context).textTheme.title,
                    ),
                    SizedBox(height: 5),
                    Text(
                      news.shortText,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
