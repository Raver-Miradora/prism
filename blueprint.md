# PRISM (Program Registry for Intern and Student Management)
## Project Blueprint & Technical Architecture

### 1. Project Overview
**PRISM** is an offline-first companion application designed for government interns. Its primary purpose is to reliably track working hours, enforce location and identity verification, and automate the generation of official Civil Service Commission (CSC) compliant reports (such as Form 48). 

**Core Philosophy:** 
- **Offline-First:** No reliance on continuous internet connectivity. All data is persisted locally to ensure immediate availability.
- **Compliance:** Adheres perfectly to strict formatting required by government agencies (specifically CSC Form 48).
- **Frictionless:** Simple, automated "yap-to-report" journaling and intuitive UX.

---

### 2. Finalized Technology Stack

#### Frontend Layer
- **Framework:** Flutter (Cross-platform compilation, natively running on Android/iOS).
- **UI Components:** Imported via Google Stitch exports (focus strictly on wiring logic and state).

#### State Management Layer
- **Library:** **Riverpod**
  - *Why Riverpod?* It provides compile-time safety, easier testing, and seamlessly handles asynchronous streams from local SQLite databases compared to standard Provider. It is the modern standard for scalable Flutter apps and integrates well with local-first architectures.

#### Local Backend & Data Layer
- **Database:** `sqflite` (Standard SQLite integration for Flutter).
- **Migrations & Queries:** Direct SQL schemas wrapped in robust Repository patterns for clean abstraction.

#### Device Native Integrations
- **Geolocation (GPS):** `geolocator` (for acquiring high-accuracy lat/long coordinates upon clock-in/out).
- **Camera (Selfie Verification):** `camera` or `image_picker` (to capture identity snapshots securely).
- **File Storage:** `path_provider` (to manage local app directories for storing images and PDFs).
- **PDF Generation:** `pdf` and `printing` packages (powerful layout engine strictly mapping data to CSC Form 48 grids).

#### External API (Future/Optional)
- **AI Processing:** Generative AI API (e.g., Google Gemini / OpenAI) via the `http` package for the "Yap-to-Report" formatting.

---

### 3. Core Features & Architecture

#### 3.1. Offline-First Timeclock (Identity & Location verified)
Logs the intern’s exact time of arrival and departure, tagged with geographic coordinates and a selfie to prevent proxy-attendance.

**Database Schema: `time_logs` Table**
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | INTEGER | Primary Key, Auto-increment |
| `date` | TEXT | ISO8601 Date (YYYY-MM-DD) |
| `time_in` | TEXT | ISO8601 DateTime |
| `time_out` | TEXT | ISO8601 DateTime (Nullable for active shifts) |
| `latitude_in` | REAL | GPS Latitude upon clock-in |
| `longitude_in` | REAL | GPS Longitude upon clock-in |
| `latitude_out` | REAL | GPS Latitude upon clock-out (Nullable) |
| `longitude_out` | REAL | GPS Longitude upon clock-out (Nullable) |
| `photo_path_in` | TEXT | Local file path to selfie upon clock-in |
| `photo_path_out`| TEXT | Local file path to selfie upon clock-out (Nullable) |

**Key Functions:**
- `Future<void> clockIn({required Position gps, required String photoPath})`
- `Future<void> clockOut({required Position gps, required String photoPath})`
- `Stream<List<TimeLog>> watchDailyLogs()`

#### 3.2. "Hourglass" Requirement Tracker
An analytic engine that calculates total rendered hours against the intern's required quota (e.g., 486 hours) and accounts for late deductions or undertime based on expected schedules.

**Database Schema: `intern_settings` Table**
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | INTEGER | Primary Key (Always 1 - Singleton pattern) |
| `target_hours` | INTEGER | Default e.g., 486 |
| `expected_time_in` | TEXT | HH:MM format (e.g., 08:00) |
| `expected_time_out`| TEXT | HH:MM format (e.g., 17:00) |
| `lunch_break_mins` | INTEGER | Default 60 mins |

**Key Functions:**
- `double calculateActualHours(TimeLog log)`: Deducts lunch breaks automatically based on start/end times.
- `double calculateAccumulatedHours()`: Sums all valid, completed `time_logs`.
- `int calculateLateDeductions(TimeLog log, String expectedIn)`: Computes minute-based tardiness.

