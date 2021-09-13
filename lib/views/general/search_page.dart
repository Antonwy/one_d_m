import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:one_d_m/components/search_results_list.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/views/home/profile_page.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _query = "";
  Timer _debounce;

  @override
  void initState() {
    super.initState();
    context
        .read<FirebaseAnalytics>()
        .setCurrentScreen(screenName: "Search Page");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorTheme.appBg,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverSearchBar(
              onChanged: (text) {
                if (_debounce?.isActive ?? false) _debounce.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  setState(() {
                    _query = text;
                  });
                });
              },
            ),
            SearchResultsList(_query)
          ],
        ));
  }
}

class SliverSearchBar extends StatefulWidget {
  final Function(String) onChanged;

  SliverSearchBar({Key key, this.onChanged}) : super(key: key);

  @override
  _SliverSearchBarState createState() => _SliverSearchBarState();
}

class _SliverSearchBarState extends State<SliverSearchBar> {
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      widget.onChanged(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: _theme.colors.textOnContrast),
      automaticallyImplyLeading: false,
      title: Column(
        children: [
          Container(
            width: double.infinity,
            height: 56,
            child: Material(
              color: ColorTheme.appBg,
              elevation: 1,
              borderRadius: BorderRadius.circular(Constants.radius),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0, right: 6),
                    child: AppBarButton(
                      icon: Icons.arrow_back,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                      child: TextField(
                    controller: _controller,
                    cursorColor: _theme.colors.dark,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: "Suchen"),
                    style:
                        _theme.textTheme.dark.bodyText1.copyWith(fontSize: 18),
                  )),
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: AppBarButton(
                      icon: _controller.text.isNotEmpty
                          ? Icons.close
                          : CupertinoIcons.search,
                      onPressed: _controller.text.isNotEmpty
                          ? () {
                              _controller.text = "";
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      toolbarHeight: 70,
    );
  }
}
