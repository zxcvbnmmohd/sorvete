# Sorvete — Design System

### Flutter App Edition

> Derived from the Sorvete web design language. All values are Flutter-ready.
> Use this file as the single source of truth for theming, typography, spacing, and component patterns across the app.

---

## 1. Design Philosophy

Sorvete's visual language is **editorial, grounded, and calm**. It avoids the sterile tech-blue look of generic SaaS and instead draws from the warmth of hospitality itself — natural materials, considered typography, and restrained colour.

**Core principles:**

- Warmth over sterility — organic tones, not cold greys or default blues
- Editorial restraint — type does the heavy lifting; colour is used sparingly
- Data-forward — numbers are heroes; surfaces exist to frame them, not compete
- Generous space — breathing room is a feature, not wasted pixels

---

## 2. Colour Palette

### Primary Colours

| Name          | Hex       | Flutter `Color`     | Role                                               |
| ------------- | --------- | ------------------- | -------------------------------------------------- |
| `inkGreen`    | `#0f1a0e` | `Color(0xFF0F1A0E)` | Primary text, nav backgrounds, hero panels         |
| `forestGreen` | `#3a5c3e` | `Color(0xFF3A5C3E)` | Primary brand, hero fill, featured card bg         |
| `terracotta`  | `#c4542a` | `Color(0xFFC4542A)` | Accent, CTAs, active states, markers               |
| `boneWhite`   | `#faf7f2` | `Color(0xFFFAF7F2)` | Page/scaffold background                           |
| `sand`        | `#ede8df` | `Color(0xFFEDE8DF)` | Card surfaces, input backgrounds, secondary panels |
| `paleGreen`   | `#e8f0e9` | `Color(0xFFE8F0E9)` | Hover states, selected rows, subtle highlights     |

### Text Colours

| Name              | Hex                      | Flutter `Color`     | Role                                           |
| ----------------- | ------------------------ | ------------------- | ---------------------------------------------- |
| `textPrimary`     | `#0f1a0e`                | `Color(0xFF0F1A0E)` | Headings, body copy                            |
| `textMuted`       | `#6b6560`                | `Color(0xFF6B6560)` | Captions, labels, secondary info               |
| `textOnDark`      | `#ffffff`                | `Color(0xFFFFFFFF)` | Text on `forestGreen` / `inkGreen` backgrounds |
| `textOnDarkMuted` | `rgba(255,255,255,0.55)` | `Color(0x8CFFFFFF)` | Secondary text on dark panels                  |

### Semantic Colours

| Name       | Hex       | Flutter `Color`     | Role                                           |
| ---------- | --------- | ------------------- | ---------------------------------------------- |
| `positive` | `#3a5c3e` | `Color(0xFF3A5C3E)` | Success states, upward trends                  |
| `negative` | `#c4542a` | `Color(0xFFC4542A)` | Warnings, downward trends, destructive actions |
| `neutral`  | `#6b6560` | `Color(0xFF6B6560)` | Neutral states, unchanged metrics              |

### Border

| Name           | Value                 | Flutter `Color`     | Role                           |
| -------------- | --------------------- | ------------------- | ------------------------------ |
| `borderSubtle` | `rgba(15,26,14,0.10)` | `Color(0x1A0F1A0E)` | Default dividers, card borders |
| `borderMedium` | `rgba(15,26,14,0.18)` | `Color(0x2E0F1A0E)` | Stronger dividers, input focus |

---

## 3. ThemeData Setup

```dart
import 'package:flutter/material.dart';

class SorveteColors {
  static const inkGreen    = Color(0xFF0F1A0E);
  static const forestGreen = Color(0xFF3A5C3E);
  static const terracotta  = Color(0xFFC4542A);
  static const boneWhite   = Color(0xFFFAF7F2);
  static const sand        = Color(0xFFEDE8DF);
  static const paleGreen   = Color(0xFFE8F0E9);
  static const textMuted   = Color(0xFF6B6560);
  static const borderSubtle = Color(0x1A0F1A0E);
  static const borderMedium = Color(0x2E0F1A0E);
}

ThemeData sorveteTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: SorveteColors.boneWhite,
    colorScheme: ColorScheme.light(
      primary:    SorveteColors.forestGreen,
      secondary:  SorveteColors.terracotta,
      surface:    Colors.white,
      onPrimary:  Colors.white,
      onSecondary: Colors.white,
      onSurface:  SorveteColors.inkGreen,
    ),
    textTheme: _sorveteTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: SorveteColors.boneWhite,
      foregroundColor: SorveteColors.inkGreen,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Fraunces',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: SorveteColors.inkGreen,
        letterSpacing: -0.5,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: SorveteColors.borderSubtle,
      thickness: 1,
      space: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: SorveteColors.borderSubtle),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: _sorveteInputTheme(),
    elevatedButtonTheme: _sorveteElevatedButtonTheme(),
    outlinedButtonTheme: _sorveteOutlinedButtonTheme(),
  );
}
```

