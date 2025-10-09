package com.example.e_vendas

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    // Só se você sobrescrever:
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // NÃO chame GeneratedPluginRegistrant manualmente em projetos recentes.
        // Se você usa "cached engine", garanta que a engine seja registrada onde for criada.
    }
}