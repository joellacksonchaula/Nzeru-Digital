# Crypto Trading-Style Dashboard Implementation Guide

## Overview
This guide explains the new TradingView-style candlestick chart dashboard with crypto trading aesthetics. The dashboard uses a professional fintech theme with:
- **White background** (30%)
- **Black accents** (20%)
- **Red for losses** (10%)
- **Gold highlights** (5%)
- **MK currency formatting** with comma separators

---

## New Files & Components

### 1. **CandlestickChart Widget** (`lib/widgets/candlestick_chart.dart`)

A custom TradingView-style candlestick chart with full interactivity.

#### Features
- ✅ OHLC (Open, High, Low, Close) candle visualization
- ✅ Green candles for gains (close > open)
- ✅ Red candles for losses (close < open)
- ✅ Interactive timeframe selector (1m, 5m, 15m, 1h, 4h, 1d)
- ✅ Hover tooltips showing OHLC data
- ✅ Grid lines with price labels
- ✅ Refresh button
- ✅ High/Low statistics footer
- ✅ Smooth animations

#### Usage
```dart
final candles = [
  CandleData(
    time: DateTime.now().subtract(Duration(days: 1)),
    open: 1000,
    high: 1200,
    low: 800,
    close: 1150,
    volume: 10000,
  ),
  // More candles...
];

CandlestickChart(
  candles: candles,
  title: 'SAVINGS GROWTH',
  subtitle: 'Last 7 days',
  height: 300,
  onRefresh: () async {
    // Reload data
  },
  onTimeframeChanged: (timeframe) {
    print('Changed to $timeframe');
  },
)
```

#### CandleData Class
```dart
class CandleData {
  final DateTime time;      // Candle timestamp
  final double open;        // Opening price
  final double high;        // Highest price in period
  final double low;         // Lowest price in period
  final double close;       // Closing price
  final double volume;      // Trading volume
  
  bool get isGreen => close >= open;  // Profit indicator
}
```

---

### 2. **Currency Formatter Utility** (`lib/utils/currency_formatter.dart`)

Centralized currency formatting for Malawian Kwacha (MK).

#### Methods

```dart
// Standard format with comma separators
CurrencyFormatter.formatMK(1250000.00)
// Result: "MK 1,250,000.00"

// Compact format (millions/thousands)
CurrencyFormatter.formatCompact(1250000.00)
// Result: "MK1.3M"

// Number only (no symbol)
CurrencyFormatter.formatNumberOnly(1250000.00)
// Result: "1,250,000.00"

// Precise format (for display)
CurrencyFormatter.formatPrecise(1250.50)
// Result: "MK 1250.50"

// Percentage format
CurrencyFormatter.formatPercentage(12.5)
// Result: "+12.5%"

// Table format (right-aligned)
CurrencyFormatter.formatTableValue(1250.00)
// Result: "   MK 1,250.00" (padded)
```

#### Implementation
```dart
// In your widgets, use:
Text(
  CurrencyFormatter.formatMK(user.savingsBalance),
  style: GoogleFonts.orbitron(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.gold,
  ),
)
```

---

### 3. **New Dashboard (V2)** (`lib/screens/home/dashboard_screen_v2.dart`)

Complete redesign with crypto trading aesthetics.

#### Key Improvements

**Layout Structure:**
```
┌─────────────────────────────────┐
│ Header (Welcome + Notifications)│
├─────────────────────────────────┤
│ Total Savings Card              │
│ ├─ Amount (MK format)          │
│ ├─ Growth % badge              │
│ └─ Mini candlestick chart      │
├─────────────────────────────────┤
│ Quick Stats (4-tile grid)       │
│ ├─ Loan Balance                │
│ ├─ Financial Score             │
│ ├─ Active Plans                │
│ └─ Penalties                   │
├─────────────────────────────────┤
│ Quick Actions (horizontal)      │
│ ├─ Deposit                     │
│ ├─ New Plan                    │
│ ├─ Loan                        │
│ └─ Repay                       │
├─────────────────────────────────┤
│ Recent Transactions (list)      │
│ ├─ Transaction items           │
│ └─ View All button             │
└─────────────────────────────────┘
```

