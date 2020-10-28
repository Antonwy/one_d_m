import 'package:flutter/material.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Pages/FindFriendsPage.dart';

class CategoriesList extends StatefulWidget {
  Function(int) onCategoryChanged;

  CategoriesList(this.onCategoryChanged);

  @override
  _CategoriesListState createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  int _selectedCategoryId = 100;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: Category.categories.length + 1,
      separatorBuilder: (context, index) => SizedBox(
        width: 10,
      ),
      itemBuilder: (context, index) {
        Category cat = Category.categories[index == 0 ? index : index - 1];
        bool isSelected = cat.id == _selectedCategoryId;
        return Center(
          child: index == 0
              ? Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: CustomOpenContainer(
                    closedElevation: 0,
                    closedColor: ColorTheme.whiteBlue,
                    closedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    openBuilder: (context, close, scrollController) =>
                        FindFriendsPage(scrollController: scrollController),
                    closedBuilder: (context, open) => CategoryItem(
                      index: index,
                      onPressed: open,
                      category: null,
                      isSelected: false,
                      isAddFriendsButton: true,
                    ),
                  ),
                )
              : CategoryItem(
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
        );
      },
    );
  }
}

class CategoryItem extends StatelessWidget {
  final int index;
  final VoidCallback onPressed;
  final Category category;
  final bool isSelected, isAddFriendsButton;

  CategoryItem(
      {this.index,
      this.onPressed,
      this.category,
      this.isSelected,
      this.isAddFriendsButton = false});

  @override
  Widget build(BuildContext context) {
    BaseTheme _bTheme = ThemeManager.of(context).colors;
    return Padding(
      padding: EdgeInsets.only(
          right: index - 1 == Category.categories.length - 1 ? 10 : 0),
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
                            width:
                                constraints.maxWidth * (isSelected ? .8 : 1.0),
                            height:
                                constraints.maxHeight * (isSelected ? .8 : 1.0),
                            decoration: BoxDecoration(
                                color: isSelected
                                    ? _bTheme.contrast
                                    : ColorTheme.lightBlue,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                      color: _bTheme.contrast.withOpacity(.8),
                                      blurRadius: isSelected ? 14 : 0),
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
                          isSelected ? _bTheme.textOnContrast : _bTheme.dark),
                  child: isAddFriendsButton
                      ? Icon(Icons.person_add)
                      : Text(
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
  String assetUrl;
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
