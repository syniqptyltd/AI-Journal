import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Mood options for journal entries
/// Designed to be supportive and non-judgmental
enum Mood {
  calm,
  happy,
  neutral,
  anxious,
  overwhelmed,
  sad,
  energized,
  tired;

  String get label {
    switch (this) {
      case Mood.calm:
        return 'Calm';
      case Mood.happy:
        return 'Happy';
      case Mood.neutral:
        return 'Neutral';
      case Mood.anxious:
        return 'Anxious';
      case Mood.overwhelmed:
        return 'Overwhelmed';
      case Mood.sad:
        return 'Sad';
      case Mood.energized:
        return 'Energized';
      case Mood.tired:
        return 'Tired';
    }
  }

  String get emoji {
    switch (this) {
      case Mood.calm:
        return '😌';
      case Mood.happy:
        return '😊';
      case Mood.neutral:
        return '😐';
      case Mood.anxious:
        return '😟';
      case Mood.overwhelmed:
        return '😰';
      case Mood.sad:
        return '😢';
      case Mood.energized:
        return '⚡';
      case Mood.tired:
        return '😴';
    }
  }

  Color get color {
    switch (this) {
      case Mood.calm:
        return AppColors.moodCalm;
      case Mood.happy:
        return AppColors.moodHappy;
      case Mood.neutral:
        return AppColors.moodNeutral;
      case Mood.anxious:
        return AppColors.moodAnxious;
      case Mood.overwhelmed:
        return AppColors.moodOverwhelmed;
      case Mood.sad:
        return AppColors.moodSad;
      case Mood.energized:
        return AppColors.moodEnergized;
      case Mood.tired:
        return AppColors.moodTired;
    }
  }

  /// Gentle description for AI context
  String get description {
    switch (this) {
      case Mood.calm:
        return 'feeling peaceful and at ease';
      case Mood.happy:
        return 'feeling joyful and content';
      case Mood.neutral:
        return 'feeling balanced, neither particularly good nor bad';
      case Mood.anxious:
        return 'feeling worried or uneasy';
      case Mood.overwhelmed:
        return 'feeling like there is too much to handle';
      case Mood.sad:
        return 'feeling down or melancholy';
      case Mood.energized:
        return 'feeling motivated and full of energy';
      case Mood.tired:
        return 'feeling fatigued or low on energy';
    }
  }
}
