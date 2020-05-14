import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';
import 'package:stripe_payment/stripe_payment.dart';

class CreditCardWidget extends StatelessWidget {
  CreditCard creditCard;
  VoidCallback onDelete;

  CreditCardWidget(this.creditCard, {this.onDelete, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 8 / 5,
      child: Material(
        color: ColorTheme.blue,
        elevation: 20,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    child: Material(
                      color: Colors.green,
                      shape: CircleBorder(),
                      child: Icon(
                        Icons.done,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    child: Material(
                      elevation: 10,
                      color: ColorTheme.red,
                      shape: CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: onDelete,
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "**** **** **** ${creditCard.last4}",
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              Expanded(child: Container()),
              Consumer<UserManager>(builder: (context, um, child) {
                return Row(
                  children: <Widget>[
                    _columnWidget(
                        title: "CARD HOLDER",
                        text: "${um.user.name}"),
                    Expanded(child: Container()),
                    Row(
                      children: <Widget>[
                        _columnWidget(
                            title: "EXPIRES",
                            text:
                                "${creditCard.expMonth}/${creditCard.expYear.toString().substring(2, 4)}"),
                        SizedBox(
                          width: 10,
                        ),
                        _columnWidget(title: "CVV", text: "XXX"),
                      ],
                    )
                  ],
                );
              })
            ],
          ),
        ),
      ),
    );
  }

  Widget _columnWidget({String title, String text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          text,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }
}
