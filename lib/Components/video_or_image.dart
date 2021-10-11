import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/components/warning_icon.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/utils/video/video_widget.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoOrImage extends StatefulWidget {
  final String? imageUrl, videoUrl, blurHash;
  final bool alwaysMuted;

  const VideoOrImage(
      {Key? key,
      this.imageUrl,
      this.videoUrl,
      this.blurHash,
      this.alwaysMuted = false})
      : super(key: key);

  @override
  _VideoOrImageState createState() => _VideoOrImageState();
}

class _VideoOrImageState extends State<VideoOrImage> {
  bool isInView = true, _muted = true, _loading = true, _videoError = false;
  ValueNotifier<double?> progress = ValueNotifier(null);

  void _toggleMuted() {
    setState(() {
      _muted = !_muted;
    });
  }

  @override
  Widget build(BuildContext context) {
    String? videoUrl = widget.videoUrl,
        imageUrl = widget.imageUrl,
        blurHash = widget.blurHash;

    Widget buildImage() => CachedNetworkImage(
          width: double.infinity,
          height: double.infinity,
          imageUrl: imageUrl!,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => Center(child: _NoImage()),
          placeholder: (context, url) => blurHash != null
              ? BlurHash(hash: blurHash)
              : Container(
                  height: double.infinity,
                  child: Center(
                    child: LoadingIndicator(),
                  ),
                ),
        );

    if (videoUrl == null) {
      if (imageUrl == null) {
        if (blurHash != null)
          return Stack(
            alignment: Alignment.center,
            children: [BlurHash(hash: blurHash), _NoImage()],
          );

        return Container(
          height: double.infinity,
          child: Center(
            child: _NoImage(),
          ),
        );
      }

      return buildImage();
    }

    Widget overlayImage = Container();

    if (imageUrl != null) overlayImage = buildImage();
    if (imageUrl == null && blurHash != null)
      overlayImage = BlurHash(hash: blurHash);

    return VisibilityDetector(
      key: Key(videoUrl),
      onVisibilityChanged: (info) {
        var visiblePercentage = (info.visibleFraction) * 100;
        if (mounted) {
          if (visiblePercentage == 100) {
            setState(() {
              isInView = true;
            });
          } else {
            setState(() {
              isInView = false;
            });
          }
        }
      },
      child: Stack(
        children: [
          VideoWidget(
            height: double.infinity,
            url: videoUrl,
            play: isInView,
            imageUrl: imageUrl,
            muted: widget.alwaysMuted ? true : _muted,
            toggleMuted: widget.alwaysMuted ? null : _toggleMuted,
            blurHash: blurHash,
            progress: (DownloadProgress dp) {
              progress.value = dp.progress ?? 0.0;
            },
            onVideoLoaded: () async {
              await Future.delayed(Duration(milliseconds: 500));
              if (mounted && _loading)
                setState(() {
                  _loading = false;
                });
            },
            onVideoLoadingError: () async {
              await Future.delayed(Duration(milliseconds: 500));
              if (mounted && _loading && !_videoError)
                setState(() {
                  _videoError = true;
                });
            },
          ),
          Positioned.fill(
              child: IgnorePointer(
            ignoring: !_loading,
            child: AnimatedOpacity(
                opacity: _loading ? 1 : 0,
                duration: Duration(milliseconds: 250),
                child: overlayImage),
          )),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ValueListenableBuilder<double?>(
                      valueListenable: progress,
                      builder: (context, value, child) {
                        return MuteButton(
                          progress: value,
                          loading: _loading,
                          error: _videoError,
                          muted: widget.alwaysMuted ? true : _muted,
                          toggle: widget.alwaysMuted ? null : _toggleMuted,
                          hide: widget.alwaysMuted,
                        );
                      })
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WarningIcon(),
        YMargin(12),
        Text(
          "Bild konnte nicht geladen werden.\nVersuche es später erneut!",
          textAlign: TextAlign.center,
          style: ThemeManager.of(context).textTheme.dark.caption,
        ),
      ],
    );
  }
}
