import 'package:flutter/material.dart';
import 'package:pomodoro_windows/app/theme.dart';
import 'package:pomodoro_windows/data/models/reservation.dart';
import 'package:pomodoro_windows/presentation/display/display_controller.dart';
import 'package:pomodoro_windows/presentation/widgets/reservation_card.dart';

class RunwayPanel extends StatefulWidget {
  final RunwaySchedule schedule;

  const RunwayPanel({super.key, required this.schedule});

  @override
  State<RunwayPanel> createState() => _RunwayPanelState();
}

class _RunwayPanelState extends State<RunwayPanel> {
  final _scrollController = ScrollController();
  final _anchorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToAnchor());
  }

  @override
  void didUpdateWidget(RunwayPanel old) {
    super.didUpdateWidget(old);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToAnchor());
  }

  void _scrollToAnchor() {
    final ctx = _anchorKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<_ListItem> _buildItems() {
    final schedule = widget.schedule;
    final items = <_ListItem>[];
    bool anchorSet = false;

    // Completed in chronological order (oldest first, newest just above active)
    for (final r in schedule.completed.reversed) {
      items.add(_ListItem(r, ReservationStatus.completed, false));
    }

    if (schedule.active != null) {
      items.add(_ListItem(schedule.active!, ReservationStatus.active, true));
      anchorSet = true;
    }

    for (int i = 0; i < schedule.upcoming.length; i++) {
      final isAnchor = !anchorSet && i == 0;
      if (isAnchor) anchorSet = true;
      items.add(_ListItem(schedule.upcoming[i], ReservationStatus.upcoming, isAnchor));
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildItems();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Text(
              DisplayController.formatRunwayLabel(widget.schedule.runwayId),
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? _EmptyPanel()
                : ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isActive = item.status == ReservationStatus.active;
                      return Container(
                        key: item.isAnchor ? _anchorKey : null,
                        child: ReservationCard(
                          reservation: item.reservation,
                          status: item.status,
                          compact: !isActive,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ListItem {
  final Reservation reservation;
  final ReservationStatus status;
  final bool isAnchor;

  const _ListItem(this.reservation, this.status, this.isAnchor);
}

class _EmptyPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 40,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Nema rezervacija',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
