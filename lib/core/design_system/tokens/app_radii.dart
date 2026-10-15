import 'package:flutter/material.dart';

abstract final class AppRadii {
  /// Small elements: Input fields, transaction tiles (12.0)
  static const double sm = 12.0;

  /// Medium containers: Secondary cards, modal sheets (16.0)
  static const double md = 16.0;

  /// Action buttons: Floating Action Button (18.0)
  static const double fab = 18.0;

  /// Large containers: Hero balance card (24.0)
  static const double lg = 24.0;

  /// Full circular radius
  static const double full = 999.0;

  // BorderRadius presets
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderFab = BorderRadius.all(Radius.circular(fab));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));

  // Subtle elevation as specified in DesignSystem.md (max blur 16px, 4-6% black)
  static const BoxShadow subtleElevation = BoxShadow(
    color: Color(0x0F000000), // ~6% black
    blurRadius: 16.0,
    offset: Offset(0, 4),
  );
}
