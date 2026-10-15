import 'package:flutter/material.dart';
import '../models/statistics.dart' as statistics;
import 'identified_controller.dart';

class BadgeController extends IdentifiedController<statistics.Badge> {
  static final BadgeController _instance = BadgeController._internal();
  factory BadgeController() => _instance;
  BadgeController._internal();

  @override
  String get storageKey => 'badges';
  @override
  Map<String, dynamic> toJson(statistics.Badge item) => item.toJson();
  @override
  statistics.Badge fromJson(Map<String, dynamic> json) =>
      statistics.Badge.fromJson(json);
  @override
  String idOf(statistics.Badge item) => item.id;
  @override
  statistics.Badge applyFields(
    statistics.Badge item,
    Map<String, dynamic> fields,
  ) => item.copyWith(
    title: fields['title'] as String? ?? item.title,
    icon: fields['icon'] as IconData? ?? item.icon,
    backgroundColor:
        fields['backgroundColor'] as Color? ?? item.backgroundColor,
    detail: fields['detail'] as String? ?? item.detail,
    earnedDate: fields.containsKey('earnedDate')
        ? fields['earnedDate'] as DateTime?
        : item.earnedDate,
  );

  List<statistics.Badge> getEarned() =>
      findWhere((badge) => badge.earnedDate != null);
  List<statistics.Badge> getUnearned() =>
      findWhere((badge) => badge.earnedDate == null);
  Future<statistics.Badge?> markEarned(String id) =>
      updateFields(id, {'earnedDate': DateTime.now()});
}
