import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Components/SearchPage.dart';
import 'package:one_d_m/Helper/CategoryDialog.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Pages/FindFriendsPage.dart';

class SearchBar extends StatelessWidget {
  final int categoryIndex;
  final void Function(int) onCategoryChange;

  SearchBar({this.categoryIndex = 100, this.onCategoryChange});

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Container(
      width: double.infinity,
      height: 60,
      child: OpenContainer(
        openBuilder: (context, close) => SearchPage(),
        closedColor: ColorTheme.appBg,
        closedBuilder: (context, open) => InkWell(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Suchen",
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
                Row(
                  children: [
                    CustomOpenContainer(
                      closedShape: CircleBorder(),
                      closedElevation: 0,
                      openBuilder: (context, close, scrollController) =>
                          FindFriendsPage(scrollController: scrollController),
                      closedColor: ColorTheme.appBg,
                      closedBuilder: (context, open) => IconButton(
                        icon: Icon(Icons.person_add),
                        onPressed: open,
                        color: _theme.colors.dark,
                      ),
                    ),
                    IconButton(
                      icon: Stack(
                        overflow: Overflow.visible,
                        children: [
                          Center(child: Icon(Icons.filter_alt)),
                          categoryIndex != 100
                              ? Positioned(
                                  right: 0,
                                  top: -5,
                                  child: Material(
                                    shape: CircleBorder(),
                                    color: Colors.red,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        "1",
                                        style: _theme.textTheme.light.bodyText2
                                            .copyWith(fontSize: 10),
                                      ),
                                    ),
                                  ),
                                )
                              : Container()
                        ],
                      ),
                      onPressed: () async {
                        int resIndex = await CategoryDialog.of(context,
                                initialIndex: categoryIndex)
                            .show();
                        onCategoryChange(resIndex);
                      },
                      color: _theme.colors.dark,
                    ),
                  ],
                )
              ],
            ),
          ),
          onTap: open,
        ),
      ),
    );
  }
}
