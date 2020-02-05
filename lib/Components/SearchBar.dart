import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {

  Function(String) onChanged;

  SearchBar({Key key, this.onChanged}) : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      child: Material(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: TextField(
                decoration: InputDecoration.collapsed(
                  hintText: "Suchen",
                ),
                onChanged: onChanged,
              ),
            ),
          ),
          onTap: () {},
        ),
      ),
    );
  }
}
