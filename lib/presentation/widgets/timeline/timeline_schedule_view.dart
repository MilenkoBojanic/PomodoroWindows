import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pomodoro_windows/app/theme.dart';
import 'package:pomodoro_windows/presentation/display/display_controller.dart';
import 'package:pomodoro_windows/presentation/widgets/timeline/timeline_layout.dart';
import 'package:pomodoro_windows/presentation/widgets/timeline/timeline_reservation_block.dart';
import 'package:provider/provider.dart';

class TimelineScheduleView extends StatefulWidget {
  const TimelineScheduleView({super.key});

  @override
  State<TimelineScheduleView> createState() => _TimelineScheduleViewState();
}

class _TimelineScheduleViewState extends State<TimelineScheduleView> {
  final ScrollController _verticalController = ScrollController();
  bool _initialScrollDone = false;

  void _scrollToCurrentTime(DisplayController controller, TimelineRange range) {
    if (_initialScrollDone || !_verticalController.hasClients) {
      return;
    }

    final offset = currentTimeOffset(controller.now, range);
    if (offset == null) {
      _initialScrollDone = true;
      return;
    }

    final viewportHeight = _verticalController.position.viewportDimension;
    final target = (TimelineMetrics.topPadding + offset - viewportHeight * 0.3)
        .clamp(
      0.0,
      _verticalController.position.maxScrollExtent,
    );

    _verticalController.jumpTo(target);
    _initialScrollDone = true;
  }

  @override
  void dispose() {
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DisplayController>();
    final runwayIds = controller.runwayIds;
    final range = resolveTimelineRange(day: controller.selectedDate);
    final totalHeight =
        TimelineMetrics.contentHeight(range.totalHeight);
    final nowOffset = controller.isViewingToday
        ? currentTimeOffset(controller.now, range)
        : null;
    final hourTicks = hourGridTicks(range);
    final halfHourOffsets = halfHourGridOffsets(range);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.isViewingToday) {
        _scrollToCurrentTime(controller, range);
      }
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final runwayColumnWidth = runwayIds.isEmpty
              ? 0.0
              : (constraints.maxWidth - TimelineMetrics.timeColumnWidth) /
                  runwayIds.length;

          return Column(
            children: [
              _RunwayHeaderRow(runwayIds: runwayIds),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surfaceLight),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: SingleChildScrollView(
                      controller: _verticalController,
                      child: SizedBox(
                        height: totalHeight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _TimeAxisColumn(
                              hourTicks: hourTicks,
                              totalHeight: totalHeight,
                            ),
                            Expanded(
                              child: SizedBox(
                                height: totalHeight,
                                child: Stack(
                                  children: [
                                    _TimelineGrid(
                                      runwayIds: runwayIds,
                                      halfHourOffsets: halfHourOffsets,
                                      totalHeight: totalHeight,
                                    ),
                                    for (final runwayId in runwayIds)
                                      ..._buildRunwayBlocks(
                                        controller: controller,
                                        runwayId: runwayId,
                                        range: range,
                                        runwayColumnWidth: runwayColumnWidth,
                                      ),
                                    if (nowOffset != null)
                                      _CurrentTimeIndicator(
                                        offset: nowOffset +
                                            TimelineMetrics.topPadding,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildRunwayBlocks({
    required DisplayController controller,
    required String runwayId,
    required TimelineRange range,
    required double runwayColumnWidth,
  }) {
    final runwayIndex = controller.runwayIds.indexOf(runwayId);
    final reservations = controller.reservations
        .where((reservation) => reservation.runwayId == runwayId)
        .toList();
    final layouts = layoutRunwayReservations(
      reservations: reservations,
      range: range,
    );

    return layouts.map((layout) {
      final columnLeft = runwayIndex * runwayColumnWidth;
      final blockWidth = runwayColumnWidth * layout.widthFraction;
      final blockLeft =
          columnLeft + (runwayColumnWidth * layout.leftFraction);

      return Positioned(
        top: layout.top + TimelineMetrics.topPadding,
        left: blockLeft + 3,
        width: blockWidth - 6,
        height: layout.height - 3,
        child: TimelineReservationBlock(
          reservation: layout.reservation,
          status: controller.statusFor(layout.reservation),
        ),
      );
    }).toList();
  }
}

class _RunwayHeaderRow extends StatelessWidget {
  final List<String> runwayIds;

  const _RunwayHeaderRow({required this.runwayIds});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: TimelineMetrics.headerHeight,
      child: Row(
        children: [
          const SizedBox(width: TimelineMetrics.timeColumnWidth),
          Expanded(
            child: Row(
              children: [
                for (final runwayId in runwayIds)
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(color: AppColors.surfaceLight),
                        ),
                      ),
                      child: Text(
                        DisplayController.formatRunwayLabel(runwayId),
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeAxisColumn extends StatelessWidget {
  final List<({double offset, DateTime time})> hourTicks;
  final double totalHeight;

  const _TimeAxisColumn({
    required this.hourTicks,
    required this.totalHeight,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');

    return SizedBox(
      width: TimelineMetrics.timeColumnWidth,
      height: totalHeight,
      child: Stack(
        children: [
          for (final tick in hourTicks)
            Positioned(
              top: TimelineMetrics.topPadding + tick.offset - 8,
              left: 0,
              right: 0,
              child: Text(
                timeFormat.format(tick.time),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineGrid extends StatelessWidget {
  final List<String> runwayIds;
  final List<double> halfHourOffsets;
  final double totalHeight;

  const _TimelineGrid({
    required this.runwayIds,
    required this.halfHourOffsets,
    required this.totalHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          children: [
            for (final _ in runwayIds)
              Expanded(
                child: Container(
                  height: totalHeight,
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: AppColors.surfaceLight),
                    ),
                  ),
                ),
              ),
          ],
        ),
        for (final offset in halfHourOffsets)
          Positioned(
            top: TimelineMetrics.topPadding + offset,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              color: AppColors.surfaceLight.withValues(alpha: 0.55),
            ),
          ),
      ],
    );
  }
}

class _CurrentTimeIndicator extends StatelessWidget {
  final double offset;

  const _CurrentTimeIndicator({required this.offset});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: offset,
      left: 0,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.accentBright,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(
              height: 2,
              color: AppColors.accentBright,
            ),
          ),
        ],
      ),
    );
  }
}
