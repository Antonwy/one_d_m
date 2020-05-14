import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';

class CategoriesList extends StatefulWidget {
  Function(int) onCategoryChanged;

  CategoriesList(this.onCategoryChanged);

  @override
  _CategoriesListState createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  int _selectedCategoryId = 4;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: Category.categories.length,
      separatorBuilder: (context, index) => SizedBox(
        width: 10,
      ),
      itemBuilder: (context, index) {
        Category cat = Category.categories[index];
        bool isSelected = cat.id == _selectedCategoryId;
        return Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(
                  left: index == 0 ? 18 : 0,
                  right: index == Category.categories.length - 1 ? 18 : 0),
              child: Center(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.fastLinearToSlowEaseIn,
                  width: isSelected ? 95 : 80,
                  height: isSelected ? 95 : 80,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Material(
                      borderRadius: BorderRadius.circular(18),
                      color: ColorTheme.lightBlue,
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: <Widget>[
                          LayoutBuilder(
                              builder: (context, constraints) => Center(
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 500),
                                      curve: Curves.fastLinearToSlowEaseIn,
                                      width: constraints.maxWidth *
                                          (isSelected ? .8 : 1.0),
                                      height: constraints.maxHeight *
                                          (isSelected ? .8 : 1.0),
                                      decoration: BoxDecoration(
                                          color: isSelected
                                              ? ColorTheme.red
                                              : ColorTheme.lightBlue,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          boxShadow: [
                                            BoxShadow(
                                                color: ColorTheme.red
                                                    .withOpacity(.8),
                                                blurRadius:
                                                    isSelected ? 14 : 0),
                                          ]),
                                    ),
                                  )),
                          Positioned.fill(
                              child: Center(
                                  child: AnimatedDefaultTextStyle(
                            duration: Duration(milliseconds: 250),
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected ? Colors.white : Colors.black),
                            child: Text(
                              cat.name,
                              textAlign: TextAlign.center,
                            ),
                          ))),
                          Positioned.fill(
                              child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedCategoryId = cat.id;
                                });
                                widget.onCategoryChanged(cat.id);
                              },
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ));
      },
    );
  }
}

class Category {
  String name;
  String assetUrl;
  int id;

  static List<Category> categories = [
    Category("Alle", "everything.jpg", 4),
    Category("Tiere", "animals.jpg", 0),
    Category("Umwelt", "earth.jpg", 1),
    Category("Menschen", "humans.jpg", 2),
  ];

  Category(this.name, String assetName, this.id) {
    this.assetUrl = "assets/images/$assetName";
  }
}
