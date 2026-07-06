# Komiku App

A comic-reading application built with Flutter (frontend) and PHP + MySQL (backend API), created as a university assignment project.

## Table of Contents

- [Features](#features)
- [Folder Structure](#folder-structure)
- [Database Structure](#database-structure)
- [Project Setup](#project-setup)
- [API Endpoints](#api-endpoints)
- [Session Handling](#session-handling)
- [Development Notes](#development-notes)

---

## Features

| Feature | Weight | Description |
|---|---|---|
| Login Page | 5% | Login using username & password |
| Category Page | 5% | Displays comic categories (Comedy, Action, Horror, etc.) from the database. Categories are fixed and cannot be modified by users. Tapping a category goes to the Comic List Page |
| Comic List Page | 10% | Lists all comics within a selected category. A comic can belong to more than one category. Displays the comic poster and average rating. Tapping a comic goes to the Comic Reader Page |
| Comic Reader Page | 30% | Displays the comic's page images. Users can also leave comments and ratings here |
| Search Comic Page | 10% | Search comics by title. Tapping a search result goes to the Comic Reader Page |
| Create Comic Page | 30% | Lets users create their own comic: title, poster upload, category selection, and page image uploads |

---

## Folder Structure

```
lib/
├── main.dart
├── models/
│   ├── user_model.dart
│   ├── category_model.dart
│   ├── comic_model.dart
│   ├── chapter_model.dart
│   ├── page_model.dart
│   └── comment_model.dart
├── services/
│   └── api_service.dart        # all HTTP calls to the PHP backend
├── utils/
│   └── session_helper.dart     # save/retrieve login session (SharedPreferences)
└── screens/
    ├── login_screen.dart
    ├── category_screen.dart
    ├── comic_list_screen.dart
    ├── comic_reader_screen.dart
    ├── search_screen.dart
    └── comic_upload_screen.dart
```

**Structure principles:**
- `models/` — plain Dart classes representing data, no logic
- `services/` — single place for all API calls (`ApiService.xxx()`)
- `utils/` — non-UI helpers, e.g. session/login state
- `screens/` — one file per full page (kept flat for now, not yet split into subfolders/widgets — only split once UI is genuinely reused across multiple screens)

---

## Database Structure

The database consists of 8 main tables:

| Table | Description |
|---|---|
| `users` | User account data (username, email, password) |
| `categories` | Comic categories, pre-seeded, cannot be modified by users |
| `comics` | Comic data (title, poster, uploader, view count) |
| `comic_category` | Many-to-many relation between comics and categories |
| `chapters` | Chapters belonging to a comic |
| `pages` | Page images belonging to a chapter |
| `ratings` | Ratings (1–5) given by users to a comic; one user can only rate a comic once |
| `comments` | User comments on a comic, supports replies (`parent_comment_id`) |

Full schema is available in `schema.sql`.

---

## Project Setup

### 1. Backend (PHP + MySQL)
1. Import `schema.sql` into a MySQL database (e.g. via phpMyAdmin on ubaya.cloud).
2. Upload the PHP API files (`login.php`, etc.) to your hosting.
3. Make sure the database connection credentials in each PHP file are correct:
   ```php
   $conn = new mysqli("localhost", "db_username", "db_password", "db_name");
   ```

### 2. Frontend (Flutter)
1. Clone/copy this project.
2. Add the following dependencies to `pubspec.yaml`:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     animate_do: ^3.0.2
     http: ^1.1.0
     shared_preferences: ^2.2.2
   ```
3. Run:
   ```bash
   flutter pub get
   flutter run
   ```
4. Update the `baseUrl` in `lib/services/api_service.dart` to match your own backend hosting URL.

---

## API Endpoints

Base URL: `https://ubaya.cloud/flutter/160423007/komiku`

| Endpoint | Method | Body (form-data) | Response |
|---|---|---|---|
| `/login.php` | POST | `username`, `password` | `{ result, user_id, username, email }` or `{ result: "error", message }` |

> Other endpoints (register, categories, comic list, comic reader, comments, ratings, comic upload) have not been built yet — they will be added as features progress.

### Example request for `login.php` (Postman)

- Method: `POST`
- Body → `form-data`:

  | Key | Value |
  |---|---|
  | username | student |
  | password | password123 |

### Example success response
```json
{
  "result": "success",
  "user_id": 1,
  "username": "student",
  "email": "student@gmail.com"
}
```

### Example error response
```json
{
  "result": "error",
  "message": "Incorrect username or password"
}
```

**Security note:** passwords are currently stored and compared in plain text for development/learning purposes. For a production implementation, passwords should be hashed with `password_hash()` at register time and verified with `password_verify()` at login time.

---

## Session Handling

Login state is stored locally using `shared_preferences`, managed through `SessionHelper`:

```dart
await SessionHelper.saveUser(userId, username);   // save after successful login
await SessionHelper.getUser();                    // retrieve saved user data
await SessionHelper.isLoggedIn();                 // check login status
await SessionHelper.logout();                     // clear login data
```

Stored data: `user_id`, `username`.

---

## Development Notes

- State management uses Flutter's built-in `setState()` — no additional library (Provider/BLoC/Riverpod) is used, since the project is small in scale and intended for learning purposes.
- Navigation between screens uses `Navigator.push` / `Navigator.pushReplacement` with `MaterialPageRoute` — `go_router` is not used.
- The folder structure is intentionally kept flat and simple, suited for students/junior programmers, rather than a production/large-team scale.
