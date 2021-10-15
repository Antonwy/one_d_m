import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:number_slide_animation/number_slide_animation.dart';
import 'package:one_d_m/components/big_button.dart';
import 'package:one_d_m/components/chart/circle_painter.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/components/margin.dart';
import 'package:one_d_m/extensions/theme_extensions.dart';
import 'package:one_d_m/helper/color_theme.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/helper/currency.dart';
import 'package:one_d_m/provider/donation_dialog_manager.dart';
import 'package:one_d_m/provider/theme_manager.dart';
import 'package:provider/provider.dart';

class DonationThankYou extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: StaggeredGridView.count(
          controller: ModalScrollController.of(context),
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            _ThankTitle(),
            _InfoContent(),
            _DonationAmountContent(),
            _CampaignImage(),
            _ChartContent(),
            _ReadMore(),
            _ThanksContent(),
            _ContinueButton(),
          ],
          staggeredTiles: [
            StaggeredTile.fit(4),
            StaggeredTile.fit(2),
            StaggeredTile.fit(2),
            StaggeredTile.fit(2),
            StaggeredTile.fit(2),
            StaggeredTile.fit(2),
            StaggeredTile.fit(2),
            StaggeredTile.fit(2),
          ],
        ),
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      child: BigButton(
        onPressed: () => Navigator.pop(
            context, context.read<DonationDialogManager>().donation),
        label: 'WEITER',
        color: Theme.of(context).canvasColor,
      ),
    );
  }
}

class _ThanksContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);

    return Material(
      borderRadius: BorderRadius.all(Radius.circular(Constants.radius)),
      color: _theme.primaryColor,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weiter so!',
              style: _theme.textTheme.headline6!
                  .copyWith(color: _theme.colorScheme.onPrimary),
            ),
            SizedBox(
              height: 6,
            ),
            Text(
                'Sammle DV, spende sie und löse mit unserer Community globale Probleme!',
                style: _theme.textTheme.bodyText2!
                    .copyWith(color: _theme.colorScheme.onPrimary)),
          ],
        ),
      ),
    );
  }
}

class _ChartContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    return Container(
      height: 240,
      width: MediaQuery.of(context).size.width,
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(Constants.radius)),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Was mit deiner Spende passiert:',
                style: _theme.textTheme.bodyText1,
              ),
              YMargin(6),
              Container(
                height: 100,
                child: Center(
                  child: PercentCircle(
                    percent: 14,
                  ),
                ),
              ),
              YMargin(12),
              FieldWidget(
                amount: '70',
                title: 'erhält das Projekt',
                color: ColorTheme.donationRed,
              ),
              YMargin(6),
              FieldWidget(
                amount: '25',
                title: 'Advertising',
                color: ColorTheme.donationLightBlue,
              ),
              YMargin(6),
              FieldWidget(
                  amount: '5',
                  title: 'erhält ODM',
                  color: ColorTheme.donationBlue)
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadMore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    DonationDialogManager ddm = context.read<DonationDialogManager>();
    return Material(
      color: _theme.primaryColor,
      borderRadius: BorderRadius.circular(Constants.radius),
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 7),
            child: AutoSizeText(
              ddm.dr!.campaignName!,
              style: _theme.textTheme.headline6!
                  .copyWith(color: _theme.colorScheme.onPrimary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: AutoSizeText(
              ddm.dr!.campaignShortDescription!,
              style: _theme.textTheme.bodyText2!
                  .copyWith(color: _theme.colorScheme.onPrimary),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Divider(color: _theme.colorScheme.onPrimary.withOpacity(.2)),
          Padding(
            padding: const EdgeInsets.only(left: 0.0, bottom: 8),
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('MEHR LESEN',
                        style: _theme.textTheme.bodyText1!
                            .copyWith(color: _theme.colorScheme.onPrimary)),
                  ),
                  onTap: () => Navigator.pop(context, ddm.donation)),
            ),
          )
        ],
      ),
    );
  }
}

