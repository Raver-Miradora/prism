<div align="center">
  <h1>PRISM</h1>
  <p><strong>Program Registry for Intern and Student Management</strong></p>

  [![PRISM CI/CD](https://github.com/Raver-Miradora/prism/actions/workflows/prism_ci_cd.yml/badge.svg)](https://github.com/Raver-Miradora/prism/actions/workflows/prism_ci_cd.yml)
  ![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
  ![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
  ![SQLite](https://img.shields.io/badge/sqlite-%2307405e.svg?style=for-the-badge&logo=sqlite&logoColor=white)

  <p>
    An intelligent, offline-first companion application designed for government interns, SPES, and OJT students to track hours, enforce locations, and generate pixel-perfect official reports on the go.
  </p>
  
  ---
  
  ### 📥 [Download Latest APK](https://github.com/Raver-Miradora/prism/actions)
  *(Click "Actions", select the latest successful build, and download the `PRISM-Android-APKs` artifact!)*
</div>

<br/>

## ✨ Why PRISM?
Say goodbye to messy logbooks, forgotten biometric punches, and manual document formatting. PRISM was built with the **"Civic Horizon"** design system to provide a premium, frictionless experience tailored specifically for civil service expectations. 

* 📵 **True Offline-First:** Out in the field or in a dead zone? No problem. All database actions, time tracking, and even complex PDF rendering happen 100% locally on your device.
* ⚖️ **Government Compliant:** Stop wrestling with Word documents. PRISM's mathematical engine strictly enforces DTR rules (stripping excess overtime, dynamically calculating undertime) and natively outputs a pixel-perfect **Civil Service Commission (CSC) Form 48**.
* 🧑‍💻 **Twin Report Generation:** Need an editable file? PRISM powers a dual-generation engine that outputs both an immutable, high-fidelity PDF and an editable `DOCX` file simultaneously.

## 🚀 Key Features

- **📍 Identity-Verified Timeclock:** Check-in and check-out tracking locked with high-accuracy GPS coordinates and selfie-camera verification to ensure authenticity.
- **⏳ "Hourglass" Engine:** Automatically tracks your accumulated vs. target hours, strictly enforces actual minute-based late deductions, and maps official work shifts (e.g. 8:00 AM – 5:00 PM).
- **📋 "Yap-to-Report" Workflow:** Jot down informal notes throughout the day in your journal. PRISM intelligently synthesizes these notes into structured summary bullets for your official Accomplishment Report.
- **🌙 Deep Dark Mode:** Beautiful, battery-saving dark mode with vibrant interactive elements utilizing Material 3 guidelines.
- **💾 Safe Local Data:** Built with a resilient `sqflite` architecture.

## 🛠️ Technology Stack

Designed for high performance, stability, and future extensibility:

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **Architecture & State:** [Riverpod 2.0](https://riverpod.dev/) (Unidirectional, immutable data streams)
- **Local Persistence:** `sqflite` / `shared_preferences`
- **Document Rendering:** `pdf` for Forms, `docx_template` for template injection.
- **Hardware Integration:** `geolocator` (Location API) and `camera` (Hardware API)
- **CI/CD:** Automated testing and APK artifact generation via **GitHub Actions**.

## 🛡️ Production Hardening
PRISM has undergone a rigorous internal audit to ensure production-grade stability and resilience.
- **[Audit Report (April 2026)](docs/HARDENING_AUDIT.md)**: 18 findings resolved across memory management, null safety, and async context logic.
- **Stability**: Zero-crash tolerance for corrupted SQLite entries and legacy database migrations.
- **Performance**: Optimized real-time UI synchronization and resource lifecycle management.

## 📱 Downloading & Installation

You don't need to be a developer to install PRISM on your Android device!

1. Navigate to the **[Actions Tab](https://github.com/Raver-Miradora/prism/actions)** in this repository.
2. Click on the latest successful **"PRISM CI/CD"** workflow run.
3. Scroll down to the **Artifacts** section and click on **`PRISM-Android-APKs`** to download the ZIP file.
4. Extract the ZIP on your phone and install the appropriate APK (`arm64-v8a` for most modern devices).

> **Note:** Since this is an independent open-source application, you may need to allow "Install from Unknown Sources" in your Android settings.

## 💻 Building from Source

If you want to contribute, run the app locally, or run the test suite:

**1. Clone the repository**
```bash
git clone https://github.com/Raver-Miradora/prism.git
cd prism
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Run the Automated Test Suite**
Verify the core Hourglass DTR math engine:
```bash
flutter test test/timeclock_logic_test.dart
```

**4. Run the app**
```bash
flutter run
```

---
<div align="center">
  <i>Bringing civic technology into the future.</i>
</div>
