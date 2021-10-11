import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/components/donation_widget.dart';
import 'package:one_d_m/components/sessions/session_donation.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/numeral.dart';
import 'package:one_d_m/models/donation_unit.dart';
import 'package:one_d_m/provider/sessions_manager.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class SessionLastDonationsTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SessionManager sm = context.watch<BaseSessionManager>() as SessionManager;
    return SliverToBoxAdapter(
      child: Builder(builder: (context) {
        if (sm.loadingMoreInfo! ||
            (!sm.loadingMoreInfo! && sm.session!.donations.isEmpty))
          return SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Text(
            "Letzte Unterstützungen",
            style: Theme.of(context).textTheme.bodyText1,
          ),
        );
      }),
    );
  }
}

class SessionLastDonations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SessionManager sm = context.watch<BaseSessionManager>() as SessionManager;
    return Builder(builder: (context) {
      List<SessionDonation> donations =
          (sm.loadingMoreInfo! ? [] : sm.session?.donations)!;
      return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
        SessionDonation don = donations[index];
        DonationUnit unit = sm.session!.donationUnit;
        return ListTile(
          leading: RoundedAvatar(
            don.userImageUrl,
            color: sm.baseSession!.primaryColor,
            iconColor:
                context.theme.correctColorFor(sm.baseSession!.primaryColor!),
          ),
          title: AutoSizeText(
            "${don.username}",
            maxLines: 1,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: AutoSizeText(
            "(${timeago.format(don.createdAt!, locale: "de")})",
            maxLines: 1,
            style: context.theme.textTheme.caption,
          ),
          trailing: Text(showAmount(don.amount!, unit),
              style: TextStyle(fontWeight: FontWeight.bold)),
        );
      }, childCount: donations.length));
    });
  }

  String showAmount(int amount, DonationUnit unit) {
    int unitAmount = (amount / (unit.value ?? 1)).round();
    String? unitName = unit.name;

    if (unit.smiley != null)
      unitName = unit.smiley;
    else if (unit.name == null)
      unitName = "DV";
    else if (unitAmount == 1) unitName = unit.singular;

    return "${Numeral(unitAmount).value()} $unitName";
  }
}
