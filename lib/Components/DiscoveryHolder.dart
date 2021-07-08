import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:one_d_m/Helper/ThemeManager.dart';

typedef DiscoveryNext = Future<bool> Function();

abstract class DiscoveryHolder extends StatelessWidget {
  static const Iterable<String> features = <String>{
    _DiscoverShowAd.featureId,
    _DiscoverSessions.featureId,
    _DiscoverCreateSessions.featureId,
    _DiscoverProjectsHome.featureId,
  };
  static const Iterable<String> sessionCampaignFeatures = <String>{
    _DiscoverDonateButton.featureId,
    _DiscoverShareButton.featureId,
  };
  static const Iterable<String> donationDialogFeatures = <String>{
    _DiscoverDonateAdd.featureId,
    _DiscoverDonateSub.featureId,
    _DiscoverSupportButton.featureId,
  };

  final Widget child, tapTarget;
  final DiscoveryNext next;
  ThemeManager _theme;

  DiscoveryHolder(
      {Key key, this.child, this.tapTarget = const Icon(Icons.add), this.next})
      : super(key: key);

  factory DiscoveryHolder.showAd(
          {int maxDVs, Widget child, Widget tapTarget, DiscoveryNext next}) =>
      _DiscoverShowAd(
        child: child,
        tapTarget: tapTarget,
        maxDVs: maxDVs,
        next: next,
      );

  factory DiscoveryHolder.sessions(
          {Widget child, Widget tapTarget, DiscoveryNext next}) =>
      _DiscoverSessions(
        child: child,
        tapTarget: tapTarget,
        next: next,
      );

  factory DiscoveryHolder.createSession(
          {Widget child, Widget tapTarget, DiscoveryNext next}) =>
      _DiscoverCreateSessions(
        child: child,
        tapTarget: tapTarget,
        next: next,
      );

  factory DiscoveryHolder.projectHome(
          {Widget child, Widget tapTarget, DiscoveryNext next}) =>
      _DiscoverProjectsHome(
        child: child,
        tapTarget: tapTarget,
        next: next,
      );

  factory DiscoveryHolder.donateButton(
          {Widget child, Widget tapTarget, DiscoveryNext next}) =>
      _DiscoverDonateButton(
        child: child,
        tapTarget: tapTarget,
        next: next,
      );

  factory DiscoveryHolder.shareButton(
          {Widget child, Widget tapTarget, DiscoveryNext next}) =>
      _DiscoverShareButton(
        child: child,
        tapTarget: tapTarget,
        next: next,
      );

  factory DiscoveryHolder.donationAdd(
          {Widget child, Widget tapTarget, DiscoveryNext next}) =>
      _DiscoverDonateAdd(
        child: child,
        tapTarget: tapTarget,
        next: next,
      );

  factory DiscoveryHolder.donationSub(
          {Widget child, Widget tapTarget, DiscoveryNext next}) =>
      _DiscoverDonateSub(
        child: child,
        tapTarget: tapTarget,
        next: next,
      );

  factory DiscoveryHolder.supportButton(
          {Widget child, Widget tapTarget, DiscoveryNext next}) =>
      _DiscoverSupportButton(
        child: child,
        tapTarget: tapTarget,
        next: next,
      );

  @override
  Widget build(BuildContext context) {
    _theme = ThemeManager.of(context);
    return buildDiscover(context);
  }

  Widget buildDiscover(BuildContext context);
}

class _DiscoverShowAd extends DiscoveryHolder {
  static const String featureId = 'collect_dv';
  final int maxDVs;

  _DiscoverShowAd(
      {this.maxDVs,
      @required Widget child,
      @required Widget tapTarget,
      DiscoveryNext next})
      : super(child: child, tapTarget: tapTarget, next: next);

  @override
  Widget buildDiscover(BuildContext context) {
    return DescribedFeatureOverlay(
      featureId: featureId,
      tapTarget: tapTarget,
      title: Text('Donation Votes einsammeln'),
      description: Text(
          'Drücke auf das Play Icon um Werbung anzuschauen und einen DV einzusammeln.\n\nDu kannst pro Tag $maxDVs einsammeln!'),
      backgroundColor: _theme.colors.contrast,
      targetColor: _theme.colors.dark,
      textColor: _theme.colors.textOnContrast,
      contentLocation: ContentLocation.below,
      child: child,
      onComplete: next,
    );
  }
}

