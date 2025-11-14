# Refactoring Guide

This document explains the new project structure and how to refactor existing features.

## New Project Structure

```
final_year_project/
├── frontend/          # Flutter application
│   └── lib/
│       ├── core/      # Core app configuration
│       │   ├── config/
│       │   └── theme/
│       ├── features/  # Feature modules
│       │   └── [feature]/
│       │       ├── data/     # Data sources
│       │       ├── logic/    # Business logic
│       │       └── ui/       # User interface
│       └── shared/    # Shared utilities
│           ├── api/
│           ├── models/
│           ├── utils/
│           └── widgets/
└── backend/           # Python FastAPI services
    ├── services/      # Microservices
    ├── shared/        # Shared utilities
    └── config/        # Configuration
```

## Refactoring Pattern

Each feature should be split into three layers:

### 1. Data Layer (`data/`)
- Handles all data operations
- Connects to APIs (Supabase or Python backend)
- No business logic, only data retrieval/storage

**Example:** `lib/features/login/data/login_data_source.dart`

### 2. Logic Layer (`logic/`)
- Contains business logic
- Validates data
- Orchestrates data operations
- No UI code

**Example:** `lib/features/login/logic/login_logic.dart`

### 3. UI Layer (`ui/`)
- Contains only UI widgets
- Uses logic layer for business operations
- Handles user interactions
- Preserves all styling

**Example:** `lib/features/login/ui/login_page.dart`

## Completed Refactoring

### ✅ Login Feature
- ✅ Data: `lib/features/login/data/login_data_source.dart`
- ✅ Logic: `lib/features/login/logic/login_logic.dart`
- ✅ UI: `lib/features/login/ui/login_page.dart`

## To Do

### Features to Refactor:
1. **Signup** - Follow the same pattern as Login
2. **Welcome** - Simple UI, may not need separate data/logic
3. **ManagerHome** - Split into data/logic/ui
4. **Profile** - Split account, update profile, etc.
5. **Booking** - Split booking and service details
6. **Notification** - Split notification management
7. **Wallet** - Split wallet operations
8. **Support** - Split all support pages

## Steps to Refactor a Feature

1. **Create folder structure:**
   ```
   lib/features/[feature_name]/
   ├── data/
   │   └── [feature]_data_source.dart
   ├── logic/
   │   └── [feature]_logic.dart
   └── ui/
       └── [feature]_page.dart
   ```

2. **Move data operations to data layer:**
   - Extract all API calls
   - Extract database operations
   - Create methods for each data operation

3. **Move business logic to logic layer:**
   - Extract validation logic
   - Extract business rules
   - Create methods that use data layer

4. **Refactor UI to use logic layer:**
   - Keep all UI styling exactly the same
   - Replace direct API calls with logic layer methods
   - Maintain all animations and transitions

5. **Update imports:**
   - Update imports in the new files
   - Update imports in files that use the feature

## Backend Services

The Python backend is structured as microservices:

- **Auth Service** (`/api/auth`): Authentication and authorization
- **Profile Service** (`/api/profile`): User profile management
- **Booking Service** (`/api/booking`): Booking and service management
- **Notification Service** (`/api/notification`): User notifications

Each service can be implemented independently.

## API Client

Use `lib/shared/api/api_client.dart` to connect to Python backend:

```dart
final apiClient = ApiClient();
final response = await apiClient.post('/auth/login', {
  'email': email,
  'password': password,
});
```

## Important Notes

1. **UI Styles Must Not Change**: All styling, colors, animations must remain exactly the same
2. **Preserve Functionality**: All existing features must work exactly as before
3. **Gradual Migration**: You can migrate features one at a time
4. **Backward Compatibility**: Old files can remain until all features are migrated

## Next Steps

1. Run `flutter pub get` to install `http` package (needed for API client)
2. Update `pubspec.yaml` if needed
3. Continue refactoring features one by one
4. Update main.dart to use new import paths
5. Test each feature after refactoring

