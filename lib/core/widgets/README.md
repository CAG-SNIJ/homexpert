# Reusable Widgets

This folder contains reusable widgets that can be used throughout the app.

## 📦 Available Widgets

### 1. `HorizontalCardList`
A reusable horizontal scrolling card list widget.

**Usage:**
```dart
import 'package:homexpert/core/widgets/horizontal_card_list.dart';

HorizontalCardList(
  children: [
    YourCard1(),
    YourCard2(),
    YourCard3(),
  ],
  height: 280,              // Optional, default: 280
  spacing: 20,              // Optional, default: 20
  padding: EdgeInsets.all(16), // Optional
)
```

**Features:**
- Automatically centers the list
- Handles spacing between cards
- Horizontal scrolling
- Customizable height and padding

---

### 2. `HoverableCard`
A reusable hoverable card with elevation and shadow effects.

**Usage:**
```dart
import 'package:homexpert/core/widgets/hoverable_card.dart';

HoverableCard(
  child: YourContent(),
  width: 300,                    // Optional, default: 300
  borderRadius: 12,              // Optional, default: 12
  hoverElevation: 8.0,          // Optional, default: 8.0
  animationDuration: Duration(milliseconds: 300), // Optional
)
```

**Features:**
- Automatic hover detection
- Smooth elevation animation
- Dynamic shadow effects
- Customizable styling

---

### 3. `CityCard` (in homepage_explore_section.dart)
A reusable city card widget with image and description.

**Usage:**
```dart
import 'package:homexpert/features/user/widgets/homepage_explore_section.dart';

CityCard(
  city: 'Kuala Lumpur',
  description: 'Explore properties...',
  imageUrl: 'https://...',
  onTap: () {
    // Handle tap
  },
)
```

**Features:**
- Built-in hover effects (uses HoverableCard)
- Image and text layout
- Clickable (optional onTap)

---

## 🎯 Example: Using Together

```dart
HorizontalCardList(
  children: [
    CityCard(
      city: 'Kuala Lumpur',
      description: 'Explore properties...',
      imageUrl: 'https://...',
      onTap: () => navigateToCity('kl'),
    ),
    CityCard(
      city: 'Penang',
      description: 'Find properties...',
      imageUrl: 'https://...',
      onTap: () => navigateToCity('penang'),
    ),
  ],
)
```

---

## 📝 Notes

- All widgets are fully customizable
- Hover effects work on web and desktop
- Widgets follow the app theme automatically
- Can be used in any screen/module