class _DiscoverSessions extends DiscoveryHolder {
  static const String featureId = 'session';

  _DiscoverSessions(
      {@required Widget child, @required Widget tapTarget, DiscoveryNext next})
      : super(child: child, tapTarget: tapTarget, next: next);

  @override
  Widget buildDiscover(BuildContext context) {
    return DescribedFeatureOverlay(
      featureId: featureId,
      tapTarget: tapTarget,
      title: Padding(
        padding: const EdgeInsets.only(top: 18.0),
        child: Text('Sessions'),
      ),
      description: Text(
          'Eine Session ist ein Ort wo ein oder mehrere Menschen zusammen an ein Projekt spenden können.'),
      backgroundColor: _theme.colors.contrast,
      targetColor: _theme.colors.dark,
      textColor: _theme.colors.textOnContrast,
      overflowMode: OverflowMode.extendBackground,
      contentLocation: ContentLocation.below,
      child: child,
      onComplete: next,
    );
  }
}

class _DiscoverCreateSessions extends DiscoveryHolder {
  static const String featureId = 'create_session';

  _DiscoverCreateSessions(
      {@required Widget child, @required Widget tapTarget, DiscoveryNext next})
      : super(child: child, tapTarget: tapTarget, next: next);

  @override
  Widget buildDiscover(BuildContext context) {
    return DescribedFeatureOverlay(
      featureId: featureId,
      tapTarget: tapTarget,
      title: Padding(
        padding: const EdgeInsets.only(top: 18.0),
        child: Text('Sessions erstellen'),
      ),
      description: Text(
          'Auch Du kannst Sessions erstellen und bspw. zusammen mit deinen Freunden Geld für ein Projekt sammeln.'),
      backgroundColor: _theme.colors.contrast,
      targetColor: _theme.colors.dark,
      textColor: _theme.colors.textOnContrast,
      overflowMode: OverflowMode.extendBackground,
      contentLocation: ContentLocation.below,
      child: child,
      onComplete: next,
    );
  }
}

class _DiscoverProjectsHome extends DiscoveryHolder {
  static const String featureId = 'discover_projects_home';

  _DiscoverProjectsHome(
      {@required Widget child, @required Widget tapTarget, DiscoveryNext next})
      : super(child: child, tapTarget: tapTarget, next: next);

  @override
  Widget buildDiscover(BuildContext context) {
    return DescribedFeatureOverlay(
      featureId: featureId,
      tapTarget: tapTarget,
      title: Padding(
        padding: const EdgeInsets.only(top: 18.0),
        child: Text('Projekte'),
      ),
      description: Text(
          'Hinter jedem Projekt steckt eine Hilfsorganisation die auf unsere Spenden angewiesen ist. Dabei kannst du diese Projekte unterstützen und zu einer besseren Welt beitragen.'),
      backgroundColor: _theme.colors.contrast,
      targetColor: _theme.colors.dark,
      textColor: _theme.colors.textOnContrast,
      overflowMode: OverflowMode.extendBackground,
      contentLocation: ContentLocation.below,
      child: child,
      onComplete: next,
    );
  }
}

class _DiscoverDonateButton extends DiscoveryHolder {
  static const String featureId = 'discover_donate_button';

  _DiscoverDonateButton(
      {@required Widget child, @required Widget tapTarget, DiscoveryNext next})
      : super(child: child, tapTarget: tapTarget, next: next);

  @override
  Widget buildDiscover(BuildContext context) {
    return DescribedFeatureOverlay(
      featureId: featureId,
      tapTarget: tapTarget,
      title: Padding(
        padding: const EdgeInsets.only(top: 18.0),
        child: Text('Unterstützen'),
      ),
      description: Text(
          'Drücke auf den Unterstützen Knopf und wähle einen beliebigen Betrag. Solltest du nicht genügend Donation Votes haben, gehe auf die Hauptseite und sammle neue Votes ein!'),
      backgroundColor: _theme.colors.contrast,
      targetColor: _theme.colors.dark,
      textColor: _theme.colors.textOnContrast,
      child: child,
      onComplete: next,
    );
  }
}

