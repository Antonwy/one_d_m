import 'package:flutter/material.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Components/BottomDialog.dart';
import 'package:one_d_m/Components/CampaignButton.dart';
import 'package:one_d_m/Components/UserButton.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Donation.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:timeago/timeago.dart' as timeago;

class DonationWidget extends StatelessWidget {
  Donation donation;
  bool withCampaignName;
  TextTheme _textTheme;
  Future _future;
  MediaQueryData _mq;

  DonationWidget(this.donation, {this.withCampaignName = false});

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    _mq = MediaQuery.of(context);
    if (_future == null)
      _future = DatabaseService().getUserFromId(donation.userId);

    return FutureBuilder<User>(
      future: _future,
      builder: (context, snapshot) {
        User user = snapshot.data;
        return Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
          child: ListTile(
            leading: Avatar(user?.imgUrl),
            title: snapshot.hasData
                ? RichText(
                    text: TextSpan(style: _textTheme.body1, children: [
                    TextSpan(
                        text: "${user.firstname} ${user.lastname}",
                        style: _textTheme.body1
                            .copyWith(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: " hat",
                    ),
                    TextSpan(
                        text: " ${donation.amount} DC",
                        style: _textTheme.body1
                            .copyWith(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: " an",
                    ),
                    TextSpan(
                        text: " ${donation.campaignName}",
                        style: _textTheme.body1
                            .copyWith(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: " gespendet!",
                    ),
                  ]))
                : Text("Laden"),
            subtitle: Text(timeago.format(donation.createdAt)),
            onTap: () {
              BottomDialog(context, duration: Duration(milliseconds: 125))
                  .show(Container(
                margin: EdgeInsets.symmetric(
                    vertical: _mq.padding.bottom == 0 ? 10 : _mq.padding.bottom,
                    horizontal: 10),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CampaignButton(donation.campaignId),
                        UserButton(
                          user.id,
                          user: user,
                        )
                      ],
                    ),
                  ),
                ),
              ));
            },
          ),
        );
      },
    );
  }
}
