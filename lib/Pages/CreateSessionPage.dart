import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:one_d_m/Components/Avatar.dart';
import 'package:one_d_m/Components/CampaignButton.dart';
import 'package:one_d_m/Components/CustomOpenContainer.dart';
import 'package:one_d_m/Components/CustomTextField.dart';
import 'package:one_d_m/Components/SearchPage.dart';
import 'package:one_d_m/Components/UserButton.dart';
import 'package:one_d_m/Helper/Campaign.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/Provider/CreateSessionManager.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Helper/User.dart';
import 'package:one_d_m/Helper/UserManager.dart';
import 'package:provider/provider.dart';

class CreateSessionPage extends StatelessWidget {
  ScrollController _scrollController;
  ThemeManager _theme;

  CreateSessionPage(this._scrollController);

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return ChangeNotifierProvider<CreateSessionManager>(
      create: (context) => CreateSessionManager(),
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton:
            Consumer<CreateSessionManager>(builder: (context, csm, child) {
          return FloatingActionButton.extended(
            backgroundColor: _theme.colors.contrast,
            label: Text(
              "Fertig",
              style: TextStyle(color: _theme.colors.textOnContrast),
            ),
            icon: csm.loading
                ? Container(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation(_theme.colors.textOnContrast),
                    ))
                : Icon(
                    Icons.done,
                    color: _theme.colors.textOnContrast,
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
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              title: Text(
                "Session erstellen",
                style: TextStyle(color: _theme.colors.dark),
              ),
              iconTheme: IconThemeData(color: _theme.colors.dark),
              backgroundColor: Colors.white,
            ),
            SliverToBoxAdapter(
                child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                SvgPicture.asset(
                  "assets/images/sessions.svg",
                  height: 120,
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            )),
            _SessionNameInput(),
            _SessionDescriptionInput(),
            _DonationTarget(),
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
            _CampaignOptions(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Freunde",
                      style: _theme.textTheme.dark.headline6,
                    ),
                    Text(
                      "Wähle die Freunde aus, die der Session beitreten sollen.",
                      style: _theme.textTheme.dark.caption,
                    ),
                  ],
                ),
              ),
            ),
            _FriendsOptions(),
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
}

class _DonationTarget extends StatefulWidget {
  @override
  __DonationTargetState createState() => __DonationTargetState();
}

class __DonationTargetState extends State<_DonationTarget> {
  ThemeManager _theme;
  int _targetAmount = 3;

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Spendenziel",
              style: _theme.textTheme.dark.headline6,
            ),
            Text(
              "Überlege dir wieviel DV jeder Nutzer spenden soll.",
              style: _theme.textTheme.dark.caption,
            ),
            SizedBox(
              height: 12,
            ),
            Row(
              children: [
                Material(
                  color: _theme.colors.contrast,
                  borderRadius: BorderRadius.circular(12),
                  child: Theme(
                    data: ThemeData(
                        accentColor: _theme.colors.textOnContrast,
                        textTheme: TextTheme(
                            body1: TextStyle(
                                color: _theme.colors.textOnContrast
                                    .withOpacity(.8)))),
                    child: NumberPicker.horizontal(
                      initialValue: _targetAmount,
                      minValue: 1,
                      maxValue: 100,
                      listViewHeight: 80,
                      onChanged: (n) {
                        setState(() {
                          _targetAmount = n;
                        });
                        Provider.of<CreateSessionManager>(context,
                                listen: false)
                            .amountPerUser = n;
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Text(
                  "DV ",
                  style: _theme.textTheme.dark.headline6,
                ),
                Text(
                  "pro Session Mitglied.",
                  style: _theme.textTheme.dark.bodyText1,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _SessionNameInput extends StatefulWidget {
  @override
  __SessionNameInputState createState() => __SessionNameInputState();
}

class __SessionNameInputState extends State<_SessionNameInput> {
  ThemeManager _theme;

  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return SliverToBoxAdapter(
      child: Consumer<UserManager>(
        builder: (context, um, child) {
          String sessionDefaultName =
              "${um.user.name[0].toUpperCase()}${um.user.name.substring(1)}'s Session";
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
                  focusedColor: _theme.colors.contrast,
                  textColor: _theme.colors.dark,
                  hint: "e.g. Spendenaktion",
                  label: "Session Name",
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

class _SessionDescriptionInput extends StatefulWidget {
  @override
  __SessionDescriptionInputState createState() =>
      __SessionDescriptionInputState();
}

class __SessionDescriptionInputState extends State<_SessionDescriptionInput> {
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
                  focusedColor: _theme.colors.contrast,
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

class _FriendsOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserManager>(
      builder: (context, um, child) => StreamBuilder<List<String>>(
        stream: DatabaseService.getFollowingUsersStream(um.uid),
        builder: (context, snapshot) {
          List<String> userIds = snapshot.data ?? [];

          if (snapshot.connectionState == ConnectionState.done &&
              userIds.isEmpty)
            return SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                child: Text(
                    "Um eine Session zu erstellen, musst du mindestens 2 Freunde abonniert haben!"),
              ),
            );

          return SliverList(
            delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6),
                      child: _UserButton(userIds[index]),
                    ),
                childCount: userIds.length),
          );
        },
      ),
    );
  }
}

class _UserButton extends StatelessWidget {
  String uid;
  ThemeManager _theme;

  _UserButton(this.uid);

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return FutureBuilder<User>(
      future: DatabaseService.getUser(uid),
      builder: (context, snapshot) {
        User user = snapshot.data;
        CreateSessionManager csm = Provider.of<CreateSessionManager>(context);

        bool selected = csm.selectedUsers.contains(user);

        return Card(
          margin: const EdgeInsets.all(0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
            child: Row(
              children: [
                Avatar(user?.imgUrl),
                SizedBox(
                  width: 12,
                ),
                Text(
                  user?.name ?? "Laden...",
                  style: _theme.textTheme.dark.bodyText1,
                ),
                Expanded(child: Container()),
                TurningAddButton(
                  selected: selected,
                  onPressed: () =>
                      selected ? csm.removeUser(user) : csm.addUser(user),
                ),
              ],
            ),
          ),
        );
      },
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
            color: selected ? _theme.colors.contrast : Colors.white,
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
                          ? _theme.textTheme.textOnContrast.headline6
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
      backgroundColor: Colors.white,
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
                  ? DatabaseService.getCampaignFromQuery(_query)
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
                                : Colors.white,
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
