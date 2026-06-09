import 'package:flutter/material.dart';

class GameModel {
  final String id;
  final String name;
  final String payout;
  final String category; // '2D', '3D', '4D'
  final Gradient cardGradient;
  final double minBet;
  final double maxBet;

  GameModel({
    required this.id,
    required this.name,
    required this.payout,
    required this.category,
    required this.cardGradient,
    required this.minBet,
    required this.maxBet,
  });
}
