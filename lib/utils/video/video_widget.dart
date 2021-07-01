import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final String url, imageUrl, blurHash;
  final bool play, muted;
  final ImageProvider image;
  final void Function() toggleMuted;
  final double height;

  const VideoWidget(
      {Key key,
      @required this.url,
      @required this.play,
      this.muted = true,
      this.toggleMuted,
      this.imageUrl,
      this.image,
      this.height,
      this.blurHash})
      : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  VideoPlayerController _controller;
  ChewieController _chewieController;
  Future<void> _initializeVideoPlayerFuture;
  bool _muted;
  bool _isVideoLoaded = false;

  @override
  void initState() {
    super.initState();
    _muted = widget.muted;

    if (!_isVideoLoaded) {
      setState(() => _isVideoLoaded = true);
      _downloadAndCacheVideo().then((file) {
        if (file != null) {
          _controller = VideoPlayerController.file(file,
              videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
          _initializeVideoPlayerFuture = _controller.initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {});
            if (widget.play) {
              _controller.play();
              _controller.setLooping(true);
              _controller.setVolume(_muted ? 0 : 1);
            }
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(VideoWidget oldWidget) {
    if (_controller?.value?.initialized == true) {
      if (oldWidget.play != widget.play) {
        if (widget.play) {
          _controller.play();
          _controller.setLooping(true);
          _controller.setVolume(_muted ? 0 : 1);
        } else {
          _controller.pause();
        }
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _muted = widget.muted;
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          _controller.setVolume(_muted ? 0 : 1);
          _chewieController = ChewieController(
              videoPlayerController: _controller,
              autoInitialize: true,
              showControls: false,
              looping: true,
              placeholder: Text("placeholder"),
              errorBuilder: (context, txt) {
                print("ERROR: $txt");
                return Text(txt);
              });

          return Container(
            height: widget.height ?? 260,
            width: double.infinity,
            child: GestureDetector(
                onTap: widget?.toggleMuted,
                child: FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    width: _controller.value.aspectRatio,
                    height: 1,
                    child: Chewie(
                      controller: _chewieController,
                    ),
                  ),
                )),
          );
        } else {
          return Container(
            height: widget.height ?? 260,
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
        placeholder: (context, url) => widget.blurHash != null
            ? BlurHash(hash: widget.blurHash)
            : Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(
                      ThemeManager.of(context).colors.dark),
                ),
              ),
      );

    return Container(
      height: 64,
      width: 64,
      color: ColorTheme.appBg,
      child: Center(
        child: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation(ThemeManager.of(context).colors.dark),
        ),
      ),
    );
  }

  Future<File> _downloadAndCacheVideo() async {
    try {
      final cacheManager = DefaultCacheManager();

      FileInfo fileInfo;

      fileInfo = await cacheManager
          .getFileFromCache(widget.url); // Get video from cache first

      if (fileInfo?.file == null) {
        fileInfo = await cacheManager
            .downloadFile(widget.url); // Download video if not cached yet
      }

      return fileInfo?.file;
    } catch (e) {
      throw (e);
    }
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
