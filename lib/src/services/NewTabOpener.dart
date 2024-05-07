import 'package:oes/ui/assets/dialogs/Toast.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NewTabOpener {

  NewTabOpener._();

  static Future<void> open(String path) async {
    html.window.open("#$path", '_blank');
  }
}