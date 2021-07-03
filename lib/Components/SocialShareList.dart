import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/ShareManager.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:social_share/social_share.dart';

class SocialShareList extends StatelessWidget {
  final Shareable shareable;
  final void Function() onClicked;

  const SocialShareList(this.shareable, {this.onClicked});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map>(
        initialData: {
          for (SocialMediaType v in [
            SocialMediaType.clipboard,
            SocialMediaType.other
          ])
            v.toString().split(".")[1]: true
        },
        future: SocialShare.checkInstalledAppsForShare(),
        builder: (context, snapshot) {
          return Wrap(
            runSpacing: 8,
            children: _typesFromMap(snapshot.data)
                .map((t) => SocialMediaButton(
                      t,
                      shareable: shareable,
                      onClicked: onClicked,
                    ))
                .toList(),
          );
        });
  }

  List<SocialMediaType> _typesFromMap(Map types) {
    List<SocialMediaType> parsedTypes = [];

    for (MapEntry e in types.entries) {
      if (e.value) {
        // if (e.key == "twitter")
        //   parsedTypes.add(SocialMediaType.twitter);
        if (e.key == "instagram")
          parsedTypes.add(SocialMediaType.instagram);
        else if (e.key == "whatsapp")
          parsedTypes.add(SocialMediaType.whatsapp);
        else if (e.key == "telegram") parsedTypes.add(SocialMediaType.telegram);
      }
    }

    parsedTypes.add(SocialMediaType.clipboard);
    parsedTypes.add(SocialMediaType.other);
    print(parsedTypes);
    return parsedTypes;
  }
}

class SocialMediaButton extends StatefulWidget {
  final SocialMediaType type;
  final Shareable shareable;
  final void Function() onClicked;

  const SocialMediaButton(this.type, {this.shareable, this.onClicked});

  @override
  _SocialMediaButtonState createState() => _SocialMediaButtonState();
}

class _SocialMediaButtonState extends State<SocialMediaButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = _getBackgroundColor();
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        clipBehavior: Clip.antiAlias,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(Constants.radius),
        child: InkWell(
          onTap: () async {
            setState(() {
              _loading = true;
            });
            ShareItem item = ShareItem(
                shareable: widget.shareable,
                context: context,
                text: "Hey",
                hashtags: ["odm", "donateForFree"]);
            await ShareManager.of(item).shareFromType(widget.type);
            setState(() {
              _loading = false;
            });
            if (widget.onClicked != null) widget.onClicked();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 30,
              child: AspectRatio(
                aspectRatio: 1,
                child: Builder(builder: (context) {
                  String name = widget.type.toString().split(".")[1];
                  if (_loading)
                    return Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                              ThemeManager.of(context)
                                  .correctColorFor(backgroundColor)),
                          strokeWidth: 3),
                    );

                  if (name == "clipboard")
                    return Icon(
                      Icons.copy,
                    );
                  if (name == "sms")
                    return Icon(
                      Icons.sms_rounded,
                    );
                  if (name == "other")
                    return Icon(
                      CupertinoIcons.share,
                    );

                  return Image.asset(
                    "assets/icons/$name.png",
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case SocialMediaType.instagram:
        return Colors.red[50];
      case SocialMediaType.whatsapp:
        return Colors.green;
      case SocialMediaType.telegram:
        return Colors.blue[100];
      case SocialMediaType.twitter:
        return Colors.blue[50];
      case SocialMediaType.other:
      case SocialMediaType.sms:
      case SocialMediaType.clipboard:
        return Colors.blueGrey[50];
      default:
        return Colors.red;
    }
  }
}
