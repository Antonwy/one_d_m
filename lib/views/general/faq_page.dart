import 'package:flutter/material.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/helper/color_theme.dart';

class FaqPage extends StatelessWidget {
  late TextTheme _textTheme;

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Image.asset(
                      "assets/images/ic_onedm.png",
                      height: 180,
                      width: 180,
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    "One Dollar Movement",
                    style: _textTheme.bodyText1!,
                  ),
                  Text(
                    "FAQ",
                    style: _textTheme.headline6!.copyWith(fontSize: 28),
                  ),
                  Text(
                    "Häufig gestellte Fragen.",
                    style: _textTheme.caption!.withOpacity(.6),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
            Faq faq = Faq.faqs[index];
            return ExpansionTile(
              title: Text(
                faq.question,
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Text(
                    faq.answer,
                  ),
                )
              ],
            );
          }, childCount: Faq.faqs.length))
        ],
      ),
    );
  }
}

class Faq {
  String question, answer;

  static List<Faq> faqs = [
    Faq("Was ist One Dollar Movement?",
        "ODM macht das Unterstützen von wohltätigen Organisationen einfach, schnell und für jeden zugänglich. Dabei haben wir uns für ein werbebasiertes Geschäftsmodell entschieden. Durch jede Ad-Impression erhalten wir Geld von unseren Werbenetzwerken. Das eingenommene Geld wird prozentual, je nach Aktivität, auf die Nutzer verteilt und am Ende des Monats an die von den Nutzern ausgewählten Projekte/ Organisationen überwiesen. Dabei befindet sich das Geld zu keinem Zeitpunkt auf dem Konto der Nutzer. Dadurch werden unnötigen Transaktionen zwischen den Nutzern und One Dollar Movement vermieden."),
    Faq("Sind die Projekte zertifiziert?",
        "Jede Organisation an die auf unserer Plattform gespendet werden kann, ist von uns sorgfältig ausgewählt und zertifiziert worden."),
  ];

  Faq(this.question, this.answer);
}