---

## 4. Typography

### Font Families

| Family              | Use                             | Flutter font family string |
| ------------------- | ------------------------------- | -------------------------- |
| **Fraunces**        | Display, headings, hero numbers | `'Fraunces'`               |
| **Instrument Sans** | Body, labels, UI copy           | `'InstrumentSans'`         |

Add to `pubspec.yaml`:

```yaml
fonts:
  - family: Fraunces
    fonts:
      - asset: assets/fonts/Fraunces-Regular.ttf
        weight: 300
      - asset: assets/fonts/Fraunces-Bold.ttf
        weight: 700
      - asset: assets/fonts/Fraunces-Italic.ttf
        style: italic
        weight: 300
      - asset: assets/fonts/Fraunces-BoldItalic.ttf
        style: italic
        weight: 700
  - family: InstrumentSans
    fonts:
      - asset: assets/fonts/InstrumentSans-Regular.ttf
        weight: 400
      - asset: assets/fonts/InstrumentSans-Medium.ttf
        weight: 500
```

> Both fonts are available free on Google Fonts. Fraunces also works via `google_fonts` package.

### Type Scale

```dart
TextTheme _sorveteTextTheme() {
  return TextTheme(
    // Hero / display numbers — large Fraunces
    displayLarge: TextStyle(
      fontFamily: 'Fraunces',
      fontSize: 56,
      fontWeight: FontWeight.w700,
      letterSpacing: -3,
      height: 1.0,
      color: SorveteColors.inkGreen,
    ),
    // Section headings
    displayMedium: TextStyle(
      fontFamily: 'Fraunces',
      fontSize: 44,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.5,
      height: 1.05,
      color: SorveteColors.inkGreen,
    ),
    // Card / panel headings
    displaySmall: TextStyle(
      fontFamily: 'Fraunces',
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.0,
      height: 1.1,
      color: SorveteColors.inkGreen,
    ),
    // KPI / stat numbers
    headlineLarge: TextStyle(
      fontFamily: 'Fraunces',
      fontSize: 36,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.5,
      height: 1.0,
      color: SorveteColors.inkGreen,
    ),
    // Screen titles / app bar
    headlineMedium: TextStyle(
      fontFamily: 'Fraunces',
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.2,
      color: SorveteColors.inkGreen,
    ),
    // Feature card titles
    headlineSmall: TextStyle(
      fontFamily: 'Fraunces',
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      height: 1.3,
      color: SorveteColors.inkGreen,
    ),
    // Body — primary
    bodyLarge: TextStyle(
      fontFamily: 'InstrumentSans',
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.65,
      color: SorveteColors.inkGreen,
    ),
    // Body — standard
    bodyMedium: TextStyle(
      fontFamily: 'InstrumentSans',
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.65,
      color: SorveteColors.inkGreen,
    ),
    // Labels, metadata
    bodySmall: TextStyle(
      fontFamily: 'InstrumentSans',
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.08,
      height: 1.4,
      color: SorveteColors.textMuted,
    ),
    // Overline / eyebrow labels
    labelSmall: TextStyle(
      fontFamily: 'InstrumentSans',
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.4,
      color: SorveteColors.textMuted,
    ),
  );
}
```

### Typography Rules

- **Fraunces italic (`fontStyle: FontStyle.italic, fontWeight: FontWeight.w300`)** on key headline words for editorial rhythm. Use sparingly — one phrase per heading maximum.
- **Never use `fontWeight: FontWeight.w600` or higher** in Instrument Sans — it reads heavy. Use w500 for emphasis.
- **Letter spacing on large Fraunces** should be negative and scale with size: -1.5 at 44px, -3 at 56px+.
- **All labels and eyebrows** in Instrument Sans w500, `letterSpacing: 0.08–0.10`, sentence case.

---

## 5. Spacing System

Base unit: **8px**. All spacing should be multiples.

```dart
class SorveteSpacing {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  // Page-level horizontal padding
  static const double pagePadding = 24;
  // Section vertical breathing room
  static const double sectionGap  = 48;
  // Card internal padding
  static const double cardPadding = 20;
  // Between list items
  static const double listGap     = 12;
}
```

---

## 6. Border Radius

```dart
class SorvetRadius {
  static const double button = 3;   // Sharp, intentional — buttons and tags
  static const double card   = 6;   // Standard cards, input fields
  static const double panel  = 8;   // Larger surface panels
  static const double pill   = 100; // Full pill — status badges only
}
```

> The design is intentionally less rounded than generic Material apps. Soft-but-not-bubbly is the target.

---

## 7. Elevation & Shadow

