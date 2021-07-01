import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Components/CampaignButton.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Components/CustomTextField.dart';
import 'package:one_d_m/Components/SearchPage.dart';
import 'package:one_d_m/Components/UserButton.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/Constants.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Provider/CreateSessionManager.dart';
import 'package:one_d_m/Helper/Provider/SessionManager.dart';
import 'package:one_d_m/Helper/Session.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:one_d_m/Helper/margin.dart';
import 'package:one_d_m/Pages/SessionPage.dart';

import 'package:provider/provider.dart';

import 'HomePage/ProfilePage.dart';

class CreateSessionPage extends StatelessWidget {
  ThemeManager _theme;
  BaseSession _baseSession;

  CreateSessionPage([this._baseSession]);

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return ChangeNotifierProvider<CreateSessionManager>(
      create: (context) =>
          CreateSessionManager(context, baseSession: _baseSession),
      child: Scaffold(
        backgroundColor: ColorTheme.appBg,
        floatingActionButton:
            Consumer<CreateSessionManager>(builder: (context, csm, child) {
          Color textColor = _theme.correctColorFor(csm.primaryColor);
          return FloatingActionButton.extended(
            backgroundColor: csm.primaryColor,
            label: Text(
              csm.editMode ? "Updaten" : "Erstellen",
              style: TextStyle(color: textColor),
            ),
            icon: csm.loading
                ? Container(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(textColor),
                    ))
                : Icon(
                    Icons.done,
                    color: textColor,
                  ),
            onPressed: csm.loading
                ? null
                : () async {
                    String res = await Provider.of<CreateSessionManager>(
                            context,
                            listen: false)
                        .createSession();

                    if (res != null)
                      return Scaffold.of(context)
                          .showSnackBar(SnackBar(content: Text(res)));

                    Navigator.pop(context);
                  },
          );
        }),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
                child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.width,
                  width: double.infinity,
                  child: Consumer<CreateSessionManager>(
                    builder: (context, csm, child) {
                      print(csm.image);
                      Color textColor =
                          _theme.correctColorFor(csm.secondaryColor);
                      return Material(
                        color: csm.secondaryColor,
                        child: InkWell(
                          onTap: () async {
                            ImagePicker picker = ImagePicker();
                            PickedFile file = await picker.getImage(
                                source: ImageSource.gallery);

                            if (file?.path != null) csm.image = File(file.path);
                          },
                          child: getTitleImage(csm, textColor),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  left: 12,
                  top: MediaQuery.of(context).padding.top,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppBarButton(
                          elevation: 10,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icons.arrow_back),
                      Consumer<CreateSessionManager>(
                        builder: (context, csm, child) => AppBarButton(
                          elevation: 10,
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SessionPage(csm.previewSession)));
                          },
                          text: "Vorschau",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
            _ColorPicker(),
            _SessionNameInput(),
            _SessionDescriptionInput(),
            _DonationTarget(),
            if (_baseSession == null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Projekt",
                        style: _theme.textTheme.dark.headline6,
                      ),
                      Text(
                        "Wähle ein Projekt, an das während der Session gespendet werden soll.",
                        style: _theme.textTheme.dark.caption,
                      ),
                    ],
                  ),
                ),
              ),
            if (_baseSession == null) _CampaignOptions(),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 120,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getTitleImage(CreateSessionManager csm, Color textColor) {
    if (csm.image != null) {
      return Image.file(
        csm.image,
        fit: BoxFit.cover,
      );
    }

    if (csm.editMode)
      return CachedNetworkImage(
          imageUrl: csm.baseSession.imgUrl, fit: BoxFit.cover);

    return SafeArea(
      bottom: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.photo,
              color: textColor,
            ),
            YMargin(12),
            Text(
              "Wähle ein Titelbild für deine Session aus!",
              style:
                  _theme.textTheme.correctColorFor(csm.secondaryColor).caption,
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  ThemeManager _theme;
  BuildContext context;

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    this.context = context;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Consumer<CreateSessionManager>(
          builder: (context, csm, child) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Farben",
                style: _theme.textTheme.dark.headline6,
              ),
              Text(
                "Wähle zwei Farben für deine Session.",
                style: _theme.textTheme.dark.caption,
              ),
              YMargin(12),
              Row(
                children: [
                  _colorWidget(
                      text: "Primary",
                      color: csm.primaryColor,
                      onChangeColor: (color) => csm.primaryColor = color),
                  XMargin(12),
                  _colorWidget(
                      text: "Secondary",
                      color: csm.secondaryColor,
                      onChangeColor: (color) => csm.secondaryColor = color)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _colorWidget(
      {String text, Color color, void Function(Color) onChangeColor}) {
    return Expanded(
      child: Material(
        color: color,
        elevation: 1,
        borderRadius: BorderRadius.circular(Constants.radius),
        child: InkWell(
          onTap: () async {
            Color mColor = await showDialog<Color>(
                context: context,
                builder: (context) {
                  Color selectedColor = color;
                  return AlertDialog(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text("Wähle $text color"),
                    content: MaterialColorPicker(
                      shrinkWrap: true,
                      elevation: 0,
                      allowShades: true,
                      onColorChange: (color) => selectedColor = color,
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Abbrechen",
                            style: TextStyle(color: Colors.red),
                          )),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, selectedColor);
                        },
                        child: Text("Auswählen",
                            style: TextStyle(color: _theme.colors.dark)),
                      ),
                    ],
                  );
                });
            if (mColor != null) onChangeColor(mColor);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 18),
            child: Center(
              child: Text(text,
                  style: ThemeData.estimateBrightnessForColor(color) ==
                          Brightness.dark
                      ? _theme.textTheme.light.bodyText1
                      : _theme.textTheme.dark.bodyText1),
            ),
          ),
        ),
      ),
    );
  }
}

