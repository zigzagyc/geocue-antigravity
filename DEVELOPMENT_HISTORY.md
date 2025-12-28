# Development History & Agent Prompt Log

This document records the "Vibe Coding" history of the **GeoCue** project. It serves as a log of high-level user requests and the corresponding architectural changes and implementation steps performed by the **Antigravity** AI agent.

Use this log to track how the software evolved from initial infrastructure to a release-ready science fair project.

## How to Contribute
When collaborating on this project from other machines:
1.  **Sync:** Always `git pull` before starting work to get the latest history.
2.  **Log:** New major requests and plan changes should be appended to this file.
3.  **Commit:** Commit this file along with your code changes to maintain a shared history of the "Vibe".

---

## Log Entries

### Dec 28, 2025: Science Fair Submission Prep
**User Vibe (Prompt):** "I will submit this program to a local science fair, can you write an abstract for me? ... highlight the use of antigravity to do AI/Agent/vibe coding as well? ... build a document to show people how this software is being developed?"

**Agent Action (Plan):**
*   **Documentation:** Drafted multiple variations of a Science Fair Abstract (Technical, HCI, Concise, Process-Oriented).
*   **Process Transparency:** Created this `DEVELOPMENT_HISTORY.md` to document the AI-assisted development lifecycle.
*   **Artifacts:** Saved abstracts to `science_fair_abstract.md` and committed documentation to the repository.

### Dec 28, 2025: Git Tagging & Branching
**User Vibe (Prompt):** "Git Tag and Branch"

**Agent Action (Plan):**
*   **Version Control:** Created a specific git tag for the Congressional App Challenge (CAC) submission.
*   **Branch Management:** Established a new development branch to isolate future work from the frozen submission state.

### Dec 27, 2025: Feature Refinement (TTS & Maps)
**User Vibe (Prompt):** "Fix TTS, Map, Logout"

**Agent Action (Plan):**
*   **Audio Logic:** Implemented sequential playback for Text-to-Speech to prevent audio overlap.
*   **State Management:** Updated Map View to persist the user's last known location.
*   **Authentication:** Added a functional Logout capability to the simplified UI.

### Dec 27, 2025: Release Automation (DevOps)
**User Vibe (Prompt):** "Release Build Automation"

**Agent Action (Plan):**
*   **Scripting:** Enhanced `tool/build_all.dart` to support multi-platform build targets (iOS, Android, macOS, Web).
*   **Distribution:** Automated the generation of `dist/` artifacts, including OTA manifests for iOS Ad-Hoc builds.
*   **CI/CD:** Standardized build commands to work consistently across developer machines.

### Dec 27, 2025: Android Maps Debugging
**User Vibe (Prompt):** "Debugging Android Maps and Keystore"

**Agent Action (Plan):**
*   **Configuration:** Fixed `AndroidManifest.xml` and Google Cloud Console settings to resolve Map API authorization failures.
*   **Keystore Management:** Standardized debug keystores across macOS and Windows environments to ensure consistent SHA-1 fingerprints for API access.

### Dec 26, 2025: iOS Lifecycle & Stability
**User Vibe (Prompt):** "Debugging iOS Lifecycle and File Errors"

**Agent Action (Plan):**
*   **Native Debugging:** Investigated and resolved `UIScene` lifecycle warnings in `AppDelegate.swift`.
*   **Resource Management:** Fixed file access errors (`fopen`) related to incorrect resource paths in the iOS bundle.

### Dec 25, 2025: App Store Prep & Security
**User Vibe (Prompt):** "Prepare App Store Deployment" & "Refactoring API Key Storage"

**Agent Action (Plan):**
*   **Security:** Moved hardcoded API keys into git-ignored config files (`local.properties`, `Config.xcconfig`).
*   **Build Config:** Updated Gradle and Xcode schemes to inject keys at build time.
*   **Deployment:** Configured `ExportOptions.plist` for App Store and Ad-Hoc distribution flavors.

### Dec 25, 2025: Core Integrations (Maps & Firebase)
**User Vibe (Prompt):** "Debugging Maps and Firebase"

**Agent Action (Plan):**
*   **Backend Setup:** Verified and fixed `google-services.json` and `GoogleService-Info.plist` placement.
*   **Initialization:** Corrected Firebase initialization logic in `main.dart` to support async startup.
*   **Platform Specifics:** Resolved iOS-specific crashers related to Firebase dependencies.

### Dec 24, 2025: Cross-Platform Build System
**User Vibe (Prompt):** "Building Cross-Platform Artifacts"

**Agent Action (Plan):**
*   **Infrastructure:** Created the initial `tool/build_all.dart` script.
*   **Portability:** Ensured the build system could run on both macOS (for iOS/Mac builds) and Windows functionality (via Dart's cross-platform libraries).

---
*End of Log. Last Updated: Dec 28, 2025.*
