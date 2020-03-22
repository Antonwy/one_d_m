import 'package:flutter/material.dart';

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

  String _amount, _method;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250))
          ..addListener(() {
            setState(() {});
          });
    _controller.forward();
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
                    child: Text(
                      "Bezahlmethode",
                      style: _theme.textTheme.title,
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        List<String> values = [
                          "Visa",
                          "Mastercard",
                          "Apple Pay",
                        ];
                        List<String> icons = [
                          "assets/icons/visa.png",
                          "assets/icons/mastercard-logo.png",
                          "assets/icons/apple-pay.png",
                        ];
                        List<Color> colors = [
                          Colors.blue[100],
                          Colors.red[100],
                          Colors.grey[100],
                        ];
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
                              elevation: _method == values[index] ? 2 : 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _method = values[index];
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 8),
                                  child: Row(
                                    children: <Widget>[
                                      Material(
                                        color: colors[index],
                                        shape: CircleBorder(),
                                        child: Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Image.asset(
                                            icons[index],
                                            width: 25,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "${values[index]}",
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
                      itemCount: 3,
                    ),
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
