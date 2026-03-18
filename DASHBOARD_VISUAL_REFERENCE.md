# Dashboard Visual Reference & Component Guide

## Dashboard Layout Map

```
┌─────────────────────────────────────────────────────────────┐
│  HEADER SECTION                                             │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ Welcome back, [User Name]     🔔  👤               │
│  │ [Orbitron Bold, Black #121212]                      │
│  │                           [Gold, Small]              │
│  └─────────────────────────────────────────────────────────┘│
├─────────────────────────────────────────────────────────────┤
│  SAVINGS CARD SECTION                                       │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ TOTAL SAVINGS          │  ┌─────────────────┐         │
│  │ [Orbitron, Muted]      │  │ 📈 +12.5%       │         │
│  │                        │  │ [Green Box]     │         │
│  │ MK 1,250,000.00        │  └─────────────────┘         │
│  │ [Orbitron Bold, Gold]  │                             │
│  │                        │                             │
│  │ [Candlestick Chart]    │ 7-day deposit history       │
│  │   ▂▅▃▇▆▅█             │                             │
│  │   Red & Green candles  │                             │
│  └─────────────────────────────────────────────────────────┘│
├─────────────────────────────────────────────────────────────┤
│  QUICK STATS GRID                                           │
│  ┌─────────────────────────┐ ┌─────────────────────────┐  │
│  │ 👛 LOAN BALANCE         │ │ 🚀 FINANCIAL SCORE      │  │
│  │ MK 500,000.00           │ │ 750                     │  │
│  │ [Info Blue]             │ │ [Gold]                  │  │
│  └─────────────────────────┘ └─────────────────────────┘  │
│  ┌─────────────────────────┐ ┌─────────────────────────┐  │
│  │ 💰 ACTIVE PLANS         │ │ ⚠️  PENALTIES            │  │
│  │ 3                       │ │ MK 10,000.00            │  │
│  │ [Green]                 │ │ [Red]                   │  │
│  └─────────────────────────┘ └─────────────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│  QUICK ACTIONS HORIZONTAL SCROLL                            │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐      │
│  │ ➕ DEPOSIT   │ │ ➕ NEW PLAN  │ │ 💳 LOAN      │ ...  │
│  │ [Gold]       │ │ [Green]      │ │ [Blue]       │      │
│  └──────────────┘ └──────────────┘ └──────────────┘      │
├─────────────────────────────────────────────────────────────┤
│  RECENT TRANSACTIONS                                        │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ RECENT TRANSACTIONS               View All →           │
│  │                                                         │
│  │ ┌──────────────────────────────────────────────────┐  │
│  │ │ 📥 DEPOSIT                    15 Jan 2026, 10:30 │  │
│  │ │ +MK 100,000.00                      [Green]     │  │
│  │ └──────────────────────────────────────────────────┘  │
│  │ ┌──────────────────────────────────────────────────┐  │
│  │ │ 📤 WITHDRAWAL                  14 Jan 2026, 14:20 │  │
│  │ │ -MK 50,000.00                       [Red]       │  │
│  │ └──────────────────────────────────────────────────┘  │
│  │ ┌──────────────────────────────────────────────────┐  │
│  │ │ 🎯 INTEREST REWARD             13 Jan 2026, 09:00 │  │
│  │ │ +MK 25,000.00                      [Green]     │  │
│  │ └──────────────────────────────────────────────────┘  │
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

---

## Color Reference Chart

### Primary Colors
```
WHITE (#FFFFFF)           ████████████████████████
Background for all cards and main area. 30% of design.

BLACK (#121212)           ████████████████████████
Primary text and dark accents. 20% of design.

GOLD (#D4AF37)            ████████████████████████
Premium highlights and important elements. 5% of design.

RED (#FF0000)             ████████████████████████
Negative indicators (losses, warnings). 10% of design.
```

### Secondary Colors
```
GREEN (#2E7D32)           ████████████████████████
Positive indicators (gains, success).

BLUE (#1976D2)            ████████████████████████
Info and neutral actions.

LIGHT GRAY (#E0E0E0)      ████████████████████████
Borders and subtle dividers.

MUTED GRAY (#9E9E9E)      ████████████████████████
Helper text and muted labels.
```

---

## Component Specifications

### Stat Tile
```
┌────────────────────────────────┐
│ LABEL (Small, Muted)           │
│ ┌──────────────────────────┐  │
│ │ Icon with bg color       │  │
│ └──────────────────────────┘  │
│                                │
│ VALUE                          │
│ (Large, Bold, Themed)          │
└────────────────────────────────┘

Width:      50% of parent (in 2-column grid)
Height:     120px
Border:     0.5px, Light Gray
Border Radius: 12px
Font:       Google Fonts (Orbitron for value)
```

### Transaction Card
```
┌─────────────────────────────────────────┐
│ ┌──────┐  Type Name       Date          │
│ │ Icon │  (Bold)          (Muted)       │  Amount
│ │ (20) │                                │  (Bold, Gold)
│ └──────┘  Timestamp (11px)              │
└─────────────────────────────────────────┘

Icon BG:    Color.withAlpha(20)
Icon Size:  20px
Padding:    12px all
Border:     0.5px, Light Gray
Radius:     12px
```

### Candlestick Chart
```
MAX   ▔▔▔▔▔▔▔▔▔▔ Price Label
      │     │
      │  █░ │ Green Candle
      │  █░ │
      │     │
      │  ░█ │ Red Candle
      │  ░█ │
MIN   ▔▔▔▔▔▔▔▔▔▔ Price Label

Height:      80-300px (configurable)
Width:       Full (with padding)
Grid Lines:  5 horizontal
Candle Body: 0.8x spacing width
Wick:        1.5px stroke
Hover:       Tooltip with OHLC
```

### Quick Action Button
```
┌────────────────┐
│  ┌──────────┐  │
│  │    Icon  │  │
│  │ (Color)  │  │
│  └──────────┘  │
│                │
│    ACTION      │
│    LABEL       │
└────────────────┘

Width:         80px
Height:        95px
Border:        1px, Color.withAlpha(30)
Border Radius: 16px
Icon Size:     22px
Font Size:     10px (label)
Icon BG:       Color.withAlpha(20), circular
```

---

## Typography Guide

### Font Families
```
Headlines & Labels:     Orbitron
  - Size: 11-20px
  - Weight: 600-700
  - Letter Spacing: 1-2
  - Color: Black or Gold

Body Text:              Inter
  - Size: 12-16px
  - Weight: 400-600
  - Color: Black or Muted Gray

Numbers/Currency:       Orbitron
  - Size: 13-34px
  - Weight: 600-700
  - Color: Gold or status color
```

### Text Styles

**Header Text**
```dart
Text('Welcome back,',
  style: GoogleFonts.inter(
    fontSize: 14,
    color: AppColors.textMuted,
  ),
),
```

**Large Amount**
```dart
Text('MK 1,250,000.00',
  style: GoogleFonts.orbitron(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.gold,
    letterSpacing: 1,
  ),
),
```

**Small Label**
```dart
Text('TOTAL SAVINGS',
  style: GoogleFonts.orbitron(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 2,
  ),
),
```

---

## Spacing Standards

```
Component Padding:       12-16px
Card Padding:            16-20px
Horizontal Spacing:      20px (sides)
Vertical Spacing:        12-24px
Icon to Text:            8-12px
Grid Gap:                12px
Border Width:            0.5-1px
Border Radius:           8-16px
```

---

## Responsive Breakpoints

```
Mobile:      < 600px
  - Single column layouts
  - Horizontal scroll for grids
  - Full-width cards

Tablet:      600-900px
  - 2-column grids
  - Larger padding
  - Optimized spacing

Desktop:     > 900px
  - 3-column grids
  - Maximum width constraints
  - Enhanced spacing
```

---

## Currency Display Examples

### Different Amounts
```
MK 1,000.00              ← Thousands
MK 10,000.00             ← Ten thousands
MK 100,000.00            ← Hundred thousands
MK 1,000,000.00          ← Millions
MK 1,250,000.00          ← Millions with decimals

Compact Format:
MK1K                     ← 1,000
MK10K                    ← 10,000
MK1M                     ← 1,000,000
MK1.3M                   ← 1,250,000
```

### In Context
```
Transaction Positive:
  +MK 100,000.00  [Green text, Orbitron bold]

Transaction Negative:
  -MK 50,000.00   [Red text, Orbitron bold]

Stat Display:
  MK 1,250,000.00 [Gold text, Orbitron bold, size 24]
```

---

## Interactive States

### Button Hover/Press
```
Default:   Color with opacity 1.0
Hover:     Color with opacity 0.8
Pressed:   Color with opacity 0.6
Disabled:  Gray with opacity 0.5
```

### Candlestick Hover
```
Hovered candle:
  - Border: 2px color with opacity 0.8
  - Background highlight box around wick

Tooltip:
  - Black background with opacity 0.8
  - Gold border subtle
  - Position: above/right of candle
```

### Transaction Card Hover
```
Default:   Normal appearance
Hover:     Slightly lighter background
Pressed:   Route to transaction detail
```

---

## Accessibility Features

### Color Contrast
```
Text on White:
  - Black #121212 on White #FFFFFF ✅ (21:1 ratio)
  - Muted #9E9E9E on White #FFFFFF ✅ (4.5:1 ratio)

Status Colors:
  - Green #2E7D32 on White ✅ (5.7:1 ratio)
  - Red #FF0000 on White ✅ (5.3:1 ratio)
  - Gold #D4AF37 on White ✅ (6:1 ratio)
```

### Touch Targets
```
Minimum touch size: 48x48px
Button height: 95px (quick actions)
Icon size: 20-26px
Spacing between buttons: 12px
```

### Font Sizes
```
Minimum readable: 11px (labels only)
Body text: 12-14px
Headers: 16-34px
Labels: 11-12px
All sizes meet WCAG guidelines
```

---

## Animation & Transitions

```
Default Duration:        300ms
Fade In:                 300ms ease-in-out
Slide Up:                300ms with begin: 0.1
Scale:                   200ms
Refresh Rotate:          600ms linear
Hover Effects:           150ms ease-out
```

---

## Dark Mode Preparation (Future)

Colors for dark mode:
```
Background:      #121212 (very dark)
Card:            #1E1E1E (dark gray)
Text Primary:    #FFFFFF (white)
Text Secondary:  #BDBDBD (light gray)
Gold:            #D4AF37 (unchanged)
Green:           #81C784 (lighter for contrast)
Red:             #FF8A80 (lighter for contrast)
```

---

## Component Usage Examples

### Creating a Stat Tile
```dart
StatTile(
  icon: Icons.speed_rounded,
  label: 'FINANCIAL SCORE',
  value: '750',
  iconColor: AppColors.gold,
  valueColor: AppColors.gold,
)
```

### Formatting Currency
```dart
Text(
  CurrencyFormatter.formatMK(1250000),
  style: GoogleFonts.orbitron(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.gold,
  ),
)
```

### Creating Candlestick Chart
```dart
CandlestickChart(
  candles: candleData,
  title: 'DEPOSIT CHART (7D)',
  height: 80,
  onTimeframeChanged: (tf) => setState(() { ... }),
)
```

---

## Brand Identity

**Theme:** Professional Fintech / Crypto Trading
**Mood:** Premium, Modern, Trustworthy
**Target:** Conservative savers, loan borrowers

**Key Design Principles:**
1. Clarity - Clean lines, readable text
2. Confidence - Bold fonts, strong colors
3. Safety - Professional appearance
4. Efficiency - Quick information access
5. Responsiveness - Works on all devices

---

## Debugging Visual Issues

### Issue: Colors look different
**Check:** Are you using the correct hex values from AppColors?

### Issue: Text overlapping
**Check:** Ensure FontSizes and Padding match specifications

### Issue: Chart not rendering
**Check:** Is candleData list empty? Verify size constraints

### Issue: Responsive layout broken
**Check:** Are you using Expanded/Flexible? Is SingleChildScrollView present?

---

**Reference Version:** 1.0
**Last Updated:** March 18, 2026
**Status:** Final
