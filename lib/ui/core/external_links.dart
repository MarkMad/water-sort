import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openExternalLink(Uri url) async {
  for (final mode in [
    LaunchMode.externalApplication,
    LaunchMode.platformDefault,
  ]) {
    try {
      if (await launchUrl(url, mode: mode)) return;
    } catch (error) {
      debugPrint('Could not open $url with $mode: $error');
    }
  }
}
