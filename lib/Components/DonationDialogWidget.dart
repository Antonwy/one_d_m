import 'package:flutter/material.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/CampaignsManager.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Pages/PaymentInfosPage.dart';
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

  bool _showThankYou = false, _loading = false;
  int _amount;
  Campaign _alternativCampaign;

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);

    return Material(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        child: Consumer<UserManager>(builder: (context, um, child) {
          return StreamBuilder<bool>(
              initialData: true,
              stream: DatabaseService.hasPaymentMethod(um.uid),
              builder: (context, snapshot) {
                if (!snapshot.data)
                  return Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          "Bitte füge eine Bezalmethode hinzu!",
                          style: _theme.textTheme.title,
                        ),
                        Text(
                          "Bevor du etwas spenden kannst, brauchen wir deine Zahlungsdaten!",
                          style: _theme.textTheme.body1,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        OutlineButton.icon(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) => PaymentInfosPage()));
                          },
                          label: Text("Hinzufügen"),
                          icon: Icon(Icons.add),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom,
                        )
                      ],
                    ),
                  );

                return Stack(
                  children: <Widget>[
                    Column(
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
                                    "Wieviele Donation Credits?",
                                    style: _theme.textTheme.title,
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    "Wieviele DC willst du spenden?",
                                    style: _theme.textTheme.body1
                                        .copyWith(color: Colors.black54),
                                  ),
                                ],
                              ),
                              _closeButton()
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
                                      : index == 5
                                          ? EdgeInsets.only(right: 20)
                                          : null,
                                  child: Card(
                                    clipBehavior: Clip.antiAlias,
                                    elevation: _amount == values[index] ? 2 : 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Material(
                                              color: Colors.indigo[100],
                                              shape: CircleBorder(),
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                  "\$",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.indigo),
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
                        Consumer<CampaignsManager>(
                            builder: (context, cm, child) {
                          List<Campaign> possibleCampaigns =
                              List.from(cm.getSubscribedCampaigns(um.user));
                          possibleCampaigns
                              .removeWhere((c) => c.id == widget.campaign.id);
                          List<Campaign> campaigns = List.from(
                              possibleCampaigns.isNotEmpty
                                  ? cm.getSubscribedCampaigns(um.user)
                                  : cm.getAllCampaigns());

                          campaigns
                              .removeWhere((c) => c.id == widget.campaign.id);

                          if (_alternativCampaign == null)
                            _alternativCampaign = campaigns[0];

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
                                                _alternativCampaign?.id ==
                                                        campaigns[index].id
                                                    ? 2
                                                    : 0,
                                            clipBehavior: Clip.antiAlias,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _alternativCampaign =
                                                      campaigns[index];
                                                });
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15.0,
                                                        vertical: 8),
                                                child: Row(
                                                  children: <Widget>[
                                                    Avatar(campaigns[index]
                                                            .thumbnailUrl ??
                                                        campaigns[index]
                                                            .imgUrl),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      "${campaigns[index].name}",
                                                      style: _theme
                                                          .textTheme.title,
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
                            onPressed:
                                _amount != null && _alternativCampaign != null
                                    ? _donate
                                    : null,
                            child: _loading
                                ? Center(
                                    child: CircularProgressIndicator(
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : Text(
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
                    Positioned.fill(
                        child: IgnorePointer(
                      ignoring: !_showThankYou,
                      child: AnimatedOpacity(
                        opacity: _showThankYou ? 1 : 0,
                        duration: Duration(milliseconds: 250),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                "assets/images/thank-you.png",
                                width: 300,
                              ),
                              Text(
                                "Vielen dank für deine Spende!",
                                style: _theme.textTheme.title,
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).padding.bottom,
                              )
                            ],
                          ),
                        ),
                      ),
                    )),
                    Positioned(top: 20, right: 20, child: _closeButton())
                  ],
                );
              });
        }));
  }

  Widget _closeButton() {
    return Container(
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
    );
  }

  _donate() async {
    Donation donation = Donation(
      _amount,
      campaignId: widget.campaign.id,
      alternativeCampaignId: widget.campaign.id,
      campaignImgUrl: widget.campaign.imgUrl,
      userId: widget.user.id,
      campaignName: widget.campaign.name,
    );

    setState(() {
      _loading = true;
    });

    await DatabaseService.donate(donation);

    setState(() {
      _loading = false;
      _showThankYou = true;
    });

    // widget.close();
  }
}
