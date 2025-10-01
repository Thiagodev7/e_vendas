import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;

class VersionBadge extends StatefulWidget {
  final bool showBuildNumber;
  final bool showCommit;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  const VersionBadge({
    super.key,
    this.showBuildNumber = true,
    this.showCommit = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.backgroundColor,
    this.textStyle,
  });

  @override
  State<VersionBadge> createState() => _VersionBadgeState();
}

class _VersionBadgeState extends State<VersionBadge> {
  String? _label;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final version = info.version;
      final build = info.buildNumber;

      // Opcional: commit via --dart-define=GIT_SHA=<hash>
      final fullSha = const String.fromEnvironment('GIT_SHA', defaultValue: '');
      final shortSha = (fullSha.isNotEmpty && fullSha.length >= 7)
          ? fullSha.substring(0, 7)
          : '';

      final parts = <String>[
        'v$version',
        if (widget.showBuildNumber) '+$build',
        if (widget.showCommit && shortSha.isNotEmpty) '· $shortSha',
        if (!kReleaseMode) ' (DEBUG)',
      ];

      setState(() => _label = parts.join(''));
    } catch (_) {
      setState(() => _label = 'v?');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ??
        Theme.of(context).colorScheme.surface.withOpacity(0.85);
    final textStyle = widget.textStyle ??
        TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
        );

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: widget.borderRadius,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      padding: widget.padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 12, color: textStyle.color),
          const SizedBox(width: 4),
          Text(_label ?? 'v…', style: textStyle),
        ],
      ),
    );
  }
}