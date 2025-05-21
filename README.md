# My Budget King

A macOS budgeting application designed to help users manage personal and family budgets, track income and expenses, and generate financial reports.

---

## Author

Sean Sullivan

---

## Features

- Create and edit personal or family budgets
- Track actual monthly income and expenses
- Import and export budget data (JSON/CSV)
- Customizable themes (header color, section color, row highlight color)
- Generate and export financial reports (RTF format)
- Export Monthly Comparison reports (RTF format)
- Choose export file name and destination with save panel
- Validation alerts when attempting to export empty reports
- View year-over-year comparisons
- Easy-to-use navigation sidebar
- Splash screen with app title, logo, and fade-in animation

---

## Splash Screen

Starting with this version, a custom SwiftUI-based splash screen is used instead of a LaunchScreen storyboard.

- **SplashScreenView.swift** shows:
  - App title
  - App version
  - App icon (`mbk-icon-1024`)
- Displays for 2–3 seconds before transitioning to the main view
- No storyboard or LaunchScreen.storyboard is used

---

## Setup Instructions

1. Open the project in Xcode.
2. Make sure **Assets.xcassets** includes the following:
   - `mbk-icon-1024` (App icon for splash screen)
3. Build and run the project.
4. The app will display a splash screen before launching into the main dashboard.

---

## Notes

- Ensure the image `mbk-icon-1024` is added inside **Assets.xcassets**.
- If you get an error like `No image named 'mbk-icon-1024' found`, clean build folder (`Shift + Cmd + K`) and rebuild (`Cmd + B`).
- Mac apps do not use a real launch screen by default; the splash is manually shown with SwiftUI.

---

### [v1.2.0] - Release Date: 2025-05-21

**Enhancements:**

- **Sidebar Buttons**:
  - Updated selected page buttons in the sidebar to always appear **blue with white text**, consistent in both Light and Dark Mode.
  - Ensured unselected buttons have proper contrast:
    - **Black text** in Light Mode
    - **Gray text** in Dark Mode

- **Settings Button**:
  - Restyled the "Settings" button to always display with a **blue background and white text**.
  - Centered the gear icon and the "Settings" text horizontally within the button for a more polished appearance.

- **⚙️ Settings Popup**:
  - **Appearance Toggle**:
    - Re-enabled Light / Dark / System appearance toggle inside the Settings popup.
    - App now respects the user’s selected theme from this control (or defaults to System if selected).

- **Bug Fixes**:
  - Cleand up UI when system is in Dark/Light Mode so its easier to see

### [v1.1.0] - Release Date: 2025-05-04

**Enhancements:**

- **Splash Screen Improvements**:
  - Added slight delay for smoother transition into main view
  - Ensured proper fade-in using `withAnimation` and `AppState.shared.isAppReady`

- **Reports Page Enhancements**:
  - Improved layout for income and expense sections to match styling across the app
  - Ensured “Income” title appears above section box for visual consistency
  - Added spacing and formatting tweaks for better readability

- **RTF Export Updates**:
  - Enhanced Reports and Monthly Comparison RTF outputs with aligned columns and headers
  - Added section labels (Income, Expenses) and groupings by category for clarity
  - Fixed alignment bugs and export issues with `CVarArg` and invalid pointer crashes
  - Added save panel allowing user to choose destination and filename

- **Validation Handling**:
  - Prevented export if no data is loaded, with user alert shown instead

- **Theme & UI Consistency**:
  - Matched button styles (e.g., “Export RTF”) across all pages
  - Standardized dark/light mode compatibility, with fallback primary color for missing accent colors

- **Bug Fixes**:
  - Removed deprecated `onChange(of:perform:)` syntax
  - Updated macOS 14+ compatibility warnings for file type filters (`allowedFileTypes` → `allowedContentTypes`)
  - Added safe decoding fallback in `AppSettings.swift` using `unarchivedObject(ofClass:from:)`

### [v1.0.0] - Release Date: 2025-04-28

**Initial Creation:**

- Created the base macOS app: **My Budget King**
- Implemented **SplashScreenView.swift** to show:
  - App title ("My Budget King")
  - App version ("Version 1.0.0")
  - App icon ("mbk-icon-1024")
- Added **Assets.xcassets** entries:
  - Imported `mbk-icon-1024` for splash screen and branding
- Created **AppSettings.swift**:
  - Manages customizable theme colors (header, section background, highlight rows)
- Built **MainAppView.swift**:
  - Displays navigation sidebar and main content areas
- Added **Budget Setup Page**:
  - Create and edit monthly budgets by category
- Added **Monthly Actuals Page**:
  - Enter real-world income and expense values for each month
- Added **Reports Page**:
  - Compare budgeted vs actuals
  - Show trend arrows (up, down, equal) for financial results
- Added **Settings Popup View**:
  - Change theme colors
  - Manage app preferences
- Implemented **Data Persistence**:
  - Save and load budget data using JSON files
- Implemented **RTF Export** for financial reports
- Set up **basic animations** (fade-in, transitions) between splash and main view
- No storyboard used (pure SwiftUI lifecycle)

---
