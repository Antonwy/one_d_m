import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
                _DropdownButton(),
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

                      if (checkpoints.isEmpty)
                        return Column(
                          children: <Widget>[
                            YMargin(
                              20,
                            ),
                            SvgPicture.asset(
                              "assets/images/no-news.svg",
                              height: MediaQuery.of(context).size.height * .25,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Noch keine Ziele vorhanden",
                              style: _theme.textTheme.dark.bodyText1,
                            ),
                          ],
                        );

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 50),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (GoalCheckpoint check in checkpoints)
                              Builder(
                                builder: (context) {
                                  bool _reached =
                                      gpm.goal.currentValue >= check.value;
                                  Color _color = _reached
                                      ? _theme.colors.dark
                                      : Colors.grey[300];
                                  Color _textColor = _reached
                                      ? _theme.colors.light
                                      : _theme.colors.dark.withOpacity(.7);
                                  return TimelineTile(
                                    alignment: TimelineAlign.start,
                                    isFirst: check.position ==
                                        TimelinePosition.first,
                                    isLast:
                                        check.position == TimelinePosition.last,
                                    indicatorStyle: IndicatorStyle(
                                        width: 18,
                                        color: _color,
                                        iconStyle: IconStyle(
                                            iconData: _reached
                                                ? Icons.done
                                                : Icons.close,
                                            color: _textColor)),
                                    beforeLineStyle: LineStyle(
                                      color: _color,
                                      thickness: 2,
                                    ),
                                    afterLineStyle: LineStyle(
                                      color: _color,
                                      thickness: 2,
                                    ),
                                    endChild: _TimelineContent(
                                      checkpoint: check,
                                      reached:
                                          gpm.goal.currentValue >= check.value,
                                      color: _color,
                                      textColor: _textColor,
                                    ),
                                  );
                                },
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
          text: TextSpan(style: _theme.textTheme.dark.bodyText2, children: [
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
          text: TextSpan(style: _theme.textTheme.dark.bodyText2, children: [
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
              text: TextSpan(style: _theme.textTheme.dark.bodyText2, children: [
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

class _DropdownButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Consumer<GoalPageManager>(
      builder: (context, gpm, child) => Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
          color: _theme.colors.contrast,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Goal>(
              value: gpm?.goal,
              onChanged: (val) => gpm.goal = val,
              style: _theme.textTheme.textOnContrast.headline6
                  .copyWith(fontSize: 18),
              dropdownColor: _theme.colors.contrast,
              iconEnabledColor: _theme.colors.textOnContrast,
              disabledHint: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 18,
                  height: 18,
                  child: gpm.error
                      ? Icon(
                          Icons.warning,
                          color: _theme.colors.textOnContrast,
                        )
                      : CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation(
                              _theme.colors.textOnContrast),
                        ),
                ),
              ),
              items: gpm.goals
                  .map<DropdownMenuItem<Goal>>(
                      (value) => DropdownMenuItem<Goal>(
                            value: value,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Text(
                                value.name ?? value.id,
                                style: _theme.textTheme.textOnContrast.headline6
                                    .copyWith(fontSize: 18),
                              ),
                            ),
                          ))
                  .toList()),
        ),
      ),
    );
  }
}

class _TimelineContent extends StatelessWidget {
  final GoalCheckpoint checkpoint;
  final bool reached;
  final Color color, textColor;

  const _TimelineContent(
      {Key key,
      this.checkpoint,
      this.reached = false,
      this.color,
      this.textColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    BaseTextTheme _textTheme = _theme.textTheme.withColor(textColor);

    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<GoalPageManager>(
              builder: (context, gpm, child) => Text(
                "${checkpoint.value} ${gpm.goal?.unitSmiley ?? gpm.goal?.unit ?? gpm.goal?.name ?? "DV"}",
                style: _textTheme.headline6,
              ),
            ),
            if (checkpoint.pending != null && !reached)
              Text(
                checkpoint.pending,
                style: _textTheme.bodyText1,
              ),
            if (checkpoint.done != null && reached)
              Text(
                checkpoint.done,
                style: _textTheme.bodyText1,
              ),
          ],
        ),
      ),
    );
  }
}
