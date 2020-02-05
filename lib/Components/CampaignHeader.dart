import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/Campaign.dart';

class CampaignHeader extends StatelessWidget {
  Campaign campaign;

  TextTheme textTheme;

  CampaignHeader(this.campaign);

  @override
  Widget build(BuildContext context) {
    textTheme = Theme.of(context).textTheme;
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "${campaign.amount}€",
                  style: textTheme.title,
                ),
                Text(
                  "Spenden",
                  style: textTheme.subtitle.copyWith(color: Colors.black54),
                ),
              ],
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    image: DecorationImage(
                        image: NetworkImage(campaign.imgUrl),
                        fit: BoxFit.cover)),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  "+126",
                  style: textTheme.title,
                ),
                Text(
                  "Mitglieder",
                  style: textTheme.subtitle.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          campaign.name,
          style: textTheme.title,
        ),
        SizedBox(
          height: 5,
        ),
        Text(campaign.description, textAlign: TextAlign.center,),
      ],
    );
  }
}
