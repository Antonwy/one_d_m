import 'dart:io';

import 'package:download_assets/download_assets.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Flare controls with a default animation to play on initialization.
class SimpleControls extends FlareControls {
  final String? defaultAnimation;

  SimpleControls(this.defaultAnimation);

  @override
  void initialize(FlutterActorArtboard artboard) {
    super.initialize(artboard);
    if (defaultAnimation != null) {
      play(defaultAnimation!);
    }
  }
}

/// A Flare widget that loads a file from the network. This could be easily
/// extended to also load the file from an AssetBundle, but the point is to show
/// how to easily comopose Flare widgets using existing Flutter functionality.
class Flare extends StatefulWidget {
  final String? filename;
  final String? campaignId;
  final String? animation;
  final BoxFit fit;
  final Alignment alignment;

  const Flare(
      {Key? key,
      this.filename,
      this.animation,
      this.fit = BoxFit.contain,
      this.alignment = Alignment.center,
      this.campaignId})
      : super(key: key);

  @override
  _FlareState createState() => _FlareState();
}

class _FlareState extends State<Flare> {
  SimpleControls? _controls;
  File? _flareFile;
  bool _downloaded = false;


  @override
  void initState() {
    super.initState();
    _controls = SimpleControls(widget.animation);
    DownloadAssetsController.init().then((value) => _downloadAssets());
  }

  @override
  void didUpdateWidget(Flare oldWidget) {
    if (oldWidget.animation != widget.animation) {
      // Simple way to change animation when the widget animation changes
      // Could also mix it by calling .play on the existing controls,
      // or provide your own controller. This is an example, implement as
      // you need!
      setState(() {
        _controls = SimpleControls(widget.animation);
      });
    }
    super.didUpdateWidget(oldWidget);
  }


  Future _downloadAssets() async {
    try {
      await DownloadAssetsController.startDownload(
          assetsUrl: widget.filename!,
          onProgress: (progressValue) {
            _downloaded = false;
            // print('${progressValue}');
          },
          onComplete: () {
            setState(() {
              _downloaded = true;
            });
            // print('completed');
          },
          onError: (exception) {
            setState(() {
              _downloaded = false;
            });
            // print('error${exception.toString()}');
          });
    } on DownloadAssetsException catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return !_downloaded
        ? SizedBox.shrink()
        : FlareActor(
            '${DownloadAssetsController.assetsDir}/campaign_${widget.campaignId}_anim.flr',
            animation: widget.animation,
            fit: widget.fit,
            antialias: true,
            snapToEnd: false,
          );

  }
}
