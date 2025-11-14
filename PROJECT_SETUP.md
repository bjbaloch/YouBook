# YouBook Project - Complete Setup Guide

## 🎯 Project Structure

```
final_year_project/
├── frontend/                    # Flutter application
│   ├── lib/
│   │   ├── core/
│   │   │   ├── config/         # Configuration files
│   │   │   │   ├── supabase_config.dart
│   │   │   │   └── api_config.dart
│   │   │   └── theme/          # Theme and colors
│   │   │       └── app_colors.dart
│   │   ├── features/           # Feature modules (UI/Logic/Data)
│   │   │   ├── login/
│   │   │   ├── signup/
│   │   │   ├── welcome/
│   │   │   ├── manager_home/
│   │   │   └── profile/
│   │   ├── shared/             # Shared utilities
│   │   │   ├── api/            # API client
│   │   │   └── utils/          # Utilities
│   │   ├── Login/              # Old login files (keep for backward compatibility)
│   │   ├── Signup/             # Old signup files
│   │   ├── Welcome/            # Old welcome files
│   │   └── main.dart           # Main entry point
│   ├── assets/                 # Images and assets
│   ├── android/                # Android native files
│   ├── ios/                    # iOS native files
│   ├── web/                    # Web files
│   ├── windows/                # Windows native files
│   ├── linux/                  # Linux native files
│   ├── macos/                  # macOS native files
│   └── pubspec.yaml            # Flutter dependencies
│
└── backend/                    # Python FastAPI backend
    ├── services/               # Microservices
    │   ├── auth_service/       # Authentication
    │   ├── profile_service/    # User profiles
    │   ├── booking_service/    # Bookings
    │   └── notification_service/ # Notifications
    ├── shared/                 # Shared backend code
    │   ├── supabase_client.py  # Supabase connection
    │   ├── models.py           # Pydantic models
    │   └── auth.py             # Auth utilities
    ├── config/                 # Configuration
    │   └── database.py         # Database config
    ├── main.py                 # FastAPI app entry point
    └── requirements.txt       # Python dependencies
```

## ✅ Completed Features

### Frontend (Flutter)
- ✅ **Login** - Complete with UI/Logic/Data separation
- ✅ **Signup** - Complete with UI/Logic/Data separation
- ✅ **Welcome** - Complete UI
- ✅ **Manager Home** - Complete with UI/Logic/Data separation
- ✅ **Profile** - Complete with UI/Logic/Data separation
- ✅ **Supabase Integration** - Centralized in `core/config/supabase_config.dart`
- ✅ **API Client** - Ready to connect to Python backend
- ✅ **Theme** - Complete light/dark theme support

### Backend (Python FastAPI)
- ✅ **Auth Service** - Login, Signup, Password Reset
- ✅ **Profile Service** - Get/Update profile
- ✅ **Booking Service** - Get services, Create bookings
- ✅ **Notification Service** - Get/Update/Delete notifications
- ✅ **Supabase Integration** - All services use Supabase

## 🚀 Quick Start

### Frontend Setup

1. **Navigate to frontend directory:**
   ```bash
   cd frontend
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

### Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Create virtual environment:**
   ```bash
   python -m venv venv
   
   # Windows
   venv\Scripts\activate
   
   # Linux/Mac
   source venv/bin/activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the server:**
   ```bash
   python main.py
   ```
   
   Or with uvicorn:
   ```bash
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```

5. **Access API docs:**
   - Swagger UI: http://localhost:8000/docs
   - ReDoc: http://localhost:8000/redoc

## 📡 API Endpoints

### Authentication (`/api/auth`)
- `POST /login` - User login
- `POST /signup` - User registration
- `POST /forgot-password` - Request password reset
- `POST /reset-password` - Reset password
- `GET /check-email/{email}` - Check if email exists
- `GET /check-phone/{phone}` - Check if phone exists
- `GET /check-cnic/{cnic}` - Check if CNIC exists

### Profile (`/api/profile`)
- `GET /{user_id}` - Get user profile
- `PUT /{user_id}` - Update user profile

