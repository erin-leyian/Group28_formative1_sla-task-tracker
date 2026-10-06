# Project & SLA Task Tracker

A Flutter mobile app that helps a small software team create tasks, assign them, set deadlines, and track SLA status.

## Features
- Sign in / user selection
- Project dashboard with progress and "needs attention" tasks
- Task list with filter and search
- Task details with status updates
- Create / edit task with validation
- Team members and profiles
- Data saved locally, so it persists after closing the app

## SLA rules
Checked in this order:
1. **Completed**: the task is marked done
2. **Overdue**: not done and the deadline has passed
3. **At Risk**: not done and the deadline is within 48 hours, or High priority and due within 72 hours
4. **On Track**: everything else

## Tech
- Flutter / Dart
- Local storage: SharedPreferences (tasks saved as JSON)
- State management: setState

## Project structure
lib/
  models/     data classes (Task, User)
  services/   storage and SLA logic
  screens/    one file per screen
  widgets/    reusable widgets
  theme/      app colors and styles

## Team and branches
| Member | Branch |
|---|---|
| Erin | erin/data-sla |
| Cynthia | cynthia/team-profile |
| Cherish | cherish/task-list-details |
| Merveille | merveille/form-dashboard |

## Run the app
flutter pub get
flutter run
(Run on an emulator or physical phone.)