import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const kPricePerCoin = 0.1;

class BuyCoinsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        textTheme: theme.textTheme,
        iconTheme: theme.iconTheme,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          "Coins kaufen",
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 10.0),
        itemBuilder: (BuildContext context, int index) {
          return Row(
            children: <Widget>[
              Expanded(child: _BuyOptionWidget(option: _BuyOption.all[index * 2 + 0])),
              (index * 2 + 1 >= _BuyOption.all.length)
                  ? Expanded(child: Container())
                  : Expanded(child: _BuyOptionWidget(option: _BuyOption.all[index * 2 + 1])),
            ],
          );
        },
        itemCount: (_BuyOption.all.length / 2).ceil(),
      ),
    );
  }
}

class _BuyOption {
  const _BuyOption({
    @required this.coins,
    @required this.price,
  })  : assert(coins != null),
        assert(price != null);

  const _BuyOption.fromCoins(this.coins) : price = kPricePerCoin * coins;

  static final all = [1, 5, 10, 15, 20, 25].map((amount) => _BuyOption.fromCoins(amount)).toList();

  final int coins;
  final double price;
}

class _BuyOptionWidget extends StatelessWidget {
  const _BuyOptionWidget({
    @required this.option,
    this.onTap,
  }) : assert(option != null);

  final _BuyOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1 / 1,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary,
                ),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/icons/coins-white.png', width: 35),
                    SizedBox(width: 10.0),
                    Text(option.coins.toString(), style: TextStyle(color: Colors.white, fontSize: 50)),
                  ]
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Text(option.price.toStringAsFixed(2) + '€', style: TextStyle(fontSize: 22)),
          ],
        ),
      ),
    );
  }
}