class _CampaignImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DonationDialogManager ddm = context.read<DonationDialogManager>();
    return Material(
      borderRadius: BorderRadius.circular(Constants.radius),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: ddm.dr!.campaignImageUrl!,
        imageBuilder: (_, imgProvider) => Container(
          height: 240,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imgProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) => ddm.dr!.campaignBlurHash != null
            ? BlurHash(hash: ddm.dr!.campaignBlurHash!)
            : LoadingIndicator(),
      ),
    );
  }
}

class _DonationAmountContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    DonationDialogManager ddm = context.read<DonationDialogManager>();
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.all(Radius.circular(Constants.radius)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              children: [
                Text('Du hast ', style: _theme.textTheme.headline6),
                NumberSlideAnimation(
                  number: "${(ddm.amount! / ddm.dr!.unit.value).round()}",
                  duration: const Duration(seconds: 3),
                  curve: Curves.bounceIn,
                  textStyle: _theme.textTheme.headline6!.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline),
                ),
                Text(' ${ddm.dr!.unit.smiley ?? ddm.dr!.unit.name}',
                    style: _theme.textTheme.headline6),
                Text('gespendet!', style: _theme.textTheme.headline6),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Text('Das entspricht ${Currency(ddm.amount! * 5).value()}',
                style: _theme.textTheme.bodyText2!.withOpacity(.7)),
          ],
        ),
      ),
    );
  }
}

class _InfoContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeManager _theme = ThemeManager.of(context);
    DonationDialogManager ddm = context.read<DonationDialogManager>();

    bool withImage = ddm.dr!.userImageUrl != null;
    return Container(
      height: 200,
      child: Material(
        borderRadius: BorderRadius.circular(Constants.radius),
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            withImage
                ? CachedNetworkImage(
                    imageUrl: ddm.dr!.userImageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => ddm.dr!.userBlurHash != null
                        ? BlurHash(hash: ddm.dr!.userBlurHash!)
                        : Center(child: LoadingIndicator()))
                : Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    child: Icon(Icons.person, size: 30),
                  ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 150,
              child: Container(
                decoration: withImage
                    ? BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                            Colors.black,
                            Colors.black.withOpacity(0)
                          ]))
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: "${ddm.dr!.username}",
                              style: (withImage
                                      ? _theme.textTheme.light
                                      : _theme.textTheme.dark)
                                  .bodyText1
                                  .copyWith(fontWeight: FontWeight.bold)),
                          TextSpan(
                            text:
                                ', du hast die Welt ein kleines Stück besser gemacht!',
                          ),
                        ],
                        style: (withImage
                                ? _theme.textTheme.light
                                : _theme.textTheme.dark)
                            .bodyText2,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ThankTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DonationDialogManager ddm = context.read<DonationDialogManager>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 24),
      child: Row(
        children: [
          Expanded(
            child:
                Text('Vielen Dank!', style: context.theme.textTheme.headline6),
          ),
          Material(
            shape: CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.pop(context, ddm.donation),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Icon(
                  Icons.close,
                  size: 18,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class FieldWidget extends StatelessWidget {
  final String? amount;
  final String? title;
  final Color? color;

  const FieldWidget({Key? key, this.amount, this.title, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 12,
          width: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        XMargin(6),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              AutoSizeText(
                '$amount% ',
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Expanded(
                child: AutoSizeText(
                  title!,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.subtitle1!.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

class PercentCircle extends StatelessWidget {
  const PercentCircle({
    Key? key,
    required this.percent,
    this.radius = 50,
  }) : super(key: key);

  final double radius;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          '100%',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13.0,
          ),
        ),
        Container(
          height: 2 * radius,
          width: 2 * radius,
          child: CustomPaint(
            size: Size(2 * radius, 2 * radius),
            painter: CirclePainter(600, 600, startAngle: 0, colors: [
              ColorTheme.donationRed,
              ColorTheme.donationLightBlue,
              ColorTheme.donationBlue,
            ]),
          ),
        ),
      ],
    );
  }
}
