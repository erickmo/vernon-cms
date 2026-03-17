import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/activity_log.dart';
import 'activity_log_item.dart';

/// Daftar timeline log aktivitas.
class ActivityLogTimeline extends StatelessWidget {
  /// Daftar log aktivitas.
  final List<ActivityLog> logs;

  const ActivityLogTimeline({
    super.key,
    required this.logs,
  });

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(AppStrings.emptyData),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: logs.length,
      itemBuilder: (context, index) => ActivityLogItem(log: logs[index]),
    );
  }
}