**Color Scheme:**
- Background: `#FFFFFF` (white)
- Cards: `#FDFDFD` (off-white)
- Borders: `#E0E0E0` (light gray)
- Text Primary: `#121212` (black)
- Text Muted: `#9E9E9E` (gray)
- Accent: `#D4AF37` (gold)
- Positive: `#2E7D32` (green)
- Negative: `#FF0000` (red)

**Currency Display:**
```dart
// Before: $1,250.00 USD
// After: MK 1,250,000.00
```

#### Implementation Details

**Transaction Card:**
```dart
Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: AppColors.cardBg,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.border, width: 0.5),
  ),
  child: Row(
    children: [
      // Icon (green for credit, red for debit)
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: txn.isCredit
              ? AppColors.success.withAlpha(20)
              : AppColors.actionRed.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          txn.isCredit
              ? Icons.arrow_downward_rounded
              : Icons.arrow_upward_rounded,
        ),
      ),
      // Info
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(txn.typeLabel),  // DEPOSIT, WITHDRAWAL, etc.
            Text(DateFormat('dd MMM yyyy, HH:mm').format(txn.date)),
          ],
        ),
      ),
      // Amount
      Text(
        '${txn.isCredit ? '+' : '-'}${CurrencyFormatter.formatMK(txn.amount)}',
        style: TextStyle(
          color: txn.isCredit ? AppColors.success : AppColors.actionRed,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  ),
)
```

---

## Migration Guide: Old Dashboard → New Dashboard

### Step 1: Update Imports
```dart
// OLD
import '../../utils/currency_util.dart';
import '../../widgets/crypto_chart.dart';
import '../../widgets/crypto_market_card.dart';

// NEW
import '../../utils/currency_formatter.dart';
import '../../widgets/candlestick_chart.dart';
```

### Step 2: Replace Currency Formatting
```dart
// OLD
Text(CurrencyUtil.format(amount))

// NEW
Text(CurrencyFormatter.formatMK(amount))
```

### Step 3: Update Routes
```dart
// In lib/config/app_routes.dart
// Update the dashboard route
const dashboard = '/dashboard/v2';

// Or in main.dart
home: auth.isLoggedIn ? const DashboardScreenV2() : const LoginScreen()
```

### Step 4: Replace Chart Widget
```dart
// OLD
LineChart(
  LineChartData(...)
)

// NEW
CandlestickChart(
  candles: candleData,
  title: 'DEPOSIT CHART (7D)',
  height: 80,
)
```

---

## Color Usage Guidelines

