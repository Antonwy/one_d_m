import 'package:flutter/material.dart';

class KeepAliveStreamBuilder extends StatefulWidget {
  final Stream? stream;
  final AsyncWidgetBuilder? builder;

  const KeepAliveStreamBuilder({Key? key, this.stream, this.builder})
      : super(key: key);

  @override
  _KeepAliveStreamBuilderState createState() => _KeepAliveStreamBuilderState();
}

class _KeepAliveStreamBuilderState extends State<KeepAliveStreamBuilder>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.stream,
      builder: widget.builder!,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
