import 'package:flutter/material.dart';

import '../../theme/colors_config.dart';
import '../../widgets/components/under_construction_widget.dart';
import '../../widgets/layout/app_shell.dart';
import '../../widgets/layout/app_top_header.dart';

class LobbySessionPage extends StatelessWidget {
  const LobbySessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;

    return AppShell(
      header: AppTopHeader(
        title: 'Quiz Lobby',
        subtitle: 'Start and manage your session',
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.textOnSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const UnderConstructionWidget(
        title: 'Lobby & Session',
        icon: Icons.sports_esports_rounded,
      ),
    );
  }
}