class _DonationTarget extends StatefulWidget {
  @override
  __DonationTargetState createState() => __DonationTargetState();
}

class __DonationTargetState extends State<_DonationTarget> {
  ThemeManager _theme;

  int _targetAmount = 100;

  @override
  void initState() {
    super.initState();
    CreateSessionManager csm = context.read<CreateSessionManager>();
    if (csm.editMode) _targetAmount = csm.baseSession.donationGoal;
  }

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Spendenziel",
              style: _theme.textTheme.dark.headline6,
            ),
            Text(
              "Überlege dir was das Ziel dieser Session ist.",
              style: _theme.textTheme.dark.caption,
            ),
            SizedBox(
              height: 12,
            ),
            Row(
              children: [
                Consumer<CreateSessionManager>(
                  builder: (context, csm, child) {
                    int step = 10;
                    return Material(
                      color: csm.secondaryColor,
                      borderRadius: BorderRadius.circular(12),
                      child: NumberPicker.horizontal(
                        initialValue: _targetAmount,
                        minValue: 10,
                        maxValue: 10000,
                        step: step,
                        listViewHeight: 80,
                        haptics: true,
                        textStyle: TextStyle(
                            color: _theme
                                .correctColorFor(csm.secondaryColor)
                                .withOpacity(.5)),
                        selectedTextStyle: TextStyle(
                            color: _theme.correctColorFor(csm.secondaryColor),
                            fontWeight: FontWeight.bold),
                        onChanged: (n) {
                          setState(() {
                            _targetAmount = n;
                          });
                          csm.donationGoal = n;
                        },
                      ),
                    );
                  },
                ),
                SizedBox(
                  width: 12,
                ),
                Consumer<CreateSessionManager>(
                  builder: (context, csm, child) => Text(
                    csm.editMode
                        ? csm.baseSession.donationUnit
                        : (csm.selectedCampaign?.unit ?? "DV"),
                    style: _theme.textTheme.dark.bodyText1,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _SessionNameInput extends StatelessWidget {
  ThemeManager _theme;

  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return SliverToBoxAdapter(
      child: Consumer<UserManager>(
        builder: (context, um, child) {
          String sessionDefaultName =
              "${um.user.name[0].toUpperCase()}${um.user.name.substring(1)}s Session";
          CreateSessionManager csm =
              Provider.of<CreateSessionManager>(context, listen: false);

          if (csm.sessionName == null && _controller.text.isEmpty) {
            _controller.text = "Test";
            csm.sessionName = sessionDefaultName;
          }

          _controller.text = csm.sessionName;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Name",
                  style: _theme.textTheme.dark.headline6,
                ),
                Text(
                  "Überlege dir einen Namen für deine Session. Standartmäßig verwenden wir: \"$sessionDefaultName\".",
                  style: _theme.textTheme.dark.caption,
                ),
                SizedBox(
                  height: 12,
                ),
                CustomTextField(
                  controller: _controller,
                  focusedColor: _theme.colors.dark,
                  textColor: _theme.colors.dark,
                  hint: "e.g. Spendenaktion",
                  label: "Session Name",
                  inputFormatter: [
                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9-._ ]"))
                  ],
                  onChanged: (txt) {
                    csm.sessionName = txt;
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SessionDescriptionInput extends StatelessWidget {
  ThemeManager _theme;

  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return SliverToBoxAdapter(
      child: Consumer<UserManager>(
        builder: (context, um, child) {
          CreateSessionManager csm =
              Provider.of<CreateSessionManager>(context, listen: false);

          if (csm.editMode && (_controller.text?.isEmpty ?? true))
            _controller.text = csm.baseSession.sessionDescription;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Beschreibung",
                  style: _theme.textTheme.dark.headline6,
                ),
                Text(
                  "Überlege dir eine anregende Beschreibung für deine Session.",
                  style: _theme.textTheme.dark.caption,
                ),
                SizedBox(
                  height: 12,
                ),
                CustomTextField(
                  controller: _controller,
                  focusedColor: _theme.colors.dark,
                  textColor: _theme.colors.dark,
                  maxLines: 4,
                  maxLength: 200,
                  hint: "e.g. Es war noch nie so wichtig...",
                  label: "Session Beschreibung",
                  onChanged: (txt) {
                    csm.sessionDescription = txt;
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CampaignOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 90,
        child: FutureBuilder<List<Campaign>>(
            future: DatabaseService.getTopCampaigns(),
            builder: (context, snapshot) {
              List<Campaign> campaigns = snapshot.data ?? [];

              CreateSessionManager csm =
                  Provider.of<CreateSessionManager>(context, listen: false);
              if (snapshot.hasData &&
                  csm.selectedCampaign == null &&
                  campaigns.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  if (csm.editMode) {
                    csm.selectedCampaign = Campaign(
                        name: csm.baseSession.campaignName,
                        imgUrl: csm.baseSession.campaignImgUrl,
                        id: csm.baseSession.campaignId);
                  } else
                    csm.selectedCampaign = campaigns[0];
                });
              }

              if (!campaigns.contains(csm.selectedCampaign) &&
                  csm.selectedCampaign != null) {
                campaigns.add(csm.selectedCampaign);
              }

              if (campaigns.isEmpty)
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        width: 20,
                      ),
                      Text("Lade Projekte")
                    ],
                  ),
                );

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: campaigns.length + 1,
                separatorBuilder: (context, index) => SizedBox(
                  width: 12,
                ),
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(
                      left: index == 0 ? 12.0 : 0,
                      right: index == campaigns.length ? 12.0 : 0),
                  child: index == campaigns.length
                      ? _SearchCampaignButton()
                      : _HorizontalCampaignView(campaigns[index]),
                ),
              );
            }),
      ),
    );
  }
}

class _SearchCampaignButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CreateSessionManager>(
      builder: (context, csm, child) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: CustomOpenContainer(
            closedColor: ColorTheme.appBg,
            openBuilder: (context, close, scrollController) =>
                _SearchPage<Campaign>(
              scrollController: scrollController,
              onFinished: (List<Campaign> res) {
                csm.selectedCampaign = res[0];
              },
            ),
            closedBuilder: (context, open) =>
                InkWell(onTap: open, child: Icon(Icons.search)),
            closedShape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}

class _HorizontalCampaignView extends StatelessWidget {
  Campaign campaign;
  ThemeManager _theme;

  _HorizontalCampaignView(this.campaign);

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);

    return Consumer<CreateSessionManager>(
      builder: (context, csm, child) {
        bool selected = csm.selectedCampaign == campaign;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Material(
            borderRadius: BorderRadius.circular(12),
            color: selected ? csm.secondaryColor : ColorTheme.appBg,
            elevation: 1,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                csm.selectedCampaign = campaign;
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    Avatar(campaign.imgUrl),
                    SizedBox(
                      width: 12,
                    ),
                    Text(
                      campaign.name,
                      style: selected
                          ? _theme.textTheme
                              .correctColorFor(csm.secondaryColor)
                              .headline6
                          : _theme.textTheme.dark.headline6,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SearchPage<T> extends StatefulWidget {
  final ScrollController scrollController;
  final void Function(List<T>) onFinished;

  const _SearchPage({
    Key key,
    this.scrollController,
    this.onFinished,
  }) : super(key: key);

  @override
  __SearchPageState<T> createState() => __SearchPageState<T>();
}

class __SearchPageState<E> extends State<_SearchPage<E>> {
  String _query = "";
  Campaign campaign = Campaign();
  ThemeManager _theme;
  List<E> _results = [];

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return Scaffold(
      backgroundColor: ColorTheme.appBg,
      floatingActionButton: Builder(builder: (context) {
        return FloatingActionButton.extended(
          icon: Icon(
            Icons.done,
            color: _theme.colors.textOnContrast,
          ),
          label: Text(
            "Fertig",
            style: TextStyle(color: _theme.colors.textOnContrast),
          ),
          backgroundColor: _theme.colors.contrast,
          onPressed: () {
            if (_results.isEmpty)
              return Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(
                      "Du musst mindestens eine Suchergebnis auswählen.")));

            widget.onFinished(_results);
            Navigator.pop(context);
          },
        );
      }),
      body: CustomScrollView(
        controller: widget.scrollController,
        slivers: [
          SliverSearchBar(
            onChanged: (text) {
              setState(() {
                _query = text;
              });
            },
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 20,
            ),
          ),
          FutureBuilder<List<E>>(
              future: campaign is E
                  ? DatabaseService.getCampaignFromQuery(_query, limit: 20)
                  : DatabaseService.getUsersFromQuery(_query),
              builder: (context, snapshot) {
                List<E> data = snapshot.data ?? [];

                if (data.isEmpty &&
                    snapshot.connectionState == ConnectionState.waiting)
                  return SliverToBoxAdapter(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation(_theme.colors.contrast),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text("Lade Suchergebnisse"),
                      ],
                    ),
                  );

                if (data.isEmpty &&
                    snapshot.connectionState == ConnectionState.done)
                  return SliverToBoxAdapter(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        SvgPicture.asset(
                          'assets/images/no-search-results.svg',
                          height: 120,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                            "Es gibt leider keine Ergebnisse für deine Suche."),
                      ],
                    ),
                  );

                return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                  bool selected = _results.contains(data[index]);
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18.0, vertical: 4),
                    child: campaign is E
                        ? CampaignButton((data[index] as Campaign).id,
                            color: selected
                                ? _theme.colors.contrast
                                : ColorTheme.appBg,
                            campaign: (data[index] as Campaign),
                            textStyle: selected
                                ? TextStyle(color: _theme.colors.textOnContrast)
                                : TextStyle(), onPressed: (c) {
                            if (_results.isEmpty) {
                              _results.add(data[index]);
                            } else {
                              _results[0] = data[index];
                            }
                            setState(() {});
                          })
                        : UserButton((data[index] as User).id,
                            user: (data[index] as User)),
                  );
                }, childCount: data.length));
              }),
        ],
      ),
    );
  }
}
