import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/colors_config.dart';
import '../../../widgets/components/app_button.dart';
import 'host_controller.dart';

class HostView extends StatefulWidget {
  final String quizId;

  const HostView({super.key, required this.quizId});

  @override
  State<HostView> createState() => _HostViewState();
}

class _HostViewState extends State<HostView> {
  late HostController _controller;
  bool _isLandscape = false;

  void _toggleOrientation() {
    setState(() {
      _isLandscape = !_isLandscape;
      if (_isLandscape) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = HostController(quizId: widget.quizId);
    _controller.addListener(_onControllerChange);
  }

  void _onControllerChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _controller.removeListener(_onControllerChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;

    String title;
    switch (_controller.phase) {
      case HostPhase.lobby:
        title = 'Host Lobby';
      case HostPhase.countdown:
        title = 'Get Ready';
      case HostPhase.question:
        title = 'Question ${_controller.currentQuestionIndex + 1}';
      case HostPhase.answerReveal:
        title = 'Answer Reveal';
      case HostPhase.leaderboard:
        title = 'Leaderboard';
      case HostPhase.results:
        title = 'Results';
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            if (!_isLandscape)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: colors.textOnSurface,
                      ),
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
                    IconButton(
                      icon: Icon(
                        Icons.stay_current_landscape,
                        color: colors.textOnSurface,
                      ),
                      onPressed: _toggleOrientation,
                    ),
                    if (_controller.phase == HostPhase.lobby)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _controller.isAdvertising
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          _controller.isAdvertising ? 'LIVE' : 'OFFLINE',
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: _controller.isAdvertising
                                ? Colors.green.shade800
                                : Colors.orange.shade800,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Expanded(
              child: Padding(
                padding: MediaQuery.of(context).orientation == Orientation.landscape
                    ? const EdgeInsets.fromLTRB(16, 16, 16, 8)
                    : const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Stack(
                  children: [
                    _buildBody(context),
                    if (_isLandscape)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.stay_current_portrait, color: colors.textOnSurface, size: 20),
                            onPressed: _toggleOrientation,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_controller.phase) {
      case HostPhase.lobby:
        return _buildLobby(context);
      case HostPhase.countdown:
        return _buildCountdown(context);
      case HostPhase.question:
        return _buildQuestion(context);
      case HostPhase.answerReveal:
        return _buildAnswerReveal(context);
      case HostPhase.leaderboard:
        return _buildLeaderboard(context);
      case HostPhase.results:
        return _buildResults(context);
    }
  }

  Widget _buildLobby(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_controller.gameId != 0) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'GAME CODE',
                  style: textTheme.labelLarge?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_controller.gameId}',
                  style: textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Share this code with participants',
                  style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        Text(
          'PARTICIPANTS (${_controller.participants.length})',
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.mutedText,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _controller.participants.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        size: 48,
                        color: colors.mutedText,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Waiting for participants to join...',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.mutedText,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _controller.participants.length,
                  itemBuilder: (context, index) {
                    final entry = _controller.participants.entries.elementAt(
                      index,
                    );
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.surfaceLowest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: colors.primary.withValues(
                              alpha: 0.14,
                            ),
                            child: Text(
                              entry.value.isNotEmpty
                                  ? entry.value[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: colors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.green.shade400,
                            size: 20,
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 16),
        if (_controller.gameId == 0)
          AppButton.primary(
            label: 'Start Game',
            onPressed: () => _controller.startGame(),
          )
        else
          AppButton.primary(
            label: 'Send First Question',
            onPressed: () => _controller.nextQuestion(),
          ),
      ],
    );
  }

  Widget _buildCountdown(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;
    final q = _controller.currentQuestion;
    final seconds = (_controller.countdownRemainingMs / 1000).ceil();

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
                'Question ${_controller.currentQuestionIndex + 1} of ${_controller.questions.length}',
                style: textTheme.labelLarge?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                q.text,
                style: textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              if ((q.localPhotoPath != null && q.localPhotoPath!.isNotEmpty) || (q.photoUrl != null && q.photoUrl!.isNotEmpty))
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: q.localPhotoPath != null && q.localPhotoPath!.isNotEmpty
                        ? Image.file(
                            File(q.localPhotoPath!),
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Image.network(
                              q.photoUrl ?? '',
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const SizedBox(height: 180, child: Center(child: Icon(Icons.broken_image, color: Colors.white))),
                            ),
                          )
                        : Image.network(
                            q.photoUrl!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(q.options.length, (i) {
          final optionColors = [
            Colors.red.shade400,
            Colors.blue.shade400,
            Colors.yellow.shade700,
            Colors.green.shade400,
          ];
          final optionIcons = [
            Icons.change_history_rounded,
            Icons.diamond_rounded,
            Icons.circle,
            Icons.square_rounded,
          ];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildPortraitOptionButton(i, q.options[i], optionColors[i], optionIcons[i], textTheme),
          );
        }),
        const Spacer(),
        Center(
          child: SizedBox(
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
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surfaceLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.people_rounded, size: 18, color: colors.mutedText),
              const SizedBox(width: 8),
              Text(
                '${_controller.participants.length} participant(s) ready',
                style: textTheme.bodyMedium?.copyWith(color: colors.mutedText),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppButton.primary(
          label: 'Skip Countdown',
          onPressed: () => _controller.skipCountdown(),
        ),
      ],
    );
  }

  Widget _buildPortraitOptionButton(int index, String text, Color color, IconData icon, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeOptionButton(int index, String text, Color color, IconData icon, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeQuestion(BuildContext context, dynamic q, List<Color> optionColors, List<IconData> optionIcons) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Question Text (Top)
        Center(
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              q.text,
              style: textTheme.titleMedium?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        // 2. Image (Middle)
        Expanded(
          flex: 6,
          child: (q.localPhotoPath != null && q.localPhotoPath!.isNotEmpty) || (q.photoUrl != null && q.photoUrl!.isNotEmpty)
              ? Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: q.localPhotoPath != null && q.localPhotoPath!.isNotEmpty
                          ? Image.file(
                              File(q.localPhotoPath!),
                              fit: BoxFit.contain,
                              errorBuilder: (ctx, err, stack) => Image.network(
                                q.photoUrl ?? '',
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                              ),
                            )
                          : Image.network(
                              q.photoUrl!,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                )
              : const SizedBox(),
        ),

        const SizedBox(height: 8),

        // 3. Options (Bottom)
        Expanded(
          flex: 5,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _buildLandscapeOptionButton(0, q.options.isNotEmpty ? q.options[0] : '', optionColors[0], optionIcons[0], textTheme)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildLandscapeOptionButton(1, q.options.length > 1 ? q.options[1] : '', optionColors[1], optionIcons[1], textTheme)),
                  ],
                ),
              ),
              if (q.options.length > 2) ...[
                const SizedBox(height: 8),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _buildLandscapeOptionButton(2, q.options[2], optionColors[2], optionIcons[2], textTheme)),
                      const SizedBox(width: 8),
                      if (q.options.length > 3)
                        Expanded(child: _buildLandscapeOptionButton(3, q.options[3], optionColors[3], optionIcons[3], textTheme))
                      else
                        const Spacer(),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 8),
        // 4. Bottom bar (Participants + Next Button)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.people_rounded, size: 24, color: colors.mutedText),
                const SizedBox(width: 8),
                Text(
                  '${_controller.answers.length} / ${_controller.participants.length} Answered',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            AppButton.primary(
              label: 'End Question',
              onPressed: () => _controller.endQuestion(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestion(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;
    final q = _controller.currentQuestion;
    final seconds = (_controller.questionRemainingMs / 1000).ceil();
    
    final optionColors = [
      Colors.red.shade400,
      Colors.blue.shade400,
      Colors.yellow.shade700,
      Colors.green.shade400,
    ];
    final optionIcons = [
      Icons.change_history_rounded,
      Icons.diamond_rounded,
      Icons.circle,
      Icons.square_rounded,
    ];

    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      return _buildLandscapeQuestion(context, q, optionColors, optionIcons);
    }

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
                'Question ${_controller.currentQuestionIndex + 1} of ${_controller.questions.length}',
                style: textTheme.labelLarge?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                q.text,
                style: textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
              if ((q.localPhotoPath != null && q.localPhotoPath!.isNotEmpty) || (q.photoUrl != null && q.photoUrl!.isNotEmpty))
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: q.localPhotoPath != null && q.localPhotoPath!.isNotEmpty
                        ? Image.file(
                            File(q.localPhotoPath!),
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Image.network(
                              q.photoUrl ?? '',
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const SizedBox(height: 180, child: Center(child: Icon(Icons.broken_image, color: Colors.white))),
                            ),
                          )
                        : Image.network(
                            q.photoUrl!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(q.options.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildPortraitOptionButton(i, q.options[i], optionColors[i], optionIcons[i], textTheme),
          );
        }),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surfaceLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.people_rounded, size: 18, color: colors.mutedText),
              const SizedBox(width: 8),
              Text(
                '${_controller.answers.length} answer(s) received',
                style: textTheme.bodyMedium?.copyWith(color: colors.mutedText),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppButton.primary(
          label: 'End Question',
          onPressed: () => _controller.endQuestion(),
        ),
      ],
    );
  }

  Widget _buildAnswerReveal(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;
    final q = _controller.currentQuestion;
    final correctIndex = q.correctAnswerIndex;

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
                'Question ${_controller.currentQuestionIndex + 1} of ${_controller.questions.length}',
                style: textTheme.labelLarge?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                q.text,
                style: textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(q.options.length, (i) {
          final isCorrect = i == correctIndex;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isCorrect ? Colors.green.shade400 : colors.surfaceLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCorrect ? Colors.green.shade600 : colors.outline,
                  width: isCorrect ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle_rounded : Icons.circle_outlined,
                    color: isCorrect ? Colors.white : colors.mutedText,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      q.options[i],
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isCorrect ? Colors.white : colors.textOnSurface,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCorrect)
                    Text(
                      'CORRECT',
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surfaceLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.people_rounded, size: 18, color: colors.mutedText),
              const SizedBox(width: 8),
              Text(
                '${_controller.answers.length} / ${_controller.participants.length} answered',
                style: textTheme.bodyMedium?.copyWith(color: colors.mutedText),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppButton.primary(
          label: 'Show Leaderboard',
          onPressed: () => _controller.showLeaderboard(),
        ),
      ],
    );
  }

  Widget _buildLeaderboard(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;
    final lb = _controller.leaderboard;

    final medals = ['🥇', '🥈', '🥉'];

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
              Icon(Icons.emoji_events_rounded, size: 48, color: Colors.yellow.shade600),
              const SizedBox(height: 8),
              Text(
                'LEADERBOARD',
                style: textTheme.labelLarge?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'After Question ${_controller.currentQuestionIndex + 1}',
                style: textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: lb.isEmpty
              ? Center(
                  child: Text(
                    'No scores yet',
                    style: textTheme.bodyMedium?.copyWith(color: colors.mutedText),
                  ),
                )
              : ListView.builder(
                  itemCount: lb.length,
                  itemBuilder: (context, index) {
                    final entry = lb[index];
                    final isTop3 = entry.rank <= 3;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isTop3
                            ? colors.primary.withValues(alpha: 0.08)
                            : colors.surfaceLowest,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isTop3
                              ? colors.primary.withValues(alpha: 0.3)
                              : colors.outline,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            isTop3 && entry.rank - 1 < medals.length
                                ? medals[entry.rank - 1]
                                : '#${entry.rank}',
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 14),
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: colors.primary.withValues(alpha: 0.14),
                            child: Text(
                              entry.name.isNotEmpty
                                  ? entry.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: colors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.name,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '${entry.score} pts',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 16),
        AppButton.primary(
          label: _controller.currentQuestionIndex < _controller.questions.length - 1
              ? 'Next Question'
              : 'Finish Game',
          onPressed: () => _controller.nextFromLeaderboard(),
        ),
      ],
    );
  }

  Widget _buildResults(BuildContext context) {
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
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_controller.participants.length} participant(s) joined',
            style: textTheme.bodyLarge?.copyWith(color: colors.mutedText),
          ),
          // const SizedBox(height: 8),
          // Text(
          //   '${_controller.answers.length} total answer(s) received',
          //   style: textTheme.bodyMedium?.copyWith(color: colors.mutedText),
          // ),
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
