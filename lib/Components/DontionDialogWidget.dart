import 'dart:async';

import 'package:flutter/material.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';

class DonationDialogWidget extends StatefulWidget {
  Function close;

  DonationDialogWidget(this.close);

  @override
  _DonationDialogWidgetState createState() => _DonationDialogWidgetState();
}

class _DonationDialogWidgetState extends State<DonationDialogWidget>
    with SingleTickerProviderStateMixin {
  Size _displaySize;
  AnimationController _controller;
  ThemeData _theme;
  UserManager um;
  Future<List<Campaign>> _alternativeFuture =
      Completer<List<Campaign>>().future;

  String _amount, _method;
  bool _hasAlternative = true;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250))
          ..addListener(() {
            setState(() {});
          });
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((d) {
      _alternativeFuture = DatabaseService(um.uid).getSubscribedCampaigns();
      _alternativeFuture.then((list) {
        if(list.isEmpty) {
          _alternativeFuture = DatabaseService().getCampaignFromQuery("");
          setState(() {
            _hasAlternative = false;
          });
        }
      });

    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _displaySize = MediaQuery.of(context).size;
    _theme = Theme.of(context);
    um = Provider.of<UserManager>(context);

    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: _closeDialog,
          child: Container(
              height: _displaySize.height,
              width: _displaySize.width,
              color: ColorTween(
                      begin: Colors.black.withOpacity(0),
                      end: Colors.black.withOpacity(.4))
                  .animate(_controller)
                  .value),
        ),
        Positioned(
          bottom: Tween<double>(begin: -_displaySize.height * .65, end: 0)
              .animate(CurvedAnimation(
                  parent: _controller,
                  curve: Curves.fastLinearToSlowEaseIn,
                  reverseCurve: Curves.fastOutSlowIn))
              .value,
          child: Container(
            width: _displaySize.width,
            height: _displaySize.height * .65,
            child: Material(
              borderRadius: BorderRadius.only( 
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        Material(
                          clipBehavior: Clip.antiAlias,
                          color: Colors.grey[200],
                          shape: CircleBorder(),
                          child: InkWell(
                            onTap: _closeDialog,
                            child: Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Icon(Icons.close),
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
                        List<String> values = [
                          "1.00",
                          "2.00",
                          "5.00",
                          "10.00",
                          "15.00",
                          "20.00"
                        ];
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
                                        "\$${values[index]}",
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
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Alternatives Projekt",
                          style: _theme.textTheme.title,
                        ),
                        Text(
                          "Aus ${_hasAlternative ? "deinen abonnierten" : "beliebten"} Projekten.",
                          style: _theme.textTheme.body1,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    child: FutureBuilder<List<Campaign>>(
                        future: _alternativeFuture,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Center(
                                  child: Container(
                                    height: 80,
                                    margin: index == 0
                                        ? EdgeInsets.only(left: 20)
                                        : index == 5
                                            ? EdgeInsets.only(right: 20)
                                            : null,
                                    child: Card(
                                      clipBehavior: Clip.antiAlias,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: InkWell(
                                        onTap: () {},
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15.0, vertical: 8),
                                          child: Row(
                                            children: <Widget>[
                                              Avatar(
                                                  snapshot.data[index].imgUrl),
                                              SizedBox(width: 10),
                                              Text(
                                                "${snapshot.data[index].name}",
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
                              itemCount: snapshot.data.length,
                            );
                          }
                          return Container();
                        }),
                  ),
                  Expanded(
                    child: Container(),
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
                      onPressed: _closeDialog,
                      child: Text(
                        "Spenden",
                        style: _theme.accentTextTheme.button,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  _closeDialog() {
    _controller.reverse().whenComplete(() {
      widget.close();
    });
  }
}
