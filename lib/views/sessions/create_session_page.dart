import 'dart:async';
import 'dart:io';
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/api/api_result.dart';
import 'package:one_d_m/components/avatar.dart';
import 'package:one_d_m/components/campaign_button.dart';
import 'package:one_d_m/components/custom_open_container.dart';
import 'package:one_d_m/components/custom_text_field.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/components/social_share_list.dart';
import 'package:one_d_m/components/user_button.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/database_service.dart';
import 'package:one_d_m/models/campaign_models/base_campaign.dart';
import 'package:one_d_m/models/campaign_models/campaign.dart';
import 'package:one_d_m/models/donation_unit.dart';
import 'package:one_d_m/models/session_models/base_session.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/provider/create_session_manager.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:one_d_m/provider/user_manager.dart';
import 'package:one_d_m/views/general/search_page.dart';
import 'package:one_d_m/views/home/profile_page.dart';
import 'package:one_d_m/views/sessions/session_page.dart';
import 'package:one_d_m/provider/sessions_manager.dart';
import 'package:provider/provider.dart';

class CreateSessionPage extends StatelessWidget {
  ThemeManager _theme;
  BaseSessionManager _baseSessionManager;

  CreateSessionPage([this._baseSessionManager]);

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return ChangeNotifierProvider<CreateSessionManager>(
      create: (context) => CreateSessionManager(context,
          baseSessionManager: _baseSessionManager),
      child: Scaffold(
        backgroundColor: ColorTheme.appBg,
        floatingActionButton:
            Consumer<CreateSessionManager>(builder: (context, csm, child) {
          Color textColor = _theme.correctColorFor(csm.primaryColor);
          return OpenContainer(
              openBuilder: (context, close) => _CreateSuccessPage(csm),
              closedColor: csm.primaryColor,
              closedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(48)),
              closedElevation: 10,
              closedBuilder: (context, open) {
                return Container(
                  height: 50,
                  child: InkWell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          csm.loading
                              ? Container(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation(textColor),
                                  ))
                              : Icon(
                                  Icons.done,
                                  color: textColor,
                                  size: 24,
                                ),
                          XMargin(8),
                          Flexible(
                            child: Text(
                              csm.editMode ? "Updaten" : "Erstellen",
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: csm.loading
                        ? null
                        : () async {
                            ApiResult res = await csm.createSession();

                            if (res.hasError())
                              return ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(res.message)));
                            open();
                          },
                  ),
                );
              });
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
            if (_baseSessionManager == null)
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
            if (_baseSessionManager == null) _CampaignOptions(),
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
          imageUrl: csm.baseSessionManager.baseSession.imgUrl,
          fit: BoxFit.cover);

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
    if (csm.editMode)
      _targetAmount = csm.baseSessionManager.baseSession.donationGoal;
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
                      child: NumberPicker(
                        axis: Axis.horizontal,
                        value: _targetAmount,
                        minValue: 10,
                        maxValue: 10000,
                        step: step,
                        itemHeight: 80,
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
                  builder: (context, csm, child) {
                    BaseCampaign c = csm.selectedCampaign ??
                        BaseCampaign(unit: DonationUnit(name: 'DV'));
                    return FutureBuilder<BaseCampaign>(
                        initialData: c,
                        future: csm.editMode
                            ? Api().campaigns().getOne(
                                csm.baseSessionManager.baseSession.campaignId)
                            : Future.value(c),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data?.unit?.name ?? "DV",
                            style: _theme.textTheme.dark.bodyText1,
                          );
                        });
                  },
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
            _controller.text = csm.baseSessionManager.baseSession.description;

          _controller.text = csm.sessionDescription;
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
        child: FutureBuilder<List<BaseCampaign>>(
            future: Api().campaigns().limit(5).get(),
            builder: (context, snapshot) {
              List<BaseCampaign> campaigns = snapshot.data ?? [];

              CreateSessionManager csm =
                  Provider.of<CreateSessionManager>(context, listen: false);
              if (snapshot.hasData &&
                  csm.selectedCampaign == null &&
                  campaigns.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  if (csm.editMode) {
                    csm.selectedCampaign = BaseCampaign(
                        id: csm.baseSessionManager.baseSession.campaignId);
                  } else
                    csm.selectedCampaign = campaigns[0];
                });
              }

              if (csm.selectedCampaign != null &&
                  !campaigns.contains(csm.selectedCampaign)) {
                campaigns.insert(0, csm.selectedCampaign);
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
            openBuilder: (context, close, scrollController) => _SearchPage(
              scrollController: scrollController,
              onFinished: (List<BaseCampaign> res) {
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
  BaseCampaign campaign;
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

class _SearchPage extends StatefulWidget {
  final ScrollController scrollController;
  final void Function(List<BaseCampaign>) onFinished;

  const _SearchPage({
    Key key,
    this.scrollController,
    this.onFinished,
  }) : super(key: key);

  @override
  __SearchPageState createState() => __SearchPageState();
}

class __SearchPageState extends State<_SearchPage> {
  String _query = "";
  BaseCampaign campaign = BaseCampaign();
  ThemeManager _theme;
  List<BaseCampaign> _results = [];
  Timer _debounce;

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
              if (_debounce?.isActive ?? false) _debounce.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                setState(() {
                  _query = text;
                });
              });
            },
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 20,
            ),
          ),
          FutureBuilder<List<BaseCampaign>>(
              future: Api().campaigns().name(_query).limit(10).get(),
              builder: (context, snapshot) {
                List<BaseCampaign> data = snapshot.data ?? [];

                if (data.isEmpty &&
                    snapshot.connectionState == ConnectionState.waiting)
                  return SliverToBoxAdapter(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        LoadingIndicator(
                          message: "Lade Suchergebnisse...",
                        )
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
                          horizontal: 12.0, vertical: 4),
                      child: CampaignButton((data[index]).id,
                          elevation: selected ? 1 : 0,
                          color: selected
                              ? _theme.colors.contrast
                              : ColorTheme.appBg,
                          campaign: (data[index]),
                          textStyle: selected
                              ? TextStyle(color: _theme.colors.textOnContrast)
                              : TextStyle(), onPressed: (c) {
                        if (_results.isEmpty) {
                          _results.add(data[index]);
                        } else {
                          _results[0] = data[index];
                        }
                        setState(() {});
                      }));
                }, childCount: data.length));
              }),
        ],
      ),
    );
  }
}

