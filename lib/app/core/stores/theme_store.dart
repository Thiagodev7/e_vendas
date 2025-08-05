import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_store.g.dart';

class ThemeStore = _ThemeStoreBase with _$ThemeStore;

abstract class _ThemeStoreBase with Store {
  static const String _themeKey = 'isDarkMode';

  @observable
  bool isDark = false;

  _ThemeStoreBase() {
    _loadTheme();
  }

  @action
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    isDark = prefs.getBool(_themeKey) ?? false;
  }

  @action
  Future<void> toggleTheme() async {
    isDark = !isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }
}