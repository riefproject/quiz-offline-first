import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../../theme/colors_config.dart';
import '../../../widgets/components/app_button.dart';
import '../../../models/master_payload.dart';
import '../widgets/first_question_countdown.dart';
import 'client_controller.dart';
import 'package:lottie/lottie.dart';

class ClientView extends StatefulWidget {
  final ValueChanged<ClientPhase>? onPhaseChanged;

  const ClientView({super.key, this.onPhaseChanged});

  @override
  State<ClientView> createState() => _ClientViewState();
}

class _ClientViewState extends State<ClientView> {
  late ClientController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ClientController();
    _controller.addListener(_onControllerChange);
    final session = AuthService.currentSession;
    if (session != null) {
      _controller.playerName = session.displayName;
    }
  }

  void _onControllerChange() {
    if (mounted) {
      setState(() {});
      widget.onPhaseChanged?.call(_controller.phase);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: _buildPhase(context),
    );
  }

  Widget _buildPhase(BuildContext context) {
    final isFirstQuestionCountdown =
        _controller.phase == ClientPhase.countdown &&
        _controller.myAnswers.isEmpty;

    if (isFirstQuestionCountdown) {
      return FirstQuestionCountdown(
        key: const ValueKey('client-first-countdown'),
        remainingMs: _controller.countdownRemainingMs,
        questionLabel: 'Question 1',
      );
    }

    switch (_controller.phase) {
      case ClientPhase.scanning:
        return KeyedSubtree(
          key: const ValueKey('client-scanning'),
          child: _buildScanning(context),
        );
      case ClientPhase.lobby:
        return KeyedSubtree(
          key: const ValueKey('client-lobby'),
          child: _buildLobby(context),
        );
      case ClientPhase.countdown:
        return KeyedSubtree(
          key: const ValueKey('client-countdown'),
          child: _buildCountdown(context),
        );
      case ClientPhase.question:
        return KeyedSubtree(
          key: const ValueKey('client-question'),
          child: _buildQuestion(context),
        );
      case ClientPhase.finished:
        return KeyedSubtree(
          key: const ValueKey('client-finished'),
          child: _buildFinished(context),
        );
    }
  }

  Widget _buildScanning(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;
    final isScanning = _controller.isScanning;
    final session = AuthService.currentSession;

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colors.primary.withValues(alpha: 0.14),
                child: Text(
                  _buildInitials(session?.displayName ?? 'U'),
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session?.displayName ?? 'User',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Ready to join a live quiz',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'AVAILABLE GAMES',
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.mutedText,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        if (isScanning)
          AppButton.primary(label: 'Scanning...', onPressed: null)
        else
          AppButton.primary(
            label: 'Start Scanning',
            onPressed: () => _controller.startScan(),
          ),
        if (_controller.scanError != null) ...[
          const SizedBox(height: 8),
          Text(
            _controller.scanError!,
            style: textTheme.bodySmall?.copyWith(color: Colors.redAccent),
          ),
        ],
        if (isScanning) ...[
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Looking for nearby games...',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (_controller.discoveredGames.isEmpty && !isScanning)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(
                    Icons.wifi_find_rounded,
                    size: 48,
                    color: colors.mutedText.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No games found yet.\nMake sure you\'re connected to\nthe same Wi-Fi or hotspot\nas the quiz host.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ..._controller.discoveredGames.map(
          (game) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildGameCard(context, game),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildGameCard(BuildContext context, MasterPayload game) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.wifi_tethering_rounded, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Game #${game.gameID}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${game.questionCount} questions • Tap to join',
                  style: textTheme.bodySmall?.copyWith(color: colors.mutedText),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.login_rounded, color: colors.primary),
            onPressed: () => _controller.joinGame(game),
          ),
        ],
      ),
    );
  }

  Widget _buildLobby(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/waiting.json',
            height: 200,
            width: 200,
          ),
          const SizedBox(height: 24),
          Text(
            'Waiting for host...',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Game #${_controller.joinedGameId}',
            style: textTheme.bodyLarge?.copyWith(color: colors.mutedText),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdown(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;
    final seconds = (_controller.countdownRemainingMs / 1000).ceil();
    final questionIndex = _controller.myAnswers.length;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Question ${questionIndex + 1} of ${_controller.currentPayload?.questionCount ?? 0}',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.mutedText,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    value: _controller.countdownRemainingMs / 5000,
                    backgroundColor: colors.outline,
                    color: colors.primary,
                  ),
                ),
                Text(
                  '$seconds',
                  style: textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Get Ready!',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;
    final payload = _controller.currentPayload;
    if (payload == null) return const SizedBox.shrink();

    final info = _controller.currentQuestionInfo;
    if (info == null) return const SizedBox.shrink();

    final questionIndex = _controller.myAnswers.length;
    final choiceCount = info.choicesCount;
    final optionColors = [
      Colors.red.shade400,
      Colors.blue.shade400,
      Colors.yellow.shade700,
      Colors.green.shade400,
    ];

    final seconds = (_controller.remainingTimeMs / 1000).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                'Question ${questionIndex + 1} of ${payload.questionCount}',
                style: textTheme.labelLarge?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Choose your answer',
                style: textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${seconds}s',
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemCount: choiceCount,
            itemBuilder: (context, index) {
              return Material(
                color: optionColors[index],
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => _controller.submitAnswer(index),
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index),
                      style: textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFinished(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;
    final lost = _controller.hostDisconnected;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            lost ? Icons.link_off_rounded : Icons.emoji_events_rounded,
            size: 64,
            color: lost ? Colors.redAccent.shade200 : colors.secondary,
          ),
          const SizedBox(height: 24),
          Text(
            lost ? 'Host Disconnected' : 'Game Over!',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lost
                ? 'The host has left the game.\nYou submitted ${_controller.myAnswers.length} answer(s).'
                : 'You submitted ${_controller.myAnswers.length} answer(s).',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(color: colors.mutedText),
          ),
          const SizedBox(height: 32),
          AppButton.primary(
            label: 'Done',
            onPressed: () {
              _controller = ClientController();
              final session = AuthService.currentSession;
              if (session != null) {
                _controller.playerName = session.displayName;
              }
              _controller.addListener(_onControllerChange);
              widget.onPhaseChanged?.call(_controller.phase);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  String _buildInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
