import 'package:flutter/material.dart';
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
      case HostPhase.question:
        title = 'Question ${_controller.currentQuestionIndex + 1}';
      case HostPhase.results:
        title = 'Results';
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
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
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: _buildBody(context),
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
      case HostPhase.question:
        return _buildQuestion(context);
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

  Widget _buildQuestion(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;
    final q = _controller.currentQuestion;
    final optionLabels = ['A', 'B', 'C', 'D'];
    final optionColors = [
      Colors.red.shade400,
      Colors.blue.shade400,
      Colors.yellow.shade700,
      Colors.green.shade400,
    ];

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
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: optionColors[i].withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: optionColors[i].withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: optionColors[i],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      optionLabels[i],
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    q.options[i],
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
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
                '${_controller.answers.length} answer(s) received',
                style: textTheme.bodyMedium?.copyWith(color: colors.mutedText),
              ),
              // ..._controller.answers.map(
              //   (a) => Padding(
              //     padding: const EdgeInsets.only(left: 8),
              //     child: Chip(
              //       label: Text(
              //         '${a.name}: ${optionLabels[a.answer]}',
              //         style: textTheme.labelSmall,
              //       ),
              //       visualDensity: VisualDensity.compact,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppButton.primary(
          label:
              _controller.currentQuestionIndex <
                  _controller.questions.length - 1
              ? 'Next Question'
              : 'Finish Game',
          onPressed: () => _controller.nextQuestion(),
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
