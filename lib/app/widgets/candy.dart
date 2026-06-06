import 'package:flutter/material.dart';

import '../cute_palette.dart';

/// The signature "candy" look is a HARD offset shadow with zero blur
/// (`box-shadow: 0 5px 0 <color>` in the mockup). Material's elevation is
/// always blurred, so we build the shadow by hand. Everything in this file is
/// a small reusable piece tasks 15/16 lean on, keeping the look in one place.

/// A hard, blur-free drop shadow offset straight down by [dy].
List<BoxShadow> candyShadow(Color color, {double dy = 5}) {
  return [BoxShadow(color: color, offset: Offset(0, dy), blurRadius: 0)];
}

/// Which gradient + shadow a [CandyButton] wears.
enum CandyVariant { matcha, peach }

/// A pill button with a gradient fill, a matching candy shadow, and white
/// bold text — the mockup's "start this slot" / "plan the next one" buttons. Pass [expand]
/// false to size to content instead of filling the available width.
class CandyButton extends StatelessWidget {
  const CandyButton({
    required this.label,
    required this.onPressed,
    this.variant = CandyVariant.matcha,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final CandyVariant variant;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final isMatcha = variant == CandyVariant.matcha;
    final gradient = isMatcha
        ? CuteColors.matchaGradient
        : CuteColors.peachGradient;
    final shadowColor = isMatcha
        ? CuteColors.matchaCandyShadow
        : CuteColors.peachCandyShadow;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: candyShadow(shadowColor),
            ),
            child: Container(
              width: expand ? double.infinity : null,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
              alignment: Alignment.center,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CuteColors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A rounded card with a border + candy shadow. Keeps task-15 call sites short
/// (they wrap content; they don't re-declare the look). Defaults match the
/// mockup's white cards on cream.
class CandyCard extends StatelessWidget {
  const CandyCard({
    required this.child,
    this.color = CuteColors.surface,
    this.borderColor = CuteColors.borderCream,
    this.shadowColor = CuteColors.borderCream,
    this.radius = 26,
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  final Widget child;
  final Color color;
  final Color borderColor;
  final Color shadowColor;
  final double radius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: candyShadow(shadowColor),
      ),
      child: child,
    );
  }
}
