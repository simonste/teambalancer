import 'package:flutter/material.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/data/group_data.dart';

class GroupSummary extends Column {
  GroupSummary({super.key, required GroupData group})
      : super(
            children: Skill.values
                .map((s) => Text(
                      "$s : ${group.skill(s).toStringAsFixed(1)}",
                      textScaler: const TextScaler.linear(0.7),
                    ))
                .toList());
}
