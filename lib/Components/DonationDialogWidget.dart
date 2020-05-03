import 'package:flutter/material.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/CampaignsManager.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';

class DonationDialogWidget extends StatefulWidget {
  Function close;
  Campaign campaign;
  User user;
  BuildContext context;

  DonationDialogWidget({this.close, this.campaign, this.user, this.context});

  @override
  _DonationDialogWidgetState createState() => _DonationDialogWidgetState();
}

class _DonationDialogWidgetState extends State<DonationDialogWidget>
    with SingleTickerProviderStateMixin {
  ThemeData _theme;

  int _amount;
  Campaign _alternativCampaign;

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);

    return Material(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Wieviele Coins?",
                      style: _theme.textTheme.title,
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      "Wieviele Coins willst du spenden?",
                      style: _theme.textTheme.body1
                          .copyWith(color: Colors.black54),
                    ),
                  ],
                ),
                Container(
                  height: 35,
                  width: 35,
                  child: Material(
                    color: Colors.grey[300],
                    shape: CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: widget.close,
                      child: Center(
                        child: Icon(
                          Icons.close,
                          color: Colors.grey[700],
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                List<int> values = [1, 2, 5, 10, 15, 20];
                return Center(
                  child: Container(
                    width: 120,
                    height: 100,
                    margin: index == 0
                        ? EdgeInsets.only(left: 20)
                        : index == 5 ? EdgeInsets.only(right: 20) : null,
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: _amount == values[index] ? 2 : 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _amount = values[index];
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Material(
                                color: Colors.indigo[100],
                                shape: CircleBorder(),
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "\$",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.indigo),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "${values[index]}.00",
                                style: _theme.textTheme.title,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              itemCount: 6,
            ),
          ),
          Consumer2<CampaignsManager, UserManager>(
              builder: (context, cm, um, child) {
            List<Campaign> possibleCampaigns =
                cm.getSubscribedCampaigns(um.user);
            possibleCampaigns.removeWhere((c) => c.id == widget.campaign.id);
            List<Campaign> campaigns = possibleCampaigns.isNotEmpty
                ? cm.getSubscribedCampaigns(um.user)
                : cm.getAllCampaigns();

            campaigns.removeWhere((c) => c.id == widget.campaign.id);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Alternatives Projekt: ",
                        style: _theme.textTheme.title,
                      ),
                      Text(
                        "Auswahl aus ${possibleCampaigns.isNotEmpty ? "deinen abonnierten" : "allen"} Projekten",
                        style: _theme.textTheme.body1,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Center(
                          child: Container(
                            height: 80,
                            margin: index == 0
                                ? EdgeInsets.only(left: 20)
                                : index == campaigns.length - 1
                                    ? EdgeInsets.only(right: 20)
                                    : null,
                            child: Card(
                              elevation:
                                  _alternativCampaign?.id == campaigns[index].id
                                      ? 2
                                      : 0,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _alternativCampaign = campaigns[index];
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 8),
                                  child: Row(
                                    children: <Widget>[
                                      Avatar(campaigns[index].imgUrl.low),
                                      SizedBox(width: 10),
                                      Text(
                                        "${campaigns[index].name}",
                                        style: _theme.textTheme.title,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: campaigns.length,
                    )),
              ],
            );
          }),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: MaterialButton(
              minWidth: double.infinity,
              height: 50,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
              color: Colors.indigo,
              disabledColor: Colors.grey,
              onPressed: _amount != null && _alternativCampaign != null
                  ? _donate
                  : null,
              child: Text(
                "Spenden",
                style: _theme.accentTextTheme.button,
              ),
            ),
          ),
          SizedBox(
            height: 10 + MediaQuery.of(context).padding.bottom,
          ),
        ],
      ),
    );
  }

  _donate() async {
    Donation donation = Donation(
      _amount,
      campaignId: widget.campaign.id,
      alternativeCampaignId: widget.campaign.id,
      campaignImgUrl: widget.campaign.imgUrl.url,
      userId: widget.user.id,
      campaignName: widget.campaign.name,
    );

    await DatabaseService(widget.user.id).donate(donation);

    Scaffold.of(widget.context).showSnackBar(SnackBar(
        content: Text(
            "Du hast $_amount DC an ${widget.campaign.name} gespendet! Vielen Dank!")));

    widget.close();
  }
}
