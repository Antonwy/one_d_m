import 'package:flutter/material.dart';
import '../Helper/Helper.dart';
import 'custom_timer_painter.dart';

/// Create a Circular Countdown Timer.
class CircularCountDownTimer extends StatefulWidget {
  /// Key for Countdown Timer.
  final Key key;

  /// Filling Color for Countdown Widget.
  final Color fillColor;

  /// Ring Color for Countdown Widget.
  final Color color;

  /// Background Color for Countdown Widget.
  final Color backgroundColor;

  /// This Callback will execute when the Countdown Ends.
  final VoidCallback onComplete;

  /// This Callback will execute when the Countdown Starts.
  final VoidCallback onStart;

  /// Countdown duration in Seconds.
  final int duration;

  /// Width of the Countdown Widget.
  final double width;

  /// Height of the Countdown Widget.
  final double height;

  /// Border Thickness of the Countdown Ring.
  final double strokeWidth;

  /// Begin and end contours with a flat edge and no extension.
  final StrokeCap strokeCap;

  /// Text Style for Countdown Text.
  final TextStyle textStyle;

  /// Format for the Countdown Text.
  final String textFormat;

  /// Handles Countdown Timer (true for Reverse Countdown (max to 0), false for Forward Countdown (0 to max)).
  final bool isReverse;

  /// Handles Animation Direction (true for Reverse Animation, false for Forward Animation).
  final bool isReverseAnimation;

  /// Handles visibility of the Countdown Text.
  final bool isTimerTextShown;

  /// Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
  final CountDownController controller;

  /// Handles the timer start.
  final bool autoStart;

  final bool showLabel;

  final Widget Function() childBuilder;

  CircularCountDownTimer(
      {@required this.width,
      @required this.height,
      @required this.duration,
      @required this.fillColor,
      @required this.color,
      @required this.childBuilder,
      this.backgroundColor,
      this.isReverse = false,
      this.isReverseAnimation = false,
      this.onComplete,
      this.onStart,
      this.strokeWidth,
      this.strokeCap,
      this.textStyle,
      this.key,
      this.isTimerTextShown = true,
      this.autoStart = true,
      this.textFormat,
      this.controller,
      this.showLabel})
      : assert(width != null),
        assert(height != null),
        assert(duration != null),
        assert(fillColor != null),
        assert(color != null),
        super(key: key);

  @override
  CircularCountDownTimerState createState() => CircularCountDownTimerState();
}

class CircularCountDownTimerState extends State<CircularCountDownTimer>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _countDownAnimation;

  String get time {
    if (widget.isReverse && _controller.isDismissed) {
      if (widget.textFormat == CountdownTextFormat.MM_SS) {
        return "00:00";
      } else if (widget.textFormat == CountdownTextFormat.SS) {
        return "00";
      } else {
        return "00:00:00";
      }
    } else {
      Duration duration = _controller.duration * _controller.value;
      return _getTime(duration);
    }
  }

  void _setAnimation() {
    if (widget.autoStart) {
      if (widget.isReverse) {
        _controller.reverse(from: 1);
      } else {
        _controller.forward();
      }
    }
  }

  void _setAnimationDirection() {
    if ((!widget.isReverse && widget.isReverseAnimation) ||
        (widget.isReverse && !widget.isReverseAnimation)) {
      _countDownAnimation =
          Tween<double>(begin: 1, end: 0).animate(_controller);
    }
  }

  void _setController() {
    widget.controller?._state = this;
    widget.controller?._isReverse = widget.isReverse;
  }

  String _getTime(Duration duration) {
    // For HH:mm:ss format
    if (widget.textFormat == CountdownTextFormat.HH_MM_SS) {
      return '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
    // For mm:ss format
    else if (widget.textFormat == CountdownTextFormat.MM_SS) {
      return '${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
    // For ss format
    else if (widget.textFormat == CountdownTextFormat.SS) {
      return '${(duration.inSeconds)}';
    } else {
      // Default format
      return _defaultFormat(duration);
    }
  }

  _defaultFormat(Duration duration) {
    if (duration.inHours != 0) {
      return '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    } else if (duration.inMinutes != 0) {
      return '${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    } else {
      return '${duration.inSeconds % 60}';
    }
  }

  void _onStart() {
    if (widget.onStart != null) widget.onStart();
  }

  void _onComplete() {
    if (widget.onComplete != null) widget.onComplete();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration),
    );

    _controller.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.forward:
          _onStart();
          break;

        case AnimationStatus.reverse:
          _onStart();
          break;

        case AnimationStatus.dismissed:
          _onComplete();
          break;
        case AnimationStatus.completed:

          /// [AnimationController]'s value is manually set to [1.0] that's why [AnimationStatus.completed] is invoked here this animation is [isReverse]
          /// Only call the [_onComplete] block when the animation is not reversed.
          if (!widget.isReverse) _onComplete();
          break;
        default:
        // Do nothing
      }
    });

    _setAnimation();
    _setAnimationDirection();
    _setController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Align(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: CustomPaint(
                        painter: CustomTimerPainter(
                            animation: _countDownAnimation ?? _controller,
                            fillColor: widget.fillColor,
                            color: widget.color,
                            strokeWidth: widget.strokeWidth,
                            strokeCap: widget.strokeCap,
                            backgroundColor: widget.backgroundColor),
                      ),
                    ),
                    widget.isTimerTextShown
                        ? Align(
                            alignment: FractionalOffset.center,
                            child: widget.childBuilder())
                        : Container(),
                  ],
                ),
              ),
            );
          }),
    );
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }
}

/// Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
class CountDownController {
  CircularCountDownTimerState _state;
  bool _isReverse;

  /// This Method Starts the Countdown Timer
  void start() {
    if (_isReverse) {
      _state._controller?.reverse(from: 1);
    } else {
      _state._controller?.forward(from: 0);
    }
  }

  /// This Method Pauses the Countdown Timer
  void pause() {
    _state._controller?.stop(canceled: false);
  }

  /// This Method Resumes the Countdown Timer
  void resume() {
    if (_isReverse) {
      _state._controller?.reverse(from: _state._controller.value);
    } else {
      _state._controller?.forward(from: _state._controller.value);
    }
  }

  /// This Method Restarts the Countdown Timer,
  /// Here optional int parameter **duration** is the updated duration for countdown timer
  void restart({int duration}) {
    _state._controller.duration =
        Duration(seconds: duration ?? _state._controller.duration.inSeconds);
    if (_isReverse) {
      _state._controller?.reverse(from: 1);
    } else {
      _state._controller?.forward(from: 0);
    }
  }

  void restartFromDuration(int value) {
    double v = Helper.mapValue(
        value, 0, _state._controller?.duration?.inSeconds ?? 400, 0, 1);
    print(_state._controller.duration.inSeconds);
    _state._controller?.reverse(from: 1 - v);
  }

  void restartFromValue(double value) {
    _state._controller?.reverse(from: value);
  }

  void complete() => _state._controller.value = 1.0;

  /// This Method returns the **Current Time** of Countdown Timer i.e
  /// Time Used in terms of **Forward Countdown** and Time Left in terms of **Reverse Countdown**
  String getTime() {
    return _state
        ._getTime(_state._controller.duration * _state._controller?.value);
  }

  AnimationStatus get status => _state._controller?.status;
  double get value => _state._controller?.value;
}

class CountdownTextFormat {
  static const String HH_MM_SS = "HH:mm:ss";
  static const String MM_SS = "mm:ss";
  static const String SS = "ss";
}
