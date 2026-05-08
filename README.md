# aait_country_explorer
# Country Explorer App - Track A

## 1. Student Information
- **Name:** [Mihretu Tesema]
- **Student ID:** [ATE/1022/15]
- **Section:** [ONE (1)]
- **Track:** Track A (Country Explorer)

## 2. Project Description
This application is a Flutter-based mobile tool that fetches real-time data from the RestCountries API. It allows users to browse all countries, view detailed information (like population, currency, and capital), and search for specific nations. The project follows a clean architecture by separating models, services, and UI screens.

## 3. How to Run the App
- Ensure Flutter is installed: `flutter --version`
- Clone the repository: `git clone [(https://github.com/nebiyutesema/aait_country_explorer.git)]`
- Get dependencies: `flutter pub get`
- Run the app: `flutter run`

## 4. API Endpoints Used
- All Countries: `https://restcountries.com/v3.1/all`
- Search by Name: `https://restcountries.com/v3.1/name/{name}`
- Search by Code: `https://restcountries.com/v3.1/alpha/{code}`

## 5. Technical Implementation
- **Data Handling**: JSON parsing using `fromJson` and `toJson`.
- **Networking**: Using the `http` package with a 10-second timeout.
- **Error States**: Custom handling for No Internet (SocketException) and Timeout.

## 6. Known Limitations
- The search requires an exact match for country names.
- Offline mode is not currently supported (data is not cached).
