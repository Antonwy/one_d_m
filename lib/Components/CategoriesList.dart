import 'package:flutter/material.dart';

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
              child: Material(
                elevation: isSelected ? 8 : 0,
                borderRadius: BorderRadius.circular(10),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: <Widget>[
                    Image.asset(
                      cat.assetUrl,
                      fit: BoxFit.cover,
                      width: 180,
                      height: 100,
                    ),
                    Positioned.fill(
                        child: Container(
                      color: Colors.black38,
                    )),
                    Positioned.fill(
                        child: Center(
                            child: Text(
                      cat.name,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
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
                    AnimatedPositioned(
                        duration: Duration(milliseconds: 125),
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: isSelected ? 7 : 0,
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ))
                  ],
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
    Category("Alle Kategorien", "everything.jpg", 4),
    Category("Tiere", "animals.jpg", 0),
    Category("Umwelt", "earth.jpg", 1),
    Category("Menschen", "humans.jpg", 2),
  ];

  Category(this.name, String assetName, this.id) {
    this.assetUrl = "assets/images/$assetName";
  }
}
