// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ThemeStore on _ThemeStoreBase, Store {
  late final _$isDarkAtom =
      Atom(name: '_ThemeStoreBase.isDark', context: context);

  @override
  bool get isDark {
    _$isDarkAtom.reportRead();
    return super.isDark;
  }

  @override
  set isDark(bool value) {
    _$isDarkAtom.reportWrite(value, super.isDark, () {
      super.isDark = value;
    });
  }

  late final _$_loadThemeAsyncAction =
      AsyncAction('_ThemeStoreBase._loadTheme', context: context);

  @override
  Future<void> _loadTheme() {
    return _$_loadThemeAsyncAction.run(() => super._loadTheme());
  }

  late final _$toggleThemeAsyncAction =
      AsyncAction('_ThemeStoreBase.toggleTheme', context: context);

  @override
  Future<void> toggleTheme() {
    return _$toggleThemeAsyncAction.run(() => super.toggleTheme());
  }

  @override
  String toString() {
    return '''
isDark: ${isDark}
    ''';
  }
}
