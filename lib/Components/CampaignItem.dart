import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CampaignHeader.dart';
import 'package:one_d_m/Components/CampaignPost.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/Helper.dart';
import 'package:one_d_m/Pages/CampaignPage.dart';

class CampaignItem extends StatelessWidget {
  Campaign campaign;

  CampaignItem(this.campaign);

  TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => CampaignPage(campaign)));
      },
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          CampaignHeader(campaign),
          SizedBox(
            height: 20,
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: CampaignPost(campaign)),
          Divider()
        ],
      ),
    );
  }
}
