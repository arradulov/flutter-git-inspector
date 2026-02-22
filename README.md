# Git Inspector Desktop

A specialized Flutter-based desktop utility designed to monitor and manage local Git repositories with a focus on seamless cross-platform character encoding.

## 🏭 Production-Ready & Real-World Proven
This project is not just a prototype; it is **actively used in a production environment** to streamline version control for **SCADA system configurations**. 

In industrial automation, engineers often work with diverse sets of configuration files where precise tracking is mission-critical. By automating encoding fixes and providing a specialized GUI, this tool has significantly reduced human error and saved numerous technical hours previously spent on manual Git troubleshooting and command-line character recovery.

## The Core Problem
When working with Git on Windows, developers often encounter issues with Cyrillic characters in the console output. By default, Git may escape these characters (e.g., showing `\320\242` instead of `Т`), and the system's default encoding (CP-1251) causes "mojibake" (garbled text) when reading logs.

## Technical Solutions
This application solves these issues through several automated mechanisms:
* **Configuration Injection**: Automatically executes `git config core.quotepath false` to ensure file names remain readable in any language.
* **UTF-8 Stream Handling**: Forces `stdout` and `stderr` streams to use UTF-8 encoding when executing Git processes, preventing character corruption.
* **Process Management**: Uses the `dart:io` `Process` class to bridge the Git CLI and Flutter UI for real-time data accuracy.

## Key Features
* **Folder Intelligence**: Detects valid Git repositories and offers one-click initialization.
* **Encoding Auto-Fix**: A dedicated routine that prepares the repository for reliable multilingual use.
* **Smart Versioning**: Automatically calculates a project version (e.g., `v0.0.X`) based on the total commit count.
* **Commit Interface**: Staging changes and creating commits with full support for Cyrillic descriptions.
* **Live Status**: Real-time tracking of modified, deleted, or untracked files.

## Tech Stack
* **Framework**: Flutter (Desktop for Windows)
* **Language**: Dart
* **Integration**: Git CLI

## Installation
1. Ensure Flutter SDK is installed.
2. Ensure Git is added to your system PATH.
3. Clone the repository and run:
   ```bash
   flutter run