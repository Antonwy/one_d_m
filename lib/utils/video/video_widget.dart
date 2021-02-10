import 'package:chewie/chewie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final String url;
  final bool play, muted;
  final String imageUrl;
  final ImageProvider image;
  final void Function() toggleMuted;

  const VideoWidget(
      {Key key,
      @required this.url,
      @required this.play,
      this.muted = true,
      this.toggleMuted,
      this.imageUrl,
      this.image})
      : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  VideoPlayerController _controller;
  ChewieController _chewieController;
  Future<void> _initializeVideoPlayerFuture;
  bool _muted;

  @override
  void initState() {
    super.initState();
    _muted = widget.muted;
    _controller = VideoPlayerController.network(widget.url);
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      _chewieController = ChewieController(
        videoPlayerController: _controller,
        autoInitialize: true,
        showControls: false,
      );
      setState(() {});
    });

    if (widget.play) {
      _controller.play();
      _controller.setLooping(true);
      _controller.setVolume(_muted ? 0 : 1);
    }
  }

  @override
  void didUpdateWidget(VideoWidget oldWidget) {
    if (oldWidget.play != widget.play) {
      if (widget.play) {
        _controller.play();
        _controller.setLooping(true);
        _controller.setVolume(_muted ? 0 : 1);
      } else {
        _controller.pause();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _muted = widget.muted;
    _controller.setVolume(_muted ? 0 : 1);
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio < 1
                ? 0.8
                : _controller.value.aspectRatio,
            child: GestureDetector(
                onTap: widget?.toggleMuted,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: Chewie(
                    controller: _chewieController,
                  ),
                )),
          );
        } else {
          return Container(
            height: 260,
            width: double.infinity,
            child: _buildImage(),
          );
        }
      },
    );
  }

  Widget _buildImage() {
    if (widget.image != null)
      return Image(
        image: widget.image,
        fit: BoxFit.cover,
      );

    if (widget.imageUrl != null && widget.imageUrl.isNotEmpty)
      return CachedNetworkImage(
        imageUrl: widget.imageUrl,
        fit: BoxFit.cover,
      );

    return CircularProgressIndicator(
        valueColor:
            AlwaysStoppedAnimation(ThemeManager.of(context).colors.dark));
  }
}

class MuteButton extends StatelessWidget {
  final bool muted;
  final void Function() toggle;

  const MuteButton({Key key, this.muted, this.toggle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      shape: CircleBorder(),
      color: ThemeManager.of(context).colors.dark.withOpacity(.8),
      child: InkWell(
        onTap: toggle,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(
            muted ? Icons.volume_off : Icons.volume_up,
            color: Colors.white,
            size: 14,
          ),
        ),
      ),
    );
  }
}
