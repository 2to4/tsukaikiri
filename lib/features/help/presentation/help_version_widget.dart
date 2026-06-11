// help_version_widget.dart — バージョン表示ウィジェット
// package_info_plus でバージョンを取得して表示する。
// 取得に失敗した場合は SizedBox.shrink() で非表示。

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/theme/app_colors.dart';

class HelpVersionWidget extends StatefulWidget {
  const HelpVersionWidget({super.key});

  @override
  State<HelpVersionWidget> createState() => _HelpVersionWidgetState();
}

class _HelpVersionWidgetState extends State<HelpVersionWidget> {
  String? _version;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _version = '${info.version} (${info.buildNumber})';
        _loaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _version == null) return const SizedBox.shrink();
    return Text(
      'バージョン $_version',
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.sub,
      ),
    );
  }
}
