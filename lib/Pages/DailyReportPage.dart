import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';
import 'package:one_d_m/Helper/DailyReport.dart';
import 'package:one_d_m/Helper/DatabaseService.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';
import 'package:one_d_m/Pages/HomePage/ProfilePage.dart';

class DailyReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    return Scaffold(
      backgroundColor: ColorTheme.appBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: ColorTheme.appBg,
            title: Text(
              "Tagesberichte",
              style: _theme.textTheme.dark.headline6,
            ),
            centerTitle: false,
            iconTheme: IconThemeData(color: _theme.colors.dark),
          ),
          StreamBuilder<List<DailyReport>>(
              initialData: [],
              stream: DatabaseService.getAllDailyReports(),
              builder: (context, snapshot) {
                return SliverPadding(
                  padding: const EdgeInsets.only(bottom: 24),
                  sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                          (context, index) => DailyReportWidget(
                                dailyReport: snapshot.data[index],
                              ),
                          childCount: snapshot.data.length)),
                );
              }),
        ],
      ),
    );
  }
}
