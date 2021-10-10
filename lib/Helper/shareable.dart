import 'package:flutter/material.dart';
import 'package:one_d_m/helper/share_image.dart';

mixin Shareable {
  Future<String> getShareUrl(BuildContext? context);
  Future<InstagramImages?> getShareImages(BuildContext? context);
}
