// lib/app/modules/totem/services/kiosk_service.dart
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class KioskService {
  /// Modo tótem em **retrato** (se precisar em outra tela)
  static Future<void> enterKioskPortrait() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await WakelockPlus.enable();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  /// Modo tótem em **paisagem** (landscape) — o que você pediu
  static Future<void> enterKioskLandscape() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await WakelockPlus.enable();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// Sai do modo tótem e restaura as orientações/UX padrão
  static Future<void> exitKiosk() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await WakelockPlus.disable();
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }
}