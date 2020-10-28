import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Components/CreditCardWidget.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/UserCharge.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';
import 'package:stripe_payment/stripe_payment.dart';

class PaymentInfosPage extends StatelessWidget {
  ThemeData _theme;
  BaseTheme _bTheme;
  final ScrollController scrollController;

  PaymentInfosPage({Key key, this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    _bTheme = ThemeManager.of(context).colors;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Zahlungen",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: Consumer<UserManager>(
        builder: (context, um, child) => FloatingActionButton.extended(
          onPressed: () async {
            PaymentMethod pm;
            try {
              pm = await StripePayment.paymentRequestWithCardForm(
                  CardFormPaymentRequest());
              DatabaseService.addCard(card: pm, uid: um.uid);
            } catch (e) {
              print(e);
            }
          },
          backgroundColor: _bTheme.dark,
          label: Text("Neue Karte"),
          icon: Icon(Icons.credit_card),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        child: Consumer<UserManager>(
          builder: (context, um, child) => StreamBuilder<List<PaymentMethod>>(
              stream: DatabaseService.getCards(um.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Container();
                List<PaymentMethod> paymentMethods = snapshot.data ?? [];
                if (paymentMethods.isEmpty)
                  return Center(
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 20,
                        ),
                        SvgPicture.asset(
                          "assets/images/no-cards.svg",
                          height: 200,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Du hast noch keine Bezahlmethode hinzugefügt!",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  );

                return CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                      CreditCard card = paymentMethods[index].card;
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                        child: CreditCardWidget(
                          card,
                          onDelete: () async {
                            bool shouldDelete = await showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      title: Text("Löschen"),
                                      content: Text(
                                          "Bist du dir sicher, dass du die Karte löschen willst?"),
                                      actions: <Widget>[
                                        FlatButton(
                                            onPressed: () {
                                              Navigator.pop(c, false);
                                            },
                                            child: Text(
                                              "Abbrechen",
                                              style: TextStyle(
                                                  color: ColorTheme.blue),
                                            )),
                                        FlatButton(
                                          onPressed: () {
                                            Navigator.pop(c, true);
                                          },
                                          child: Text(
                                            "Löschen",
                                            style: TextStyle(
                                              color: ColorTheme.orange,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ));
                            if (shouldDelete)
                              await DatabaseService.deleteCard(
                                  card: paymentMethods[index], uid: um.uid);
                          },
                        ),
                      );
                    }, childCount: paymentMethods.length)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Ausstehende Zahlungen:",
                              style: _theme.textTheme.headline6,
                            ),
                            Text(
                              "Deine spenden werden monatlich gesammelt und ab 5 DC abgebucht.",
                              style: _theme.textTheme.caption,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            FutureBuilder<UserCharge>(
                                future: DatabaseService.getUserCharge(um.uid),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting)
                                    return Row(
                                      children: [
                                        CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation(
                                              ColorTheme.blue),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Text("Laden..."),
                                      ],
                                    );

                                  if (!snapshot.hasData)
                                    return Text("Noch keine Zahlungen.");

                                  UserCharge charge = snapshot.data;

                                  if (charge.error)
                                    return Row(
                                      children: [
                                        Icon(
                                          Icons.warning,
                                          color: Colors.red,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Expanded(
                                          child: Text(
                                            "Beim Abbuchen von ${charge.amount} DC gab es ein Fehler.\nWir werden es nächsten Monat erneut versuchen. Bitte sorgen sie für eine ausreichende Deckung ihres Kontos.",
                                            style: _theme.textTheme.bodyText1
                                                .copyWith(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    );

                                  return Text(
                                    _chargeText(charge),
                                    style: _theme.textTheme.bodyText1,
                                  );
                                }),
                            SizedBox(
                              height: 100,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                );
              }),
        ),
      ),
    );
  }

  String _chargeText(UserCharge charge) {
    if (charge.amount > 0) {
      if (charge.amount < 5)
        return "${charge.amount} DC noch ${5 - charge.amount} DC spenden bis wir abbuchen.";
      return "${charge.amount} DC werden am Ende des Monats abgebucht.";
    }

    return "Keine ausstehenden Zahlungen.";
  }
}
