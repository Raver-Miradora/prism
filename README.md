# PRISM (Program Registry for Intern and Student Management)

PRISM is a powerful, offline-first companion application designed for government interns. It reliably tracks working hours, enforces location and identity verification, and automates the generation of official Civil Service Commission (CSC) Form 48 compliant reports.

## Core Philosophy
- **Offline-First**: All data is persisted locally via SQLite. The app is fully functional out in the field with no continuous internet requirement.
- **Compliance**: Produces strict, grid-based standard reporting formats (such as the CSC Form 48).
- **Frictionless**: Clean "yap-to-report" journaling workflow.
- **Digital Registry Design**: Beautiful, professional UI crafted under the "Civic Horizon" design system.

## Key Features
- **Identity-Verified Timeclock**: GPS-locked check-in and check-out tracking combined with selfie camera verification.
- **"Hourglass" Requirement Tracker**: Calculate accumulated vs. target hours automatically, including minute-based late deductions and undertime.
- **Automated Timesheet PDF**: Generates the exact formatting required for the CSC Form 48 DTR (Daily Time Record) using standard rendering tools.
- **"Yap-to-Report" Engine**: Synthesize your daily informal journal notes directly into an official government output.
- **Safe Local Data**: Built-in mechanisms to backup and restore your local registry databases preventing data loss.

## Tech Stack
- **Framework**: [Flutter](https://flutter.dev/) (Cross-platform Dart)
- **State Management**: [Riverpod](https://riverpod.dev/) 
- **Database**: `sqflite`
- **Native Integrations**: `geolocator`, `camera`, `path_provider`, `pdf`, `printing` 

## Current Implementation Status

This repository contains the foundational **Project Blueprint** and the fully translated Flutter **UI Widgets** (converted directly from Google Stitch mockups via Tailwind/HTML).

The UI code is housed in `lib/ui/` and is entirely stateless. The next development phase involves wiring these beautiful, pixel-perfect UI screens to the local SQLite database leveraging Riverpod.

## Getting Started

To review the layout modules:
1. Ensure your machine has Flutter installed.
2. If the project isn't initialized natively, run `flutter create .`
3. Add the font dependencies to your `pubspec.yaml`:
```bash
flutter pub add google_fonts material_symbols_icons
```
4. Render the modules found in `lib/ui/` and apply the `CivicHorizonTheme` in `lib/core/theme/`.
