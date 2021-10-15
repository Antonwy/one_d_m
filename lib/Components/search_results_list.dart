import 'dart:async';

import 'package:flutter/material.dart';
import 'package:one_d_m/api/api.dart';
import 'package:one_d_m/api/stream_result.dart';
import 'package:one_d_m/components/donation_widget.dart';
import 'package:one_d_m/components/empty.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/models/campaign_models/campaign.dart';
import 'package:one_d_m/models/organization.dart';
import 'package:one_d_m/models/search_result.dart';
import 'package:one_d_m/models/session_models/session.dart';
import 'package:one_d_m/models/user.dart';
import 'package:one_d_m/views/campaigns/campaign_page.dart';
import 'package:one_d_m/views/organizations/organization_page.dart';
import 'package:one_d_m/views/sessions/session_page.dart';
import 'package:one_d_m/views/users/user_page.dart';

class SearchResultsList extends StatelessWidget {
  final String _query;

  const SearchResultsList([this._query = ""]);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StreamResult<SearchResult>>(
        stream: Api().searchStream(_query),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return SliverFillRemaining(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingIndicator(),
                  YMargin(12),
                  Text('Lade Suchergebnisse...')
                ],
              ),
            );

          SearchResult result = snapshot.data!.data!;

          if (result.noData)
            return SliverFillRemaining(
              child: Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Empty(
                  message: "Keine Ergebnisse gefunden!",
                ),
              ),
            );

          return SliverList(
              delegate: SliverChildListDelegate(
            [
              result.users!.isEmpty
                  ? Container()
                  : Padding(
                      padding:
                          const EdgeInsets.only(left: 20, bottom: 10, top: 10),
                      child: Text(
                        "Nutzer",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
              ..._buildItems(result.users!),
              SizedBox(
                height: 10,
              ),
              result.sessions!.isEmpty
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 10),
                      child: Text(
                        "Sessions",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
              ..._buildItems(result.sessions!),
              SizedBox(
                height: 10,
              ),
              result.campaigns!.isEmpty
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 10),
                      child: Text(
                        "Projekte",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
              ..._buildItems(result.campaigns!),
              SizedBox(
                height: 10,
              ),
              result.organizations!.isEmpty
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 10),
                      child: Text(
                        "Organizations",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
              ..._buildItems(result.organizations!),
              SizedBox(height: 50)
            ],
          ));
        });
  }

  _buildItems(List<SearchResultItem> items) {
    return items.map((i) => _SearchItem(i)).toList();
  }
}

class _SearchItem extends StatefulWidget {
  final SearchResultItem item;
  const _SearchItem(this.item);

  @override
  __SearchItemState createState() => __SearchItemState();
}

class __SearchItemState extends State<_SearchItem> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18),
      leading: RoundedAvatar(widget.item.thumbnailUrl ?? widget.item.imageUrl,
          blurHash: widget.item.blurHash, loading: _loading),
      title: Text(
        widget.item.name!,
        key: Key(widget.item.id!),
      ),
      onTap: () async {
        setState(() {
          _loading = true;
        });

        Widget page;
        switch (widget.item.type) {
          case SearchResultType.campaigns:
            Campaign? campaign = await Api().campaigns().getOne(widget.item.id);
            page = CampaignPage(campaign!);
            break;
          case SearchResultType.sessions:
            Session? session = await (Api().sessions().getOne(widget.item.id));
            page = SessionPage(session!);
            break;
          case SearchResultType.users:
            User? user = await Api().users().getOne(widget.item.id);
            page = UserPage(user!);
            break;
          case SearchResultType.organizations:
            Organization? org =
                await Api().organizations().getOne(widget.item.id);
            page = OrganizationPage(org);
            break;
          default:
            Campaign? campaign = await Api().campaigns().getOne(widget.item.id);
            page = CampaignPage(campaign!);
        }

        setState(() {
          _loading = false;
        });

        Navigator.push(context, MaterialPageRoute(builder: (c) => page));
      },
    );
  }
}
