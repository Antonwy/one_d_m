import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:one_d_m/components/loading_indicator.dart';
import 'package:one_d_m/helper/constants.dart';
import 'package:one_d_m/models/donation_request.dart';
import 'package:one_d_m/provider/donation_dialog_manager.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart' as rive;

class DonationDialogHeading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);

    return Consumer<DonationDialogManager>(builder: (context, ddm, child) {
      DonationRequest? dr = ddm.dr;

      if (ddm.initialLoading!)
        return Container(
          width: double.infinity,
          height: 220,
          child: Center(
              child: LoadingIndicator(
            message: "Laden...",
          )),
        );

      if (dr!.animationUrl != null)
        return FutureBuilder<rive.Artboard?>(
            future: ddm.artboardFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Container(
                  width: double.infinity,
                  height: 220,
                  child: Center(child: LoadingIndicator()),
                );

              ddm.artboardController = snapshot.data;

              return ClipRRect(
                borderRadius: BorderRadius.circular(18.0),
                child: Container(
                    width: double.infinity,
                    height: 220,
                    child: !snapshot.hasData
                        ? SizedBox.shrink()
                        : rive.Rive(
                            fit: BoxFit.fitWidth,
                            artboard: ddm.artboardController!,
                          )),
              );
            });

      String? blurHash = dr.sessionBlurHash ?? dr.campaignBlurHash;
      String? imageUrl = dr.sessionImageUrl ?? dr.campaignImageUrl;
      String? name = dr.sessionName ?? dr.campaignName;

      return LayoutBuilder(builder: (context, constraints) {
        return ClipRRect(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(Constants.radius)),
          child: Stack(
            children: [
              CachedNetworkImage(
                height: 220,
                width: double.infinity,
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => blurHash != null
                    ? BlurHash(hash: blurHash)
                    : Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: LoadingIndicator(),
                        ),
                      ),
              ),
              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                          _theme.cardColor,
                          _theme.cardColor.withOpacity(0)
                        ])),
                  )),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: constraints.maxWidth,
                      child: AutoSizeText(
                        name!,
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: _theme.textTheme.headline5!.copyWith(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'by ${dr.organizationName}',
                      style: _theme.textTheme.bodyText2!.copyWith(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      });
    });
  }
}
