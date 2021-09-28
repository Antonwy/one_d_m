import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/components/warning_icon.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final String url, imageUrl, blurHash;
  final bool play, muted;
  final ImageProvider image;
  final void Function() toggleMuted;
  final void Function() onVideoLoaded, onVideoLoadingError;
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
      this.blurHash,
      this.onVideoLoaded,
      this.onVideoLoadingError})
      : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  VideoPlayerController _controller;
  ChewieController _chewieController;
  Future<void> _initializeVideoPlayerFuture;
  bool _muted;
  bool _isVideoLoaded = false, _errorLoading = false;

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
            if (widget.play) {
              _controller.play();
              _controller.setLooping(true);
              _controller.setVolume(_muted ? 0 : 1);
            }
          }).catchError((e) {
            print("CATCHED ERROR: $e");
            _errorLoading = true;
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(VideoWidget oldWidget) {
    if (_controller?.value?.isInitialized == true) {
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
          if (widget?.onVideoLoaded != null && !_errorLoading)
            widget?.onVideoLoaded();
          if (_errorLoading && widget?.onVideoLoadingError != null)
            widget?.onVideoLoadingError();

          if (_errorLoading) return _VideoError();

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
                child: LoadingIndicator(),
              ),
      );

    return Container(
      height: 64,
      width: 64,
      color: ColorTheme.appBg,
      child: Center(
        child: LoadingIndicator(),
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

class _VideoError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          WarningIcon(),
          YMargin(12),
          Text(
            "Video konnte nicht geladen werden!",
            style: ThemeManager.of(context).textTheme.dark.bodyText2,
          )
        ],
      ),
    );
  }
}

class MuteButton extends StatelessWidget {
  final bool muted, loading, error, hide;
  final void Function() toggle;

  MuteButton(
      {Key key,
      this.muted,
      this.toggle,
      this.loading = false,
      this.error = false,
      this.hide = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 250),
      opacity: opacity(),
      child: Material(
        clipBehavior: Clip.antiAlias,
        shape: error
            ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))
            : CircleBorder(),
        color: ThemeManager.of(context).colors.dark.withOpacity(.8),
        child: InkWell(
          onTap: toggle,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: buildChild(context),
          ),
        ),
      ),
    );
  }

  double opacity() {
    if (loading) return 1;
    if (error) return 1;

    return hide ? 0 : 1;
  }

  Widget buildChild(BuildContext context) {
    if (error)
      return Row(
        children: [
          Icon(
            Icons.warning,
            color: Colors.white,
            size: 14,
          ),
          XMargin(6),
          Text("Video konnte nicht geladen werden!",
              style: ThemeManager.of(context)
                  .textTheme
                  .textOnDark
                  .caption
                  .copyWith(color: Colors.white))
        ],
      );

    if (loading)
      return LoadingIndicator(
        color: Colors.white,
        size: 10,
        strokeWidth: 1.5,
      );

    IconData data = Icons.volume_off;

    if (!muted) data = Icons.volume_up;

    return Icon(
      data,
      color: Colors.white,
      size: 14,
    );
  }
}