### Background Colors
- **Primary Background:** `AppColors.background` (#FFFFFF)
- **Card Background:** `AppColors.cardBg` (#FDFDFD)
- **Surface:** `AppColors.surface` (#F5F5F7)

### Text Colors
```dart
// Headlines
Text('Title', style: TextStyle(color: AppColors.textPrimary))

// Body text
Text('Description', style: TextStyle(color: AppColors.textSecondary))

// Muted/Helper text
Text('Helper', style: TextStyle(color: AppColors.textMuted))
```

### Status Colors
```dart
// Positive (gains, deposits)
color: AppColors.success (#2E7D32)

// Negative (losses, withdrawals)
color: AppColors.actionRed (#FF0000)

// Neutral (info, alerts)
color: AppColors.info (#1976D2)

// Warning
color: AppColors.warning (#F57C00)

// Premium/Highlight
color: AppColors.gold (#D4AF37)
```

---

## Currency Formatting Examples

| Value | Format | Result |
|-------|--------|--------|
| 1000 | formatMK | MK 1,000.00 |
| 1250000 | formatMK | MK 1,250,000.00 |
| 1250000 | formatCompact | MK1.3M |
| 1250000 | formatNumberOnly | 1,250,000.00 |
| 12.5 | formatPercentage | +12.5% |
| 1234.567 | formatPrecise | MK 1234.57 |

---

## Candlestick Chart Data Generation

### From Transaction History
```dart
// Convert recent transactions to candleData
final transactions = savings.transactions.take(7).toList().reversed.toList();
final candles = transactions.map((txn) {
  final amount = txn.amount.toDouble();
  return CandleData(
    time: txn.date,
    open: amount * 0.9,
    high: amount,
    low: amount * 0.7,
    close: amount,
    volume: amount,
  );
}).toList();
```

### From Daily Aggregates
```dart
// Group by day and calculate OHLC
final dailyData = <DateTime, List<Transaction>>{};
for (final txn in transactions) {
  final dayKey = DateTime(txn.date.year, txn.date.month, txn.date.day);
  dailyData.putIfAbsent(dayKey, () => []).add(txn);
}

final candles = dailyData.entries.map((entry) {
  final amounts = entry.value.map((t) => t.amount.toDouble()).toList();
  amounts.sort();
  
  return CandleData(
    time: entry.key,
    open: amounts.first,
    high: amounts.last,
    low: amounts.first,
    close: amounts.last,
    volume: amounts.reduce((a, b) => a + b),
  );
}).toList();
```

---

## Testing Checklist

- [ ] Dashboard loads without errors
- [ ] Candlestick chart displays with sample data
- [ ] Timeframe selector changes chart data
- [ ] Hover over candles shows tooltip
- [ ] Currency formats with commas (e.g., MK 1,250,000.00)
- [ ] Colors match specifications (white/black/red/gold)
- [ ] Responsive on mobile and web
- [ ] Quick actions navigate to correct screens
- [ ] Recent transactions display with correct icons
- [ ] Pull-to-refresh reloads data
- [ ] All text uses correct font families (Orbitron, Inter)

---

## Performance Optimization Tips

1. **Limit transactions displayed:** Use `.take(5)` or `.take(10)`
2. **Lazy load candlestick data:** Only generate candles when chart is visible
3. **Cache currency formatting:** Use a utility class (already implemented)
4. **Avoid rebuilds:** Use `const` for static widgets
5. **Use `RepaintBoundary`:** Around complex charts if performance is an issue

```dart
RepaintBoundary(
  child: CandlestickChart(
    candles: candles,
  ),
)
```

---

## Common Issues & Solutions

### Issue: Chart not displaying
**Solution:** Verify `candles` list is not empty:
```dart
if (candles.isEmpty) {
  return Center(child: Text('No data available'));
}
CandlestickChart(candles: candles)
```

### Issue: Currency format showing scientific notation
**Solution:** Use `formatPrecise()` instead of `toStringAsFixed()`:
```dart
// BAD
Text('${txn.amount}')  // 1.25E+6

// GOOD
Text(CurrencyFormatter.formatMK(txn.amount))  // MK 1,250,000.00
```

### Issue: Chart performance slow with many candles
**Solution:** Limit to last 30-100 data points:
```dart
final candles = allCandles.skip(allCandles.length - 30).toList();
```

### Issue: Tooltip not showing on hover
**Solution:** Ensure chart is wrapped in `MouseRegion`:
```dart
MouseRegion(
  onHover: (event) { ... },
  child: CustomPaint(painter: ...),
)
```

---

## Next Steps

1. **Deploy updated backend** with entrypoint fixes
2. **Update main.dart** to use `DashboardScreenV2`
3. **Test on multiple devices** (Android, iOS, Web)
4. **Monitor performance** on low-end devices
5. **Collect user feedback** on UI/UX
6. **Consider adding:**
   - Daily/weekly/monthly savings charts
   - Goal progress visualization
   - Spending breakdown pie charts
   - Loan repayment timeline
   - Interest earnings projection

---

## Related Files

- Backend: `backend/entrypoint.sh`, `backend/config/settings.py`
- Frontend: All currency usages updated to use `CurrencyFormatter`
- Models: No changes to data models needed
- Colors: Finalized in `lib/config/app_colors.dart`
