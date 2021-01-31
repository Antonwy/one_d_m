import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final String url;
  final bool play;
  final String imageUrl;

  const VideoWidget(
      {Key key, @required this.url, @required this.play, this.imageUrl})
      : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  bool _mute;

  @override
  void initState() {
    super.initState();
    _mute = true;
    _controller = VideoPlayerController.network(widget.url);
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      setState(() {});
    });

    if (widget.play) {
      _controller.play();
      _controller.setLooping(true);
      _controller.setVolume(0);
    }
  }

  @override
  void didUpdateWidget(VideoWidget oldWidget) {
    if (oldWidget.play != widget.play) {
      if (widget.play) {
        _controller.play();
        _controller.setLooping(true);
        _controller.setVolume(0);
      } else {
        _controller.pause();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: InkWell(
                  onTap: _handleMute,
                  child: VideoPlayer(_controller),
                ),
              ),
              Positioned(
                bottom: 5,
                left: 5,
                child: Icon(
                  _mute ? Icons.volume_off : Icons.volume_up,
                  color: ThemeManager.of(context).colors.light,
                ),
              )
            ],
          );
        } else {
          return Container(
            height: 260,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  void _handleMute() {
    setState(() {
      _mute = !_mute;
      _controller.setVolume(_mute ? 0 : 1);
    });
  }
}
