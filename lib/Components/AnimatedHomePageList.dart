import 'package:flutter/material.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:one_d_m/Components/DailyReportFeed.dart';
import 'package:one_d_m/Helper/Ranking.dart';

class AnimatedHomePageList extends StatelessWidget {
  final List<DonatedAmount> infos;
  final bool isUserList;

  AnimatedHomePageList(this.infos, {this.isUserList = true});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
          height: infos.length * (constraints.maxWidth * .3 + 10.0),
          width: constraints.maxWidth,
          child: ImplicitlyAnimatedList<RankingButton>(
              insertDuration: Duration(milliseconds: 300),
              removeDuration: Duration(milliseconds: 300),
              physics: NeverScrollableScrollPhysics(),
              items: _generateList(),
              itemBuilder: (context, animation, child, index) =>
                  SizeFadeTransition(
                    animation: animation,
                    child: child,
                  ),
              areItemsTheSame: (w1, w2) => w1 == w2)),
    );
  }

  List<Widget> _generateList() { 
    List<RankingButton> list = [];

    for (int i = 0; i < infos.length; i++) {
      list.add(RankingButton(
        info: infos[i],
        isUser: isUserList,
      ));
    }

    return list;
  }
}
