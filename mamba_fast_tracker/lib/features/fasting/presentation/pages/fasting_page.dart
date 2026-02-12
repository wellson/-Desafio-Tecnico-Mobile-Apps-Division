import 'dart:math';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_fast_tracker/core/theme/app_theme.dart';
import 'package:mamba_fast_tracker/core/utils/date_utils.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/entities/fasting_protocol.dart';
import 'package:mamba_fast_tracker/features/fasting/presentation/cubit/fasting_cubit.dart';
import 'package:mamba_fast_tracker/features/fasting/presentation/cubit/fasting_state.dart';
import 'package:mamba_fast_tracker/core/di/injection_container.dart';
import 'package:mamba_fast_tracker/core/services/sound_service.dart';
import 'package:mamba_fast_tracker/core/utils/strings.dart';

class FastingPage extends StatefulWidget {
  const FastingPage({super.key});

  @override
  State<FastingPage> createState() => _FastingPageState();
}

class _FastingPageState extends State<FastingPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<FastingCubit>().onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppStrings.fastingTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        title: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showCustomProtocolDialog(context),
          tooltip: AppStrings.customProtocolTooltip,
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings, color: AppTheme.primaryColor),
            tooltip: AppStrings.tabSettings,
          ),
        ],
      ),
      body: BlocListener<FastingCubit, FastingState>(
        listenWhen: (previous, current) {
          // Play sound when starting (Idle -> Active)
          if (previous is FastingIdle && current is FastingActive) return true;
          // Play sound when finishing (Active -> Completed)
          if (previous is FastingActive && current is FastingCompleted) return true;
          return false;
        },
        listener: (context, state) {
          if (state is FastingActive) {
            sl<SoundService>().playFastStarted();
          } else if (state is FastingCompleted) {
            sl<SoundService>().playFastEnded();
          }
        },
        child: BlocBuilder<FastingCubit, FastingState>(
          builder: (context, state) {
            if (state is FastingLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is FastingError) {
              return Center(child: Text('Erro: ${state.message}'));
            }

            if (state is FastingActive) {
              return _buildActiveTimer(context, state);
            }

            if (state is FastingCompleted) {
              return _buildCompletedView(context, state);
            }

            if (state is FastingIdle) {
              return _buildIdleView(context, state);
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
      // This allows the BlocBuilder to rebuild the UI while BlocListener handles side effects
    );
  }

  Widget _buildIdleView(BuildContext context, FastingIdle state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Circular indicator (idle)
          _buildCircularTimer(context, 0.0, '--:--:--', AppStrings.readyToStart),
          const SizedBox(height: 32),

          // Protocol selection
          Text(
            AppStrings.selectProtocol,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          ...state.protocols.map((protocol) => _buildProtocolCard(
                context,
                protocol,
                state.selectedProtocol?.name == protocol.name,
              )),
          const SizedBox(height: 24),

          // Start button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: state.selectedProtocol != null
                  ? () {
                      context
                          .read<FastingCubit>()
                          .startFasting(state.selectedProtocol!);
                    }
                  : null,
              icon: const Icon(Icons.play_arrow),
              label: const Text(AppStrings.startFasting),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTimer(BuildContext context, FastingActive state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildCircularTimer(
            context,
            state.progress,
            AppDateUtils.formatTime(state.elapsed),
            '${AppStrings.timeRemaining}${AppDateUtils.formatTime(state.remaining)}',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${AppStrings.protocolLabel}${state.session.protocolName}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${AppStrings.startedLabel}${AppDateUtils.formatDateTime(state.session.startTime)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          // End button
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _confirmCancel(context),
                  icon: const Icon(Icons.close),
                  label: const Text(AppStrings.cancel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentRed,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.read<FastingCubit>().endFasting(),
                  icon: const Icon(Icons.stop),
                  label: const Text(AppStrings.finishButton),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedView(BuildContext context, FastingCompleted state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, size: 80, color: AppTheme.accentGreen),
            const SizedBox(height: 24),
            Text(
              AppStrings.fastingCompletedTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${AppStrings.protocolLabel}${state.session.protocolName}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.read<FastingCubit>().loadInitialState(),
              icon: const Icon(Icons.refresh),
              label: const Text(AppStrings.newFastingButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularTimer(BuildContext context, double progress, String time, String subtitle) {
    // Get colors from theme
    final theme = Theme.of(context);
    final textColor = theme.textTheme.headlineLarge?.color ?? Colors.black;
    final subtitleColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;
    final backgroundColor = theme.cardTheme.color ?? Colors.grey[200]!;

    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: 250,
            height: 250,
            child: CustomPaint(
              painter: _CircularProgressPainter(
                progress: progress,
                backgroundColor: backgroundColor,
                progressColor: AppTheme.primaryColor,
                strokeWidth: 12,
              ),
            ),
          ),
          // Time text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: subtitleColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolCard(
      BuildContext context, FastingProtocol protocol, bool isSelected) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => context.read<FastingCubit>().selectProtocol(protocol),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.2)
              : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppTheme.primaryColor, width: 2)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor
                    : theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${protocol.fastingHours}h',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    protocol.name,
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    '${protocol.fastingHours}h jejum / ${protocol.eatingHours}h alimentação',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (protocol.isCustom)
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppTheme.accentRed, size: 20),
                onPressed: () {
                  if (protocol.id != null) {
                    context.read<FastingCubit>().deleteProtocol(protocol.id!);
                  }
                },
              ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: const Text(AppStrings.cancelFastingTitle),
        content:
            const Text(AppStrings.cancelFastingMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.no),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<FastingCubit>().cancelFasting();
            },
            child: const Text(AppStrings.yes, style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }

  void _showCustomProtocolDialog(BuildContext context) {
    final nameController = TextEditingController();
    final fastingController = TextEditingController();
    final eatingController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: const Text(AppStrings.customProtocolTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: AppStrings.nameLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: fastingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: AppStrings.fastingHoursLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: eatingController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: AppStrings.eatingHoursLabel),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final fasting = int.tryParse(fastingController.text) ?? 0;
              final eating = int.tryParse(eatingController.text) ?? 0;

              if (name.isNotEmpty && fasting > 0 && eating > 0) {
                context
                    .read<FastingCubit>()
                    .saveCustomProtocol(name, fasting, eating);
                Navigator.pop(ctx);
              }
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: [progressColor, progressColor.withValues(alpha: 0.6)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