### Booking (`/api/booking`)
- `GET /services` - Get available services
- `POST /book` - Create booking
- `GET /bookings/{user_id}` - Get user bookings

### Notification (`/api/notification`)
- `GET /{user_id}` - Get user notifications
- `POST /{notification_id}/read` - Mark as read
- `DELETE /{notification_id}` - Delete notification

## 🔧 Configuration

### Supabase Configuration

**Frontend (`frontend/lib/core/config/supabase_config.dart`):**
```dart
static const String supabaseUrl = "https://blycroutezsjhduujaai.supabase.co";
static const String supabaseAnonKey = "your-anon-key";
```

**Backend (`backend/shared/supabase_client.py`):**
```python
SUPABASE_URL = "https://blycroutezsjhduujaai.supabase.co"
SUPABASE_KEY = "your-anon-key"
```

### API Configuration

**Frontend (`frontend/lib/core/config/api_config.dart`):**
```dart
static const String baseUrl = 'http://localhost:8000/api';
```

Change to your backend URL in production:
```dart
static const String baseUrl = 'https://your-api-domain.com/api';
```

## 🔌 Connecting Frontend to Backend

The app uses **Supabase** for authentication and can optionally use the **Python backend** for additional features.

**Current setup:**
- **Authentication**: Uses Supabase directly
- **Additional features**: Can use Python backend API

**To use Python backend:**
- Update `ApiConfig.baseUrl` to your backend URL
- Use `ApiClient` in data sources to call backend APIs
- Backend services are ready and integrated with Supabase

## 📝 Database Schema (Supabase)

### `profiles` table
```sql
- id (uuid, primary key)
- email (text)
- full_name (text)
- phone (text)
- cnic (text)
- role (text)
- avatar_url (text)
- address (text)
- city (text)
- state_province (text)
- country (text)
- created_at (timestamp)
- updated_at (timestamp)
```

### `services` table (for bookings)
```sql
- id (uuid, primary key)
- name (text)
- type (text) -- 'bus' or 'van'
- from_location (text)
- to_location (text)
- price (numeric)
- available_seats (integer)
- departure_time (timestamp)
- arrival_time (timestamp)
- created_at (timestamp)
```

### `bookings` table
```sql
- id (uuid, primary key)
- service_id (uuid, foreign key)
- user_id (uuid, foreign key)
- seat_numbers (integer[])
- passenger_name (text)
- passenger_cnic (text)
- passenger_phone (text)
- total_price (numeric)
- status (text)
- created_at (timestamp)
```

### `notifications` table
```sql
- id (uuid, primary key)
- user_id (uuid, foreign key)
- title (text)
- message (text)
- type (text) -- 'info', 'success', 'warning', 'error'
- read (boolean)
- created_at (timestamp)
```

## 🎨 Architecture

### Frontend Architecture (Flutter)
- **UI Layer**: Widgets and screens
- **Logic Layer**: Business logic and validation
- **Data Layer**: API calls and data sources

### Backend Architecture (Python FastAPI)
- **Microservices**: Separate services for each domain
- **Shared Code**: Common utilities and models
- **Supabase**: Database and authentication backend

## 🔐 Security

- All API endpoints use Supabase authentication
- Passwords are hashed by Supabase
- JWT tokens for API authentication
- CORS configured for Flutter app

## 📚 Next Steps

1. **Test the application:**
   - Run frontend and backend
   - Test login/signup flows
   - Verify API connections

2. **Complete remaining features:**
   - Customer Home
   - Booking UI
   - Notification UI
   - Wallet functionality

3. **Deploy:**
   - Deploy backend to cloud (Heroku, AWS, etc.)
   - Update API config with production URL
   - Deploy Flutter app

## 🎉 Success!

Your project is now properly structured with:
- ✅ Clean frontend/backend separation
- ✅ Professional three-layer architecture
- ✅ Complete backend services
- ✅ Supabase integration
- ✅ Ready for production

All files are organized and connected properly!

