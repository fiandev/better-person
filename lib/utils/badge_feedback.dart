import 'package:flutter/material.dart' hide Badge;

import '../models/statistics.dart';

class BadgeFeedback {
  static void show(BuildContext context, List<Badge> badges) {
    final messenger = ScaffoldMessenger.of(context);
    for (var index = 0; index < badges.length; index++) {
      final badge = badges[index];
      Future<void>.delayed(Duration(milliseconds: index * 450), () {
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(badge.icon, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Badge earned: ${badge.title}. ${badge.detail}'),
                ),
              ],
            ),
            backgroundColor: badge.backgroundColor,
          ),
        );
      });
    }
  }
}
