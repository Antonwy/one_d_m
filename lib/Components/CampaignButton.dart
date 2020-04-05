import 'package:flutter/material.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Components/CampaignPageRoute.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';

import 'AnimatedFutureBuilder.dart';

class CampaignButton extends StatelessWidget {
  String id;

  CampaignButton(this.id);

  @override
  Widget build(BuildContext context) {
    return AnimatedFutureBuilder<Campaign>(
        future: DatabaseService().getCampaign(id),
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return Material(
              borderRadius: BorderRadius.circular(5),
              clipBehavior: Clip.antiAlias,
              color: Colors.white,
              child: InkWell(
                onTap: () {
                  Navigator.push(context, CampaignPageRoute(snapshot.data));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Avatar(snapshot.data.imgUrl),
                      SizedBox(width: 10),
                      Text(
                        "${snapshot.data.name}",
                        style: Theme.of(context).textTheme.title,
                      )
                    ],
                  ),
                ),
              ),
            );
          return Container(height: 20);
        });
  }
}
