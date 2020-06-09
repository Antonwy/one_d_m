import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:one_d_m/Components/SearchResultsList.dart';

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
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
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
                      borderRadius: BorderRadius.circular(5),
                      elevation: 2,
                      color: Colors.white,
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.only(right: 18.0),
                        child: Row(
                          children: <Widget>[
                            BackButton(),
                            Expanded(
                              child: TextField(
                                onChanged: (text) {
                                  setState(() {
                                    _query = text;
                                  });
                                },
                                decoration: InputDecoration.collapsed(
                                    hintText: "Suchen"),
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
            ),
            SearchResultsList(_query)
          ],
        ));
  }
}
