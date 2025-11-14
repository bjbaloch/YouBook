# YouBook Project Structure

This document describes the new professional structure of the YouBook project.

## Overview

The project is now structured with clear separation between frontend (Flutter) and backend (Python FastAPI), following microservices architecture principles.

## Directory Structure

```
final_year_project/
│
├── frontend/                    # Flutter Application
│   ├── lib/
│   │   ├── core/                # Core app configuration
│   │   │   ├── config/          # App configuration
│   │   │   └── theme/           # Theme and colors
│   │   │
│   │   ├── features/            # Feature modules (UI/logic/data separation)
│   │   │   ├── login/
│   │   │   │   ├── data/        # Data sources
│   │   │   │   ├── logic/       # Business logic
│   │   │   │   └── ui/          # User interface
│   │   │   ├── signup/
│   │   │   ├── welcome/
│   │   │   ├── manager_home/
│   │   │   ├── customer_home/
│   │   │   ├── profile/
│   │   │   ├── booking/
│   │   │   ├── notification/
│   │   │   ├── wallet/
│   │   │   └── support/
│   │   │
│   │   └── shared/              # Shared utilities
│   │       ├── api/             # API client
│   │       ├── models/          # Shared data models
│   │       ├── utils/           # Utility functions
│   │       └── widgets/         # Reusable widgets
│   │
│   ├── assets/                  # App assets
│   ├── android/                 # Android platform code
│   ├── ios/                     # iOS platform code
│   ├── web/                     # Web platform code
│   └── pubspec.yaml             # Flutter dependencies
│
└── backend/                     # Python FastAPI Backend
    ├── services/                # Microservices
    │   ├── auth_service/        # Authentication service
    │   ├── profile_service/     # Profile management service
    │   ├── booking_service/     # Booking service
    │   └── notification_service/ # Notification service
    │
    ├── shared/                  # Shared utilities
    │   ├── models.py            # Shared data models
    │   └── auth.py              # Authentication utilities
    │
    ├── config/                  # Configuration
    │   └── database.py          # Database configuration
    │
    ├── main.py                  # API Gateway
    ├── requirements.txt         # Python dependencies
    └── README.md                # Backend documentation
```

## Architecture Principles

### Frontend (Flutter)

Each feature follows a **three-layer architecture**:

1. **Data Layer** (`data/`)
   - Handles all data operations
   - Connects to APIs (Supabase or Python backend)
   - No business logic

2. **Logic Layer** (`logic/`)
   - Contains business logic
   - Validates data
   - Orchestrates data operations
   - No UI code

3. **UI Layer** (`ui/`)
   - Contains only UI widgets
   - Uses logic layer for operations
   - Handles user interactions
   - Preserves all styling

### Backend (Python FastAPI)

Follows **microservices architecture**:

- Each service is independent
- Can be deployed separately
- Uses shared models and utilities
- RESTful API design

## Completed Refactoring

✅ **Login Feature**
- Data: `lib/features/login/data/login_data_source.dart`
- Logic: `lib/features/login/logic/login_logic.dart`
- UI: `lib/features/login/ui/login_page.dart`

✅ **Theme and Colors**
- Moved to: `lib/core/theme/app_colors.dart`

✅ **API Client**
- Created: `lib/shared/api/api_client.dart`

✅ **Backend Structure**
- API Gateway: `backend/main.py`
- Auth Service: `backend/services/auth_service/`
- Profile Service: `backend/services/profile_service/`
- Booking Service: `backend/services/booking_service/`
- Notification Service: `backend/services/notification_service/`

## Remaining Work

### Frontend Features to Refactor
- [ ] Signup
- [ ] Welcome
- [ ] Manager Home
- [ ] Customer Home
- [ ] Profile (all sub-features)
- [ ] Booking (all sub-features)
- [ ] Notification
- [ ] Wallet
- [ ] Support (all pages)

### Backend Implementation
- [ ] Connect to actual database
- [ ] Implement authentication logic
- [ ] Implement profile management
- [ ] Implement booking management
- [ ] Implement notification system

## Migration Strategy

1. **Gradual Migration**: Features can be migrated one at a time
2. **Backward Compatibility**: Old files remain until fully migrated
3. **No Breaking Changes**: UI styles and functionality remain unchanged
4. **Testing**: Each feature should be tested after refactoring

## Next Steps

1. Add `http` package to `pubspec.yaml` (already done)
2. Run `flutter pub get`
3. Continue refactoring features following the Login example
4. Update main.dart imports
5. Implement backend services
6. Connect frontend to backend APIs

## Notes

- **UI Styles**: All styling remains exactly the same - no visual changes
- **Functionality**: All features work exactly as before
- **Flexibility**: Can use Supabase or Python backend (or both)

