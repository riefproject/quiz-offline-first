import 'package:flutter/material.dart';

import '../../theme/colors_config.dart';

class AppShell extends StatelessWidget {
  final Widget body;
  final Widget? header;
  final Widget? bottomNavigationBar;
  final bool showHeader;
  final bool showBottomNavigation;
  final EdgeInsetsGeometry bodyPadding;
  final EdgeInsetsGeometry headerPadding;
  final EdgeInsetsGeometry bottomNavigationPadding;
  final Gradient? backgroundGradient;

  const AppShell({
    super.key,
    required this.body,
    this.header,
    this.bottomNavigationBar,
    this.showHeader = true,
    this.showBottomNavigation = true,
    this.bodyPadding = const EdgeInsets.fromLTRB(20, 0, 20, 20),
    this.headerPadding = const EdgeInsets.fromLTRB(20, 18, 20, 12),
    this.bottomNavigationPadding = const EdgeInsets.fromLTRB(20, 0, 20, 20),
    this.backgroundGradient,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: backgroundGradient ??
              LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.background,
                  colors.backgroundSoft,
                ],
              ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (showHeader && header != null)
                Padding(
                  padding: headerPadding,
                  child: header,
                ),
              Expanded(
                child: Padding(
                  padding: bodyPadding,
                  child: body,
                ),
              ),
              if (showBottomNavigation && bottomNavigationBar != null)
                Padding(
                  padding: bottomNavigationPadding,
                  child: bottomNavigationBar,
                ),
            ],
          ),
        ),
      ),
    );
  }
}