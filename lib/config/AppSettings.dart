
import 'package:oes/src/services/LocalStorage.dart';

class AppSettings {

  static AppSettings instance = AppSettings._();
  AppSettings._();

  bool optimizeUIForLargeScreens = true;
  bool enableQuestionRepeating = true;

  Future<void> load() async {
    optimizeUIForLargeScreens = bool.tryParse(await LocalStorage.instance.get("optimizeUIForLargeScreens") ?? "") ?? optimizeUIForLargeScreens;
    enableQuestionRepeating = bool.tryParse(await LocalStorage.instance.get("enableQuestionRepeating") ?? "") ?? enableQuestionRepeating;
  }

  Future<void> save() async {
    if(optimizeUIForLargeScreens != true) {
      LocalStorage.instance.set("optimizeUIForLargeScreens", optimizeUIForLargeScreens.toString());
    } else {
      LocalStorage.instance.remove("optimizeUIForLargeScreens");
    }

    if(enableQuestionRepeating != true) {
      LocalStorage.instance.set("enableQuestionRepeating", enableQuestionRepeating.toString());
    } else {
      LocalStorage.instance.remove("enableQuestionRepeating");
    }
  }
}