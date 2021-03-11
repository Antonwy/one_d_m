import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:one_d_m/Components/SearchResultsList.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Constants.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Size _displaySize;

  String _query = "";

  @override
  Widget build(BuildContext context) {
    _displaySize = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: ColorTheme.appBg,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverSearchBar(
              onChanged: (text) {
                setState(() {
                  _query = text;
                });
              },
            ),
            SearchResultsList(_query)
          ],
        ));
  }
}

class SliverSearchBar extends StatelessWidget {
  final Function(String) onChanged;

  const SliverSearchBar({Key key, this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      backgroundColor: ColorTheme.appBg,
      iconTheme: IconThemeData(color: Colors.black),
      expandedHeight: 80,
      flexibleSpace: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 60,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Material(
              borderRadius: BorderRadius.circular(Constants.radius - 6),
              elevation: 1,
              color: ColorTheme.appBg,
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.only(right: 18.0),
                child: Row(
                  children: <Widget>[
                    BackButton(),
                    Expanded(
                      child: TextField(
                        onChanged: onChanged,
                        decoration:
                            InputDecoration.collapsed(hintText: "Suchen"),
                      ),
                    ),
                    Icon(Icons.search),
                  ],
                ),
              )),
            ),
          ),
        ),
      ),
    );
  }
}
