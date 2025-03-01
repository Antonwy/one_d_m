import 'dart:ui';
import 'package:flutter/material.dart';

import 'categories_list.dart';

class CategoryDialog {
  final BuildContext context;
  final int? initialIndex;

  CategoryDialog(this.context, this.initialIndex);

  factory CategoryDialog.of(BuildContext context, {int? initialIndex = 100}) =>
      CategoryDialog(context, initialIndex);

  Future<int?> show() {
    return Navigator.of(context)
        .push<int>(_CategoryDialogRoute<int>(initialIndex));
  }
}

class _CategoryDialogRoute<T> extends PageRouteBuilder<T> {
  _CategoryDialogRoute(int? initIndex)
      : super(
          transitionDuration: Duration(milliseconds: 250),
          opaque: false,
          pageBuilder: (context, animation, secondAnim) =>
              _CategoryDialogWidget(initIndex),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            Animation curvedAnim =
                CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn);
            return Container(
              color: ColorTween(
                      begin: Colors.black.withOpacity(0.0),
                      end: Colors.black.withOpacity(.38))
                  .animate(curvedAnim as Animation<double>)
                  .value,
              child: SlideTransition(
                  position:
                      Tween<Offset>(begin: Offset(0, -.25), end: Offset.zero)
                          .animate(curvedAnim),
                  child: FadeTransition(
                      opacity: Tween<double>(begin: 0.0, end: 1.0)
                          .animate(curvedAnim),
                      child: ScaleTransition(
                          scale: Tween<double>(begin: 0.5, end: 1.0)
                              .animate(curvedAnim),
                          child: child))),
            );
          },
        );
}

// ignore: must_be_immutable
class _CategoryDialogWidget extends StatelessWidget {
  int? _categoryIndex;
  final int? _initCategory;

  _CategoryDialogWidget(this._categoryIndex) : _initCategory = _categoryIndex;

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop<int>(context, _initCategory);
          },
          child: Container(
            color: Colors.transparent,
          ),
        ),
        Positioned(
          top: 50,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Wähle Kategorie",
                            style: _theme.textTheme.bodyText1,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop<int>(context, _categoryIndex);
                            },
                            child: Text(
                              "FILTERN",
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        height: 120,
                        child: CategoriesList(
                            (index) => {_categoryIndex = index},
                            initialIndex: _categoryIndex)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