Sorvete uses **no elevation shadows** on cards. Depth is created through background colour contrast and 1px borders. This is intentional — it keeps the UI calm and print-like.

```dart
// Correct — border only, no shadow
Card(
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(SorvetRadius.card),
    side: BorderSide(color: SorveteColors.borderSubtle),
  ),
)

// Only use shadow for floating elements (bottom sheets, popovers)
BoxShadow(
  color: Color(0x1A0F1A0E), // 10% inkGreen
  blurRadius: 24,
  offset: Offset(0, 8),
)
```

---

## 8. Components

### Buttons

```dart
// Primary — terracotta fill
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: SorveteColors.terracotta,
    foregroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(SorvetRadius.button),
    ),
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    textStyle: TextStyle(
      fontFamily: 'InstrumentSans',
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  ),
)

// Secondary — outlined inkGreen
OutlinedButton(
  style: OutlinedButton.styleFrom(
    foregroundColor: SorveteColors.inkGreen,
    side: BorderSide(color: SorveteColors.inkGreen),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(SorvetRadius.button),
    ),
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    textStyle: TextStyle(
      fontFamily: 'InstrumentSans',
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  ),
)

// Ghost on dark background (e.g. inside hero panels)
OutlinedButton(
  style: OutlinedButton.styleFrom(
    foregroundColor: Colors.white.withOpacity(0.75),
    side: BorderSide(color: Colors.white.withOpacity(0.25)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(SorvetRadius.button),
    ),
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  ),
)
```

### Input Fields

```dart
InputDecoration _sorveteInput({required String label}) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(
      fontFamily: 'InstrumentSans',
      fontSize: 13,
      color: SorveteColors.textMuted,
    ),
    filled: true,
    fillColor: SorveteColors.sand,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(SorvetRadius.card),
      borderSide: BorderSide(color: SorveteColors.borderSubtle),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(SorvetRadius.card),
      borderSide: BorderSide(color: SorveteColors.borderSubtle),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(SorvetRadius.card),
      borderSide: BorderSide(color: SorveteColors.forestGreen, width: 1.5),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

InputDecorationTheme _sorveteInputTheme() {
  return InputDecorationTheme(
    filled: true,
    fillColor: SorveteColors.sand,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(SorvetRadius.card),
      borderSide: BorderSide(color: SorveteColors.borderSubtle),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(SorvetRadius.card),
      borderSide: BorderSide(color: SorveteColors.borderSubtle),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(SorvetRadius.card),
      borderSide: BorderSide(color: SorveteColors.forestGreen, width: 1.5),
    ),
  );
}
```

### KPI / Metric Card

The signature data component. Large Fraunces number, small Instrument Sans label below.

```dart
class SorveteKpiCard extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const SorveteKpiCard({
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SorveteSpacing.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SorvetRadius.card),
        border: Border.all(color: SorveteColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            value,
            style: TextStyle(
              fontFamily: 'Fraunces',
              fontSize: 36,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.5,
              height: 1.0,
              color: valueColor ?? SorveteColors.inkGreen,
            ),
          ),
          SizedBox(height: 4),
          SelectableText(
            label,
            style: TextStyle(
              fontFamily: 'InstrumentSans',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: SorveteColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
```

### Eyebrow / Section Label

Used above headings throughout the app.

```dart
Widget sorveteEyebrow(String text) {
  return SelectableText(
    text.toUpperCase(),
    style: TextStyle(
      fontFamily: 'InstrumentSans',
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: SorveteColors.textMuted,
    ),
  );
}
```

### Status Badge / Tag

```dart
Widget sorveteBadge(String label, {Color? bg, Color? fg}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bg ?? SorveteColors.paleGreen,
      borderRadius: BorderRadius.circular(SorvetRadius.pill),
    ),
    child: SelectableText(
      label,
      style: TextStyle(
        fontFamily: 'InstrumentSans',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: fg ?? SorveteColors.forestGreen,
      ),
    ),
  );
}
```

### Hero / Dark Panel

For full-bleed green panels (dashboard headers, onboarding screens).

```dart
Container(
  color: SorveteColors.forestGreen,
  padding: EdgeInsets.all(SorveteSpacing.xl),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      sorveteEyebrow('Live overview'), // white version: override color
      SizedBox(height: SorveteSpacing.md),
      SelectableText(
        'Week 17',
        style: TextStyle(
          fontFamily: 'Fraunces',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -1,
        ),
      ),
      // KPI row below
    ],
  ),
)
```

---

## 9. Navigation

### Bottom Navigation Bar

```dart
NavigationBar(
  backgroundColor: SorveteColors.boneWhite,
  indicatorColor: SorveteColors.paleGreen,
  surfaceTintColor: Colors.transparent,
  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
  destinations: [
    NavigationDestination(
      icon: Icon(Icons.grid_view_outlined),
      selectedIcon: Icon(Icons.grid_view, color: SorveteColors.forestGreen),
      label: 'Overview',
    ),
    // ...
  ],
)
```