class _CreateSuccessPage extends StatelessWidget {
  final CreateSessionManager csm;
  const _CreateSuccessPage(this.csm);

  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return FutureBuilder<BaseSession>(
        future: Api().sessions().getOne(csm.uploadableSession.id),
        builder: (context, snapshot) {
          return Scaffold(
            backgroundColor: csm.primaryColor,
            floatingActionButton: FloatingActionButton(
                onPressed: snapshot.hasData
                    ? () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SessionPage(snapshot.data)),
                            (route) => route.isFirst);
                      }
                    : () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                child: Icon(
                  snapshot.hasData ? Icons.arrow_forward : Icons.close,
                  color: _theme.correctColorFor(csm.secondaryColor),
                ),
                backgroundColor: csm.secondaryColor),
            body: ClipRect(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      width: 150,
                      height: 150,
                      child: Transform.scale(
                        scale: 2.5,
                        child: Lottie.asset('assets/anim/anim_start.json',
                            repeat: false, onLoaded: (composition) {
                          HapticFeedback.heavyImpact();
                        }),
                      ),
                    ),
                  ),
                  YMargin(12),
                  Text(
                      "Deine Session wurde ${csm.editMode ? "geupdated" : "erstellt"}!",
                      style: _theme.textTheme
                          .correctColorFor(csm.primaryColor)
                          .headline6),
                  YMargin(6),
                  Text("Teile sie jetzt mit deinen Freunden:",
                      style: _theme.textTheme
                          .correctColorFor(csm.primaryColor)
                          .bodyText2),
                  YMargin(12),
                  Builder(builder: (context) {
                    if (!snapshot.hasData)
                      return LoadingIndicator(
                        color: csm.secondaryColor,
                        size: 15,
                      );
                    return SocialShareList(snapshot?.data
                        ?.manager(context.read<UserManager>().uid));
                  }),
                ],
              ),
            ),
          );
        });
  }
}