#### 3.3. "Yap-to-Report" Local Engine
Interns can type quick, informal notes ("yaps") daily. These are locally stored and can later be passed to an AI engine to convert into formal civil service vocabulary.

**Database Schema: `daily_reports` Table**
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | INTEGER | Primary Key |
| `date` | TEXT | ISO8601 Date |
| `raw_notes` | TEXT | User's informal text input |
| `formal_report` | TEXT | AI-generated/User-edited formal text (Nullable) |

**Key Functions:**
- `Future<void> saveRawNotes(String date, String notes)`
- `Future<String> generateFormalReport(String rawNotes)`: *Placeholder Engine.* We will implement a mock function currently that returns standard phrases, which will easily be swapped to an HTTP call out to an LLM endpoint, prompt-engineered to translate slang to "Government Professional" English.

#### 3.4. CSC Form 48 PDF Generator
At the end of the month, the app queries the local SQLite DB to generate a strict, grid-based PDF of the standard Civil Service Form 48 (Daily Time Record).

**Key Functions:**
- `Future<List<TimeLog>> fetchMonthlyLogs(int month, int year)`
- `Future<Uint8List> buildForm48PDF(List<TimeLog> logs, InternProfile profile)`: Uses `pdf` widgets to aggressively draw exact borders, padding, and standardized fonts matching the physical DTR card provided by the CSC.
- `Future<void> exportAndSharePDF(Uint8List pdfData)`: Integrates with Native Share sheets so the intern can email or print it.

#### 3.5. [Expanded Feature] Profile Management
Necessary metadata for the Form 48 generation.

**Database Schema: `intern_profile` Table**
| Column | Type | Description |
| :--- | :--- | :--- |
| `name` | TEXT | Full name of intern |
| `agency_office` | TEXT | e.g. "Department of Education" |
| `supervisor_name`| TEXT | Official Signatory on the Form 48 |

#### 3.6. [Expanded Feature] Local Backup & Restore
Since PRISM is purely offline by design, phone damage or app deletion causes total data loss. A manual backup mechanism is critical.

**Key Functions:**
- `Future<File> exportSQLiteBackup()`: Copies `prism.db` to a user-selectable directory (e.g., local Downloads folder) allowing them to manually back it up to Google Drive.
- `Future<void> importSQLiteBackup(File backupPath)`: Restores previous data safely by overwriting the local `.db`.

---

### 4. Recommended Directory Structure (Flutter/Clean Architecture)
```text
lib/
 ┣ core/
 ┃ ┣ database/           # SQLite initialization and SQL schema migrations
 ┃ ┣ utils/              # Calculation utilities (Hourglass logic), Constants
 ┃ ┗ theme/              # Inherited from Google Stitch exports
 ┣ data/                 
 ┃ ┣ models/             # Data structure classes (TimeLog, DailyReport, etc.)
 ┃ ┗ repositories/       # DB abstraction layer (Riverpod providers attached here)
 ┣ services/             # Third-party Integrations
 ┃ ┣ location_service.dart
 ┃ ┣ camera_service.dart
 ┃ ┣ pdf_service.dart
 ┃ ┗ ai_report_service.dart
 ┗ ui/                   # Imported Google Stitch UI
   ┣ timeclock/
   ┣ hourglass/
   ┣ yap_journal/
   ┗ settings/
```

### 5. Implementation Roadmap

- **Phase 1: Bedrock Foundation**
  - Initialize the Flutter project and configure `.env` variables if needed.
  - Setup Riverpod state management root.
  - Create the Local SQLite Database layer and schema migrations for tables.
- **Phase 2: Clock & Verify (The Core Engine)**
  - Integrate device permissions (Camera, GPS, File Storage).
  - Build Timeclock logic, photo saving to filesystem, and "Hourglass" calculations.
- **Phase 3: The Bureaucratic Automator**
  - Implement standard CRUD locally for the Yap-to-Report daily journal.
  - Construct the visually strict PDF grid layout for CSC Form 48.
- **Phase 4: UI Synthesis & Polish**
  - Attach the provided Google Stitch UI widgets directly to Riverpod controllers.
  - Write unit test coverage for `calculateAccumulatedHours` and `calculateLateDeductions` (critical algorithms).
  - Setup local SQLite backup exporter for safety.
