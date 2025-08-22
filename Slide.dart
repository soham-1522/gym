import 'package:flutter/material.dart';

class Slide {
  final String imageUrl;
  final String title;
  final String description;

  const Slide({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}

final slideList = [
  Slide(
    imageUrl: 'assets/screen_1.png',
    title: 'Welcome to FitLife',
    description: '   Your parcover tasks compation time workjets, bisk,progress',
  ),
  Slide(
    imageUrl: 'assets/screen_2.png',
    title: 'Custom Workouts',
    description: ' A custom workout plan is a fitness routine designed specifically for you, based on your unique goals, current fitness level, available equipment, and preferences.',
  ),
  Slide(
    imageUrl: 'assets/screen_3.png',
    title: 'Track Progress',
    description: 'Allows you to track the progress against the actual progress being made',
  ),
];