### App Bar

```dart
AppBar(
  backgroundColor: SorveteColors.boneWhite,
  elevation: 0,
  scrolledUnderElevation: 0,
  bottom: PreferredSize(
    preferredSize: Size.fromHeight(1),
    child: Divider(height: 1, color: SorveteColors.borderSubtle),
  ),
  title: SelectableText(
    'Sorvete',
    style: TextStyle(
      fontFamily: 'Fraunces',
      fontWeight: FontWeight.w700,
      fontSize: 20,
      letterSpacing: -0.5,
      color: SorveteColors.inkGreen,
    ),
  ),
)
```

---

## 10. Layout Rules

### Screen Padding

```dart
EdgeInsets.symmetric(horizontal: SorveteSpacing.pagePadding) // 24px sides
```

### Content Sections

Separate major sections with `SizedBox(height: SorveteSpacing.sectionGap)` (48px). Within sections use `SorveteSpacing.lg` (24px) between items.

### KPI Grid

Use a 2-column grid for metric cards:

```dart
GridView.count(
  crossAxisCount: 2,
  crossAxisSpacing: SorveteSpacing.sm,   // 8px
  mainAxisSpacing: SorveteSpacing.sm,    // 8px
  childAspectRatio: 1.6,
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  children: [ /* KpiCards */ ],
)
```

### List Items

Standard list item internal padding: `EdgeInsets.symmetric(horizontal: 16, vertical: 14)`.
Dividers between items use `SorveteColors.borderSubtle` at 1px.

---

## 11. Do's and Don'ts

### Do

- Use `SorveteColors.boneWhite` (`#faf7f2`) as the scaffold background — never pure white
- Use `Fraunces` for all numeric data displays and headings
- Use `Instrument Sans` for all UI labels, body copy, and button text
- Use `terracotta` as the single CTA/accent colour — do not introduce a second accent
- Keep border radius at 3–6px for interactive elements; only use `pill` radius for status badges
- Use `forestGreen` for primary actions and positive data; `terracotta` for CTAs and warnings
- Use negative letter spacing on all large Fraunces text
- Rely on border + background contrast for depth — avoid Material elevation shadows on cards
- Use `paleGreen` for selected/active row states in lists and nav

### Don't

- Don't use the system default blue (`Colors.blue`) anywhere — it breaks the palette immediately
- Don't use `FontWeight.w600` or `w700` in Instrument Sans — only Fraunces carries heavy weight
- Don't use card `elevation` > 0 except for modals and bottom sheets
- Don't use `Colors.grey` for muted text — use `SorveteColors.textMuted` (`#6b6560`)
- Don't add decorative gradients or mesh backgrounds — the design is flat by intent
- Don't use `ALL CAPS` for headings — reserve it only for eyebrow/overline labels at small sizes
- Don't mix `inkGreen` and `forestGreen` as competing backgrounds on the same screen — pick one
- Don't use rounded corners above `border-radius: 8` on cards — it reads as generic Material

---

## 12. Responsive / Adaptive Notes

| Breakpoint                     | Width     | Behaviour                                            |
| ------------------------------ | --------- | ---------------------------------------------------- |
| Mobile (phone)                 | < 600px   | Single column. `pagePadding: 24px`. Stack all grids. |
| Tablet                         | 600–900px | 2-column grids for KPIs and feature cards.           |
| Desktop (web/tablet landscape) | > 900px   | Hero uses 2-column split. Feature grid 2–3 columns.  |

For Flutter Web / large screens, wrap content in a max-width container:

```dart
Center(
  child: ConstrainedBox(
    constraints: BoxConstraints(maxWidth: 1200),
    child: /* page content */,
  ),
)
```

---

## 13. Quick Reference

```
Scaffold bg:     #faf7f2   Color(0xFFFAF7F2)
Primary brand:   #3a5c3e   Color(0xFF3A5C3E)
CTA / accent:    #c4542a   Color(0xFFC4542A)
Text primary:    #0f1a0e   Color(0xFF0F1A0E)
Text muted:      #6b6560   Color(0xFF6B6560)
Card surface:    #ffffff   Color(0xFFFFFFFF)
Card bg alt:     #ede8df   Color(0xFFEDE8DF)
Active/hover:    #e8f0e9   Color(0xFFE8F0E9)
Border:          rgba(15,26,14,0.10)

Display font:    Fraunces (700 / 300 italic)
Body font:       Instrument Sans (400 / 500)

Base spacing:    8px
Page padding:    24px
Card padding:    20px
Card radius:     6px
Button radius:   3px
```
