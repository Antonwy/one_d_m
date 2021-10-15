import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/components/discovery_holder.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/helper/ad_manager.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:provider/provider.dart';

class PlayButton extends StatefulWidget {
  final double? size;
  final bool? showLabel;

  const PlayButton({
    Key? key,
    this.size,
    this.showLabel,
  }) : super(key: key);

  @override
  _PlayButtonState createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ThemeData _theme;
  late Animation<double> _curvedAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutSine,
    );

    _controller.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.completed:
          _controller.reverse();
          break;
        case AnimationStatus.dismissed:
          Future.delayed(Duration(seconds: 5)).then((val) {
            if (context.read<AdManagerNotifier>().done && mounted)
              _controller.forward();
          });
          break;
        default:
      }
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);
    AdManagerNotifier manager = context.watch<AdManagerNotifier>();
    return DiscoveryHolder.showAd(
        maxDVs: manager.maxDVs,
        tapTarget: _button(manager),
        next: () async {
          context.read<Future<void> Function(int)>()(1);
          return true;
        },
        child: ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 1.1).animate(_curvedAnimation),
          child: SlideTransition(
            position: Tween<Offset>(begin: Offset.zero, end: Offset(0, -.08))
                .animate(_curvedAnimation),
            child: Material(
              borderRadius: BorderRadius.circular(Constants.radius),
              clipBehavior: Clip.antiAlias,
              color: _theme.colorScheme.secondary,
              elevation: 8,
              child: InkWell(onTap: manager.showAd, child: _button(manager)),
            ),
          ),
        ));
  }

  Widget _button(AdManagerNotifier amn) => AspectRatio(
        aspectRatio: 1,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buttonIcon(amn),
              YMargin(4),
              _buttonText(amn),
            ],
          ),
        ),
      );

  Widget _buttonText(AdManagerNotifier amn) {
    String text = "DV einsammeln";
    if (amn.done)
      text = "${amn.maxDVs}DV gesammelt";
    else if (amn.loading) text = "Ad Laden...";

    return AutoSizeText(text,
        maxLines: 1,
        minFontSize: 4,
        style: TextStyle(fontSize: 6, color: _theme.colorScheme.onSecondary));
  }

  Widget _buttonIcon(AdManagerNotifier amn) {
    if (amn.done)
      return Icon(
        Icons.done_rounded,
        color: _theme.colorScheme.onSecondary,
      );

    if (amn.loading)
      return Container(
        width: 15,
        height: 15,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation(
            _theme.colorScheme.onSecondary,
          ),
        ),
      );

    return Icon(
      Icons.play_arrow_rounded,
      color: _theme.colorScheme.onSecondary,
    );
  }
}
