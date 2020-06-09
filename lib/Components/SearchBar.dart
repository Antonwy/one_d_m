import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/SearchPage.dart';

class SearchBar extends StatelessWidget {
  SearchBar({Key key}) : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      child: OpenContainer(
        openBuilder: (context, close) => SearchPage(),
        closedBuilder: (context, open) => InkWell(
          child: Align(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                "Suchen",
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
            alignment: Alignment.centerLeft,
          ),
          onTap: open,
        ),
      ),
    );
  }
}