class _DiscoverShareButton extends DiscoveryHolder {
  static const String featureId = 'discover_share_button';

  _DiscoverShareButton(
      {@required Widget child, @required Widget tapTarget, DiscoveryNext next})
      : super(child: child, tapTarget: tapTarget, next: next);

  @override
  Widget buildDiscover(BuildContext context) {
    return DescribedFeatureOverlay(
      featureId: featureId,
      tapTarget: tapTarget,
      title: Padding(
        padding: const EdgeInsets.only(top: 18.0),
        child: Text('Teilen'),
      ),
      description: Text(
          'Teile Projekte und Sessions mit deinen Freunden, damit ihr gemeinsam eine Organisation unterstützen könnt!'),
      backgroundColor: _theme.colors.contrast,
      targetColor: _theme.colors.dark,
      textColor: _theme.colors.textOnContrast,
      overflowMode: OverflowMode.extendBackground,
      contentLocation: ContentLocation.below,
      child: child,
      onComplete: next,
    );
  }
}

class _DiscoverDonateAdd extends DiscoveryHolder {
  static const String featureId = 'discover_donate_add';
  final String unit;

  _DiscoverDonateAdd(
      {@required Widget child,
      @required Widget tapTarget,
      DiscoveryNext next,
      this.unit})
      : super(child: child, tapTarget: tapTarget, next: next);

  @override
  Widget buildDiscover(BuildContext context) {
    return DescribedFeatureOverlay(
      featureId: featureId,
      tapTarget: tapTarget,
      title: Padding(
        padding: const EdgeInsets.only(top: 18.0),
        child: Text('Mehr ${unit ?? 'DVs'} Spenden'),
      ),
      description:
          Text('Klicke auf das + um mehr ${unit ?? 'DVs'} zu spenden!'),
      backgroundColor: _theme.colors.contrast,
      targetColor: _theme.colors.dark,
      textColor: _theme.colors.textOnContrast,
      overflowMode: OverflowMode.extendBackground,
      child: child,
      onComplete: next,
    );
  }
}

class _DiscoverDonateSub extends DiscoveryHolder {
  static const String featureId = 'discover_donate_sub';
  final String unit;

  _DiscoverDonateSub(
      {@required Widget child,
      @required Widget tapTarget,
      DiscoveryNext next,
      this.unit})
      : super(child: child, tapTarget: tapTarget, next: next);

  @override
  Widget buildDiscover(BuildContext context) {
    return DescribedFeatureOverlay(
      featureId: featureId,
      tapTarget: tapTarget,
      title: Padding(
        padding: const EdgeInsets.only(top: 18.0),
        child: Text('Weniger ${unit ?? 'DVs'} spenden'),
      ),
      description:
          Text('Klicke auf das - um weniger ${unit ?? 'DVs'} zu spenden!'),
      backgroundColor: _theme.colors.contrast,
      targetColor: _theme.colors.dark,
      textColor: _theme.colors.textOnContrast,
      overflowMode: OverflowMode.extendBackground,
      child: child,
      onComplete: next,
    );
  }
}

class _DiscoverSupportButton extends DiscoveryHolder {
  static const String featureId = 'discover_support_button';

  _DiscoverSupportButton(
      {@required Widget child, @required Widget tapTarget, DiscoveryNext next})
      : super(child: child, tapTarget: tapTarget, next: next);

  @override
  Widget buildDiscover(BuildContext context) {
    return DescribedFeatureOverlay(
      featureId: featureId,
      tapTarget: tapTarget,
      title: Padding(
        padding: const EdgeInsets.only(top: 18.0),
        child: Text('Unterstützen'),
      ),
      description: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Text('Klicke auf Support um die ausgewählten DVs zu spenden!'),
      ),
      backgroundColor: _theme.colors.contrast,
      targetColor: _theme.colors.dark,
      textColor: _theme.colors.textOnContrast,
      child: child,
      onComplete: next,
    );
  }
}
