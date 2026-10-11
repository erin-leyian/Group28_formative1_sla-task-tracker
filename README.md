# Project & SLA Task Tracker

A Flutter mobile app that helps a small software team create tasks, assign them, set deadlines and priorities, and track progress. Every task is automatically classified with an SLA status from its deadline and completion state: **On Track**, **At Risk**, **Overdue** or **Completed**.

Group 28, Formative 1 group project.

- Demo video: [add link]
- Contribution tracker: [add link]
- Technical report: [add link or file name]

## Features

- **Sign In / User Selection:** pick who you are from the team list (no real authentication, as the brief allows)
- **Dashboard:** overall progress, a count per SLA status, and a "needs attention" list (Overdue first, then At Risk)
- **Task List:** search by title and filter by SLA status
- **Task Details:** mark a task completed or reopen it, edit it, or delete it with a confirmation
- **Create / Edit Task:** one form for both, with validation
- **Team:** each member with their task count, and a list of their tasks
- **Local storage:** tasks are saved on the device and survive closing and reopening the app

## SLA rules

Checked in this order:

1. **Completed:** the task is marked done
2. **Overdue:** not done, and the deadline has passed
3. **At Risk:** not done, and the deadline is within 48 hours, or the task is High priority and due within 72 hours
4. **On Track:** everything else

The rule is one function, `computeSlaStatus` in `lib/services/sla_service.dart`. It takes an optional `now` value so it can be tested with fixed dates. The date picker sets deadlines to 23:59, so a task due today is not overdue the moment it is saved.

## Validation rules (task form)

- Title: required, at least 3 characters
- Assignee: required (dropdown of team members)
- Deadline: required, and cannot be in the past for a new task
- Saving is wrapped in `try`/`catch` and reports success or failure in a snackbar

## Tech decisions

| Area | Choice | Why |
|---|---|---|
| Framework | Flutter / Dart, Material 3 | Required by the brief |
| State | `setState` | Required by the brief; each screen loads data in `initState` and redraws with `setState` |
| Storage | `shared_preferences` (tasks saved as one JSON list) | Small data, no joins or relational queries, filtering done in memory. The trade-off is that the whole list is rewritten on each save |
| Navigation | Named routes in a routes map | One `AppRoutes` class holds every route name, so typos are caught by the editor |
| Styling | One `AppTheme`, shared `AppSpacing`, one `StatusChip` widget | Keeps colours, spacing and status labels consistent on every screen |

## Project structure

```
lib/
  main.dart                  app entry, theme and routes
  routes.dart                route name constants
  models/
    task.dart                Task model with toJson / fromJson
    user.dart                AppUser model with toJson / fromJson
  services/
    db_service.dart          SharedPreferences storage, fixed team members, sample tasks
    sla_service.dart         SLA status calculation
  screens/
    sign_in_screen.dart
    home_screen.dart         bottom navigation (Dashboard, Tasks, Team)
    dashboard_screen.dart
    task_list_screen.dart
    task_details_screen.dart
    task_form_screen.dart
    team_screen.dart
  theme/
    app_theme.dart           colours, component styles, spacing
  widgets/
    status_chip.dart         shared SLA status label
test/
  widget_test.dart           Sign In screen test
  sla_service_test.dart      unit tests for the SLA rules
```

## Run the app

Requirements: the Flutter SDK, and an Android emulator or a physical Android phone. The app is meant to run on a device or emulator, not in a browser.

```
flutter pub get
flutter devices
flutter run -d <device-id>
```

Notes:

- **Windows:** turn on Developer Mode first (`start ms-settings:developers`), otherwise plugins will not build.
- The first Android build is slow and needs a stable internet connection.
- On the first launch the app adds four sample tasks, one in each SLA state, so every status is visible. To reset the data, clear the app's storage in Android settings.

## Tests

```
flutter analyze
flutter test
```

The tests cover the Sign In screen and five SLA cases: a completed task stays Completed after its deadline, an unfinished task past its deadline is Overdue, exactly 48 hours left is At Risk, a High priority task with 60 hours left is At Risk, and a Medium priority task with 60 hours left is On Track.

## Team and branches

We used one branch per feature, pull requests into `main`, and commit messages that start with a type (`feat:`, `fix:`, `test:`, `docs:`, `chore:`).

| Member | Work | Branches |
|---|---|---|
| Erin | Models, storage, SLA logic, theme, routes, Sign In, home navigation, Task List, Task Form, Task Details, Team screen, tests | `erin/data-sla`, `erin/home-shell`, `erin/task-list`, `erin/task-form`, `erin/task-details`, `erin/team-screen`, `erin/sla-tests` |
| Merveille | Dashboard screen | `merveille/form-dashboard` |
| Cherish | No commits at the time of submission | none |
| Cynthia | No commits at the time of submission | none |

See the technical report for the full account of the collaboration, the challenges and how we solved them.

## Known limitations

- Team members are a fixed list in `DbService`. There is no add-member screen.
- Data is stored only on the device, so two phones do not share tasks. There is no backend, as the brief allows.
- The signed-in user is saved, but tasks are not filtered by who is signed in.
- Tasks are stored as one JSON list, which is simple but would not scale to thousands of tasks. `sqflite` would suit that case better.
- A few small helper functions (date formatting, looking up an assignee's name) are repeated across screens, and could move into one shared helper.
