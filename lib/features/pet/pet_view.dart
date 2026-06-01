import 'package:flutter/material.dart';

import 'pet_mood.dart';

class PetView extends StatelessWidget {
  const PetView({required this.mood, this.size = 24, super.key});

  final PetMood mood;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsForMood(Theme.of(context).colorScheme);

    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background,
          border: Border.all(color: colors.border, width: size * 0.06),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            _emojiForMood(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: size * 0.56, height: 1),
          ),
        ),
      ),
    );
  }

  String _emojiForMood() {
    return switch (mood) {
      PetMood.happy => '🌳',
      PetMood.neutral => '🌱',
      PetMood.sad => '🥀',
    };
  }

  _PetColors _colorsForMood(ColorScheme colorScheme) {
    return switch (mood) {
      PetMood.happy => _PetColors(
        background: colorScheme.tertiaryContainer,
        border: colorScheme.tertiary,
      ),
      PetMood.neutral => _PetColors(
        background: colorScheme.secondaryContainer,
        border: colorScheme.secondary,
      ),
      PetMood.sad => _PetColors(
        background: colorScheme.errorContainer,
        border: colorScheme.error,
      ),
    };
  }
}

class _PetColors {
  const _PetColors({required this.background, required this.border});

  final Color background;
  final Color border;
}
