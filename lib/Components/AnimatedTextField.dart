import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';

class AnimatedTextField extends StatefulWidget {
  final String hint;
  final Color activeColor, focusedColor, textColor;
  final Icon prefixIcon;
  final TextInputType textInputType;
  final bool obscureText, autoCorrect;
  final Function(String) onChanged;
  final String Function(String) validator;

  AnimatedTextField(
      {Key key,
      this.hint,
      this.prefixIcon,
      this.obscureText = false,
      this.textInputType = TextInputType.text,
      this.activeColor = Colors.black26,
      this.focusedColor = Colors.black,
      this.textColor = Colors.white,
      this.onChanged,
      this.autoCorrect = true,
      this.validator})
      : super(key: key);

  @override
  _AnimatedTextFieldState createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField> {
  Duration _animDuration = Duration(milliseconds: 500);

  FocusNode _focus = FocusNode();

  bool _hasFocus = false;
  String _error;

  get _hasError => _error != null;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      setState(() {
        _hasFocus = _focus.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        overflow: Overflow.visible,
        alignment: Alignment.centerLeft,
        children: <Widget>[
          AnimatedPositioned(
            curve: Curves.fastLinearToSlowEaseIn,
            duration: _animDuration,
            left: _hasFocus ? 10 : 0,
            child: AnimatedContainer(
              width: _hasFocus ? 0 : constraints.maxWidth,
              height: (_hasFocus ? 25.0 : 60.0),
              duration: _animDuration,
              curve: Curves.fastLinearToSlowEaseIn,
              decoration: BoxDecoration(
                  color: _hasError ? Colors.red : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: kElevationToShadow[_hasFocus ? 0 : 1]),
            ),
          ),
          AnimatedContainer(
            width: constraints.maxWidth,
            curve: Curves.fastLinearToSlowEaseIn,
            duration: _animDuration,
            height: 60,
            decoration: BoxDecoration(
                border: Border.all(
                    width: 2, color: _hasError ? Colors.red : Colors.white),
                borderRadius: BorderRadius.circular(6)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: TweenAnimationBuilder(
                curve: Curves.fastLinearToSlowEaseIn,
                duration: _animDuration,
                tween: ColorTween(
                    begin: ColorTheme.blue,
                    end: _hasFocus ? Colors.white : Colors.black),
                builder: (context, color, child) {
                  return Theme(
                    data: ThemeData(primaryColor: ColorTheme.whiteBlue),
                    child: TextFormField(
                      validator: (text) {
                        String error = widget.validator(text);

                        if (error != null)
                          setState(() {
                            _error = error;
                          });

                        return "";
                      },
                      cursorColor: Colors.white,
                      focusNode: _focus,
                      autocorrect: false,
                      obscureText: widget.obscureText,
                      onChanged: widget.onChanged,
                      keyboardType: widget.textInputType,
                      style: TextStyle(
                        fontSize: 18,
                        color: color,
                      ),
                      decoration: InputDecoration(
                          errorStyle: TextStyle(color: Colors.red, height: 0),
                          border: InputBorder.none,
                          hintText: widget.hint,
                          suffixIcon: widget.prefixIcon,
                          hintStyle: TextStyle(
                              color: color.withOpacity(.4), fontSize: 16)),
                    ),
                  );
                }),
          ),
        ],
      );
    });
  }
}
