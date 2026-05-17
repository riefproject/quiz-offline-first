import 'package:flutter/material.dart';

import '../../../theme/colors_config.dart';
import '../../../widgets/components/app_button.dart';
import '../../../widgets/countdown_screen.dart';
import '../../../models/master_payload.dart';
import '../widgets/first_question_countdown.dart';
import 'client_controller.dart';

class ClientView extends StatefulWidget {
  const ClientView({super.key});

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
  }

  void _onControllerChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final isCountdown = _controller.phase == ClientPhase.countdown;

    return Scaffold(
      backgroundColor: isCountdown ? colors.primary : colors.background,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          child: isCountdown
              ? KeyedSubtree(
                  key: const ValueKey('client-countdown'),
                  child: CountdownScreen(
                    endsAtMs: _controller.countdownEndsAtMs ??
                        (DateTime.now().millisecondsSinceEpoch + 5000),
                  ),
                )
              : KeyedSubtree(
                  key: ValueKey(_controller.phase),
                  child: Column(
                    children: [
                      _buildHeader(context),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: _buildBody(context),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;

    String title;
    switch (_controller.phase) {
      case ClientPhase.scanning:
        title = 'Find a Game';
      case ClientPhase.lobby:
        title = 'Lobby';
      case ClientPhase.countdown:
        title = 'Get Ready';
      case ClientPhase.question:
        title = 'Question!';
      case ClientPhase.finished:
        title = 'Results';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: colors.textOnSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.textOnSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
=======
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

>>>>>>> 3be853f (feat: enhance quiz management with ownership checks, Quiz  UI improvements, and image store offline-first)
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
<<<<<<< HEAD
<<<<<<< HEAD
        return const SizedBox.shrink();
=======
        return _buildCountdown(context);
>>>>>>> 2edd15f (leaderboard)
=======
        return KeyedSubtree(
          key: const ValueKey('client-countdown'),
          child: _buildCountdown(context),
        );
>>>>>>> 3be853f (feat: enhance quiz management with ownership checks, Quiz  UI improvements, and image store offline-first)
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Your name',
          hintText: 'Enter a display name',
          onChanged: (v) => _controller.playerName = v,
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
                  style: textTheme.bodyMedium?.copyWith(color: colors.mutedText),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Expanded(
          child: _controller.discoveredGames.isEmpty
              ? !isScanning
                  ? Center(
                      child: Text(
                        'No games found yet.\nTap "Start Scanning" to discover nearby hosts.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(color: colors.mutedText),
                      ),
                    )
                  : const SizedBox.shrink()
              : ListView.builder(
                  itemCount: _controller.discoveredGames.length,
                  itemBuilder: (context, index) {
                    final game = _controller.discoveredGames[index];
                    return _buildGameCard(context, game);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildGameCard(BuildContext context, MasterPayload game) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_tethering_rounded, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Game #${game.gameID}',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tap to join',
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
          Icon(Icons.hourglass_top_rounded, size: 56, color: colors.primary),
          const SizedBox(height: 24),
          Text(
            'Waiting for host...',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
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
            'Question ${questionIndex + 1}',
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

    final questionIndex = payload.nextQuestion.isNotEmpty ? payload.nextQuestion.length : 1;
    final optionLabels = ['A', 'B', 'C', 'D'];
    final optionColors = [
      Colors.red.shade400,
      Colors.blue.shade400,
      Colors.yellow.shade700,
      Colors.green.shade400,
    ];

    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
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
                      'Question ${questionIndex + 1}',
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
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Options grid — shrinkWrapped so the whole question column can scroll on small screens.
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Material(
                    color: optionColors[index],
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => _controller.submitAnswer(index),
                      borderRadius: BorderRadius.circular(16),
                      child: Center(
                        child: Text(
                          optionLabels[index],
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

              const SizedBox(height: 24),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFinished(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_rounded, size: 64, color: colors.secondary),
          const SizedBox(height: 24),
          Text(
            'Game Over!',
            style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'You submitted ${_controller.myAnswers.length} answer(s).',
            style: textTheme.bodyLarge?.copyWith(color: colors.mutedText),
          ),
          const SizedBox(height: 32),
          AppButton.primary(
            label: 'Done',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: colors.mutedText.withValues(alpha: 0.5)),
            filled: true,
            fillColor: colors.surfaceLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ],
    );
  }
}