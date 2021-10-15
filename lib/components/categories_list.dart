import 'package:flutter/material.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/helper/constants.dart';

class CategoriesList extends StatefulWidget {
  final Function(int) onCategoryChanged;
  final int? initialIndex;

  CategoriesList(this.onCategoryChanged, {this.initialIndex = 100});

  @override
  _CategoriesListState createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  int? _selectedCategoryId = 100;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialIndex;
  }

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
        return Center(
          child: Padding(
            padding: EdgeInsets.only(
                left: index == 0 ? 12.0 : 0.0,
                right: index == Category.categories.length - 1 ? 12.0 : 0),
            child: CategoryItem(
              index: index,
              onPressed: () {
                setState(() {
                  _selectedCategoryId = cat.id;
                });
                widget.onCategoryChanged(cat.id);
              },
              category: cat,
              isSelected: isSelected,
            ),
          ),
        );
      },
    );
  }
}

class CategoryItem extends StatelessWidget {
  final int index;
  final VoidCallback onPressed;
  final Category category;
  final bool isSelected;

  CategoryItem(
      {required this.index,
      required this.onPressed,
      required this.category,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(
          right: index - 1 == Category.categories.length - 1 ? 10 : 0),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 1000),
        curve: Curves.fastLinearToSlowEaseIn,
        width: isSelected ? 85 : 80,
        height: isSelected ? 85 : 80,
        child: AspectRatio(
          aspectRatio: 1,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 1000),
            curve: Curves.fastLinearToSlowEaseIn,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color:
                        _theme.primaryColor.withOpacity(isSelected ? .35 : 0),
                    blurRadius: 10)
              ],
              borderRadius: BorderRadius.circular(Constants.radius + 2),
              color: isSelected ? _theme.primaryColor : _theme.canvasColor,
            ),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                    child: Center(
                        child: AnimatedDefaultTextStyle(
                  duration: Duration(milliseconds: 250),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? _theme.colorScheme.onPrimary
                          : (context.theme.darkMode
                              ? Colors.white
                              : Colors.black)),
                  child: Text(
                    category.name,
                    textAlign: TextAlign.center,
                  ),
                ))),
                Positioned.fill(
                    child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onPressed,
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Category {
  String name;
  String? assetUrl;
  int id;

  static List<Category> categories = [
    Category("Alle", "everything.jpg", 100),
    Category("Tiere", "animals.jpg", 0),
    Category("Umwelt", "earth.jpg", 1),
    Category("Menschen", "humans.jpg", 2),
  ];

  Category(this.name, String assetName, this.id) {
    this.assetUrl = "assets/images/$assetName";
  }
}
