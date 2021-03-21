import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/GoalPageManager.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';

class GoalPage extends StatefulWidget {
  @override
  _GoalPageState createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage>
    with AutomaticKeepAliveClientMixin {
  ThemeManager _theme;

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return Scaffold(
      backgroundColor: ColorTheme.appBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Row(
              children: [
                Text("Roadmap", style: TextStyle(color: _theme.colors.dark)),
                XMargin(6),
                Consumer<GoalPageManager>(
                  builder: (context, gpm, child) => Material(
                    color: _theme.colors.dark,
                    child: DropdownButton<Goal>(
                        value: gpm?.goal,
                        underline: SizedBox.shrink(),
                        onChanged: (val) => gpm.goal = val,
                        style: _theme.textTheme.textOnDark.headline6
                            .copyWith(fontSize: 18),
                        dropdownColor: _theme.colors.dark,
                        iconEnabledColor: _theme.colors.textOnDark,
                        disabledHint: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 18,
                            height: 18,
                            child: gpm.error
                                ? Icon(
                                    Icons.warning,
                                    color: _theme.colors.textOnDark,
                                  )
                                : CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation(
                                        _theme.colors.textOnDark),
                                  ),
                          ),
                        ),
                        items: gpm.goals
                            .map<DropdownMenuItem<Goal>>((value) =>
                                DropdownMenuItem<Goal>(
                                  value: value,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: Text(
                                      value.name ?? value.id,
                                      style: _theme
                                          .textTheme.textOnDark.headline6
                                          .copyWith(fontSize: 18),
                                    ),
                                  ),
                                ))
                            .toList()),
                  ),
                ),
                XMargin(6),
                Text(":", style: TextStyle(color: _theme.colors.dark)),
              ],
            ),
            centerTitle: false,
            backgroundColor: ColorTheme.appBg,
          ),
          Consumer<GoalPageManager>(
              builder: (context, gpm, child) => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: _buildGoalDescription(gpm?.goal),
                    ),
                  )),
          SliverFillRemaining(
            child: Consumer<GoalPageManager>(
              builder: (context, gpm, child) {
                return StreamBuilder<List<GoalCheckpoint>>(
                    stream: gpm.goal?.checkpoints,
                    builder: (context, snapshot) {
                      List<GoalCheckpoint> checkpoints = snapshot.data ?? [];
                      if (checkpoints.isNotEmpty) {
                        checkpoints.first.position = TimelinePosition.first;
                        checkpoints.last.position = TimelinePosition.last;
                      }

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 50),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (GoalCheckpoint check in checkpoints)
                              TimelineTile(
                                alignment: TimelineAlign.start,
                                isFirst:
                                    check.position == TimelinePosition.first,
                                isLast: check.position == TimelinePosition.last,
                                indicatorStyle: IndicatorStyle(
                                    width: 18,
                                    color: gpm.goal.currentValue < check.value
                                        ? _theme.colors.contrast
                                        : _theme.colors.dark,
                                    iconStyle: IconStyle(
                                        iconData:
                                            gpm.goal.currentValue < check.value
                                                ? Icons.close
                                                : Icons.done,
                                        color: _theme.colors.textOnDark)),
                                beforeLineStyle: LineStyle(
                                  color: gpm.goal.currentValue < check.value
                                      ? _theme.colors.contrast
                                      : _theme.colors.dark,
                                  thickness: 2,
                                ),
                                afterLineStyle: LineStyle(
                                  color: gpm.goal.currentValue < check.value
                                      ? _theme.colors.contrast
                                      : _theme.colors.dark,
                                  thickness: 2,
                                ),
                                endChild: _TimelineContent(
                                  checkpoint: check,
                                  reached: gpm.goal.currentValue >= check.value,
                                ),
                              ),
                          ],
                        ),
                      );
                    });
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGoalDescription(Goal goal) {
    if (goal == null) return SizedBox.shrink();

    if (goal.description?.isEmpty ?? true)
      return RichText(
          text: TextSpan(
              style: _theme.textTheme.textOnContrast.bodyText2,
              children: [
            TextSpan(
              text: "Wir haben bis jetzt ",
            ),
            TextSpan(
                text: goal.currentValue.toString(),
                style: TextStyle(fontWeight: FontWeight.w800)),
            TextSpan(
              text: " ${goal.unit} gespendet.",
            ),
          ]));

    if (goal.description.contains("**")) {
      List<String> splitted = goal.description.split("**");
      return RichText(
          text: TextSpan(
              style: _theme.textTheme.textOnContrast.bodyText2,
              children: [
            TextSpan(
              text: splitted[0],
            ),
            TextSpan(
                text: "${goal.currentValue}",
                style: TextStyle(fontWeight: FontWeight.w800)),
            TextSpan(
              text: " ${goal.unit}${splitted.length >= 2 ? splitted[1] : ""}",
            ),
          ]));
    } else
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
              text: TextSpan(
                  style: _theme.textTheme.textOnContrast.bodyText2,
                  children: [
                TextSpan(
                  text: "Wir haben bis jetzt ",
                ),
                TextSpan(
                    text: goal.currentValue.toString(),
                    style: TextStyle(fontWeight: FontWeight.w800)),
                TextSpan(
                  text: " ${goal.unit} gespendet.",
                ),
              ])),
          Text("${goal.description}"),
        ],
      );
  }

  @override
  bool get wantKeepAlive => true;
}

class _TimelineContent extends StatelessWidget {
  final GoalCheckpoint checkpoint;
  final bool reached;

  const _TimelineContent({Key key, this.checkpoint, this.reached = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Card(
      color: ColorTheme.appBg,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<GoalPageManager>(
              builder: (context, gpm, child) => Text(
                "${checkpoint.value} ${gpm.goal?.unitSmiley ?? gpm.goal?.unit ?? gpm.goal?.name ?? "DV"}",
                style: _theme.textTheme.dark.headline6,
              ),
            ),
            if (checkpoint.pending != null && !reached)
              Text(
                checkpoint.pending,
                style: _theme.textTheme.dark.bodyText1,
              ),
            if (checkpoint.done != null && reached)
              Text(
                checkpoint.done,
                style: _theme.textTheme.dark.bodyText1,
              ),
          ],
        ),
      ),
    );
  }
}
