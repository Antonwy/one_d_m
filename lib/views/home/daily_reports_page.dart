import 'package:flutter/material.dart';
import 'package:one_d_m/helper/database_service.dart';
import 'package:one_d_m/models/daily_report.dart';
import 'package:one_d_m/views/home/profile_page.dart';

class DailyReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            title: Text(
              "Tagesberichte",
            ),
            centerTitle: false,
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
                                dailyReport: snapshot.data![index],
                              ),
                          childCount: snapshot.data!.length)),
                );
              }),
        ],
      ),
    );
  }
}
