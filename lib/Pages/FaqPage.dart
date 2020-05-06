import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ColorTheme.dart';

class FaqPage extends StatelessWidget {
  TextTheme _textTheme;

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: ColorTheme.blue,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: ColorTheme.blue,
            elevation: 0,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "One Dollar Movement",
                    style: _textTheme.body1.copyWith(color: Colors.white),
                  ),
                  Text(
                    "FAQ",
                    style: _textTheme.title
                        .copyWith(color: Colors.white, fontSize: 28),
                  ),
                  Text(
                    "Häufig gestellte Fragen.",
                    style: _textTheme.caption.copyWith(color: Colors.white60),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
            Faq faq = Faq.faqs[index];
            return Theme(
              data: ThemeData(
                  accentColor: Colors.white,
                  unselectedWidgetColor: Colors.white.withOpacity(.7)),
              child: ExpansionTile(
                title: Text(
                  faq.question,
                  style: TextStyle(color: Colors.white),
                ),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text(
                      faq.answer,
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                ],
              ),
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
        "One Dollar Movement ist eine Spenden App, die es ermöglicht schnell und einfach kleine Geldbeträge an wohltätige Zwecke zu spenden. Dabei fokussieren wir uns besonders auf die junge Generation, um aktuelle und bevorstehende Probleme zu lösen und finanziell zu unterstützen."),
    Faq("Was passiert mit meinen Spenden?",
        "Deine Spenden werden auf Deinem Account gesammelt und dann in einer Überweisung am Ende des Monats auf das One Dollar Movement Bankkonto übertragen. Ein Donation Credit entspricht dabei 10 Cent. Nachdem wir den Eingang des Geldes registrieren, werden die entsprechenden Beträge an die jeweiligen Organisationen überwiesen."),
    Faq("Sind die Projekte zertifiziert?",
        "Jede Organisation an die auf unserer Plattform gespendet werden kann, ist von uns sorgfältig ausgewählt und zertifiziert worden."),
  ];

  Faq(this.question, this.answer);
}
