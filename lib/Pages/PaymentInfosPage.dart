import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:one_d_m/Components/CreditCardWidget.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';
import 'package:stripe_payment/stripe_payment.dart';

class PaymentInfosPage extends StatelessWidget {
  ThemeData _theme;
  final ScrollController scrollController;

  PaymentInfosPage({Key key, this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Bezahlmethode",
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
          backgroundColor: ColorTheme.blue,
          label: Text("Neue Karte"),
          icon: Icon(Icons.credit_card),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(18.0),
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
                return ListView.separated(
                  controller: scrollController,
                  itemCount: paymentMethods.length,
                  separatorBuilder: (context, index) => SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    CreditCard card = paymentMethods[index].card;
                    return CreditCardWidget(
                      card,
                      onDelete: () async {
                        bool shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
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
                                          style:
                                              TextStyle(color: ColorTheme.blue),
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
                    );
                  },
                );
              }),
        ),
      ),
    );
  }
}
