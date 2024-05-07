import 'package:universal_html/html.dart' as html;

class NewTabOpener {

  NewTabOpener._();

  static Future<void> open(String path) async {
    html.window.open("#$path", '_blank');
  }
}