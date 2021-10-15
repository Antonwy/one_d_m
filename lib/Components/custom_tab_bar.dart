import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/helper.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/not_used/goal_page.dart';

class CustomTabBar extends StatefulWidget {
  final void Function(GoalPageTabs?) onTabChanged;
  final List<CustomTabInfo> tabs;

  const CustomTabBar({
    Key? key,
    required this.onTabChanged,
    required this.tabs,
  }) : super(key: key);

  @override
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  double _position = -1;
  late CustomTabInfo _currentTab;
  PageController? _pageController;
  late ValueNotifier<double?> _pageNotifier;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _pageNotifier = ValueNotifier(0.0);
    _pageController!.addListener(() {
      _pageNotifier.value = _pageController!.page;
    });
    _currentTab = widget.tabs[0];
  }

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Material(
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(Constants.radius),
      child: Container(
        height: 300,
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              children: widget.tabs
                  .map((tab) => Image.asset(
                        tab.assetPath!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ))
                  .toList(),
              onPageChanged: _changeContent,
            ),
            IgnorePointer(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: [
                      0.0,
                      .7,
                      1.0
                    ],
                        colors: [
                      _theme.colors!.contrast!,
                      _theme.colors!.contrast!.withOpacity(0),
                      _theme.colors!.contrast!.withOpacity(0)
                    ])),
              ),
            ),
            IgnorePointer(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 250),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  child: Padding(
                    key: ValueKey<String?>(_currentTab.title),
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AutoSizeText(
                          _currentTab.title!,
                          style: _theme.textTheme.textOnContrast!.headline5
                              .copyWith(fontWeight: FontWeight.w500),
                          maxLines: 1,
                        ),
                        Text(_currentTab.subtitle!,
                            style: _theme.textTheme.textOnContrast!
                                .withOpacity(.75)
                                .bodyText2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 50,
              child: Container(
                color: _theme.colors!.contrast!.withOpacity(.3),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 50,
                  child: Stack(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) =>
                            ValueListenableBuilder(
                                valueListenable: _pageNotifier,
                                builder: (context, dynamic val, child) => Align(
                                      alignment: Alignment(
                                          Helper.mapValue(val, 0,
                                              widget.tabs.length - 1, -1, 1)!,
                                          0),
                                      child: Container(
                                        height: double.infinity,
                                        width: constraints.maxWidth /
                                            widget.tabs.length,
                                        child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Material(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Constants.radius),
                                              clipBehavior: Clip.antiAlias,
                                              color: _theme.colors!.contrast,
                                            )),
                                      ),
                                    )),
                      ),
                      Row(
                          children: List.generate(widget.tabs.length, (index) {
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _changeContent(index);
                              _changePage(index);
                            },
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: Colors.transparent,
                              child: Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                  style: _position != (index - 1)
                                      ? _theme.textTheme.textOnContrast!
                                          .withOpacity(.7)
                                          .bodyText2
                                      : _theme
                                          .textTheme.textOnContrast!.bodyText1
                                          .copyWith(
                                              fontWeight: FontWeight.w600),
                                  child: Text(
                                    widget.tabs[index].name!,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      })),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _changeContent(int page) {
    setState(() {
      _position = (page - 1).toDouble();
      _currentTab = widget.tabs[page];
    });
    widget.onTabChanged(_currentTab.tab);
  }

  Future<void> _changePage(int page) {
    return _pageController!.animateToPage(page,
        duration: Duration(milliseconds: 250), curve: Curves.easeInOut);
  }
}
