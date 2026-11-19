# Simple News App (Flutter)

A modern, responsive, production-ready Flutter news application developed for the Flutter Developer evaluation at **Mallow Technologies**.

The application connects to the **Spaceflight News API (v4)**, matches the provided UI design reference, follows the **MVVM (Model-View-ViewModel)** architectural pattern, and is fully responsive across Android, iOS, tablets, and iPads.

---

## Table of Contents
1. [Screenshots & UI Design](#screenshots--ui-design)
2. [Task Overview & Features](#task-overview--features)
3. [Architecture Overview (MVVM)](#architecture-overview-mvvm)
4. [State Management Justification](#state-management-justification)
5. [Production Scenarios Handled](#production-scenarios-handled)
6. [Folder Structure](#folder-structure)
7. [Dependencies & Packages](#dependencies--packages)
8. [Setup & Running Instructions](#setup--running-instructions)
9. [Testing](#testing)
10. [Assumptions & Design Adaptations](#assumptions--design-adaptations)

---

## Screenshots & UI Design

The app faithfully implements the attached reference design:
- **Discover (List Screen)**: Features a clean header, debounced search bar, category/news site filter pills, article thumbnail cards with category, title, author avatar with initials, dot separator, and formatted date.
- **Article Detail Screen**: Full hero image with gradient overlay, floating category tag and title, publisher info with verified badge, complete summary, and a prominent **"Read Full Article"** action.
- **Swipe Navigation (Gmail-style)**: Horizontal page swipe allowing seamless browsing from one news article to the next and previous article, with automatic pagination pre-fetching at the end of the loaded feed.
- **Responsive Layout**: Single-column layout on mobile phones; 2-column and 3-column responsive grid layout on tablets and iPads.
- **Theme Modes**: Full support for both **Light Mode** and **Dark Mode**, with a one-tap theme toggle in the header.

---

## Task Overview & Features

### A. List Screen (Discover)
- **Search**: Allows real-time search across article titles and summaries with a 400ms debouncer to prevent excessive API calls.
- **Category Filter Pills**: Filter articles by news site (`All`, `NASA`, `SpaceNews`, `European Spaceflight`, `Teslarati`, `SpacePolicyOnline`, etc.).
- **Infinite Pagination**: Listens to scroll position and automatically fetches the next page when within 250px of the bottom.
- **Pull-to-Refresh**: Native `RefreshIndicator` enabling users to pull down to refresh the article list without layout jumps.
- **Thumbnails & Caching**: Efficient image caching with `cached_network_image`, skeleton shimmer placeholders, and graceful fallback icons.

### B. Detail Screen
- **Rich Presentation**: Displays hero image, title, news site badge, relative publish date ("6 hours ago"), author, and full summary.
- **"Read full article" Button**: Opens the original external article URL in the device's default browser using `url_launcher`.
- **Swipe Navigation (Gmail-Style)**: Powered by `PageView.builder`, users can swipe horizontally left/right to move to the next or previous article in the current feed.
- **Continuous Reading Pagination**: When the user swipes near the end of the loaded list in the detail pager, the next page is fetched proactively so the reading experience is uninterrupted.
- **Interactive Actions**: Integrated bookmark toggle and native OS share dialog (`share_plus`).

---

## Architecture Overview (MVVM)

The project follows a clean **MVVM (Model-View-ViewModel)** architecture:

```
[ View (UI Screens & Widgets) ]
              ▲
              │ Observes state changes (ChangeNotifier / Consumer)
              ▼
[ ViewModel (Business Logic & UI State) ]
              ▲
              │ Calls domain operations
              ▼
[ Repository Layer (Contracts & Implementations) ]
              ▲
              │ Calls typed networking
              ▼
[ ApiClient (Dio with Interceptors & Typed Exceptions) ]
              ▲
              ▼
[ Spaceflight News API v4 ]
```

### Key Architectural Layers:
1. **Core**: Contains app constants (`ApiConstants`, `AppColors`), theme specifications (`AppTheme`), typed network exceptions (`AppException`, `NetworkException`, `RequestTimeoutException`), and reusable utilities (`Debouncer`, `DateFormatter`, `UrlLauncherHelper`).
2. **Data**:
   - **Models**: Immutable, null-safe data classes (`Article`, `ArticleResponse`, `Author`) with robust `fromJson` parsers handling null, empty, or missing fields gracefully.
   - **Repositories**: `NewsRepository` interface and `NewsRepositoryImpl` concrete implementation, isolating networking logic from presentation state.
3. **ViewModels**:
   - `NewsListViewModel`: Manages list loading state, pagination offset/limit, search query debouncing, category selection, and pagination retry.
   - `ThemeViewModel`: Manages system, light, and dark theme states.
   - `ArticleDetailViewModel`: Manages single article detail, bookmark status, and refresh logic.
4. **Views**:
   - `DiscoverScreen`: The main list screen.
   - `ArticleDetailPagerScreen`: The horizontal swipeable Gmail-style pager.
   - `ArticleDetailView`: The single article view.
   - `widgets/`: Reusable, isolated UI components (`ArticleCard`, `SearchInputBar`, `CategoryPills`, `PaginationFooter`, `EmptyStateView`, `ErrorStateView`, `ShimmerArticleCard`, `ResponsiveLayout`).

---

## State Management Justification

**Provider with `ChangeNotifier`** was chosen as the state management solution for this application based on the following engineering merits:

1. **Direct Alignment with MVVM**:
   `ChangeNotifier` naturally maps to the ViewModel role in MVVM. The ViewModel encapsulates mutable UI state and exposes immutable getters, notifying the View only when state actually changes via `notifyListeners()`.
2. **Clean Separation of Concerns**:
   Views remain purely declarative and reactive (`Consumer` and `Selector`). Business logic, API calls, and pagination state reside strictly in ViewModels, decoupled from Flutter's widget tree.
3. **High Testability**:
   `NewsListViewModel` depends on the abstract `NewsRepository` interface, allowing mock repositories (`MockNewsRepository`) to be injected easily in unit tests without touching Flutter UI widgets.
4. **Zero Unnecessary Boilerplate**:
   Unlike Bloc, which requires creating Events, States, and EventHandlers for every minor interaction, Provider offers readable, concise, and maintainable code without sacrificing architectural cleanliness.
5. **Memory Safety & Resource Management**:
   All controllers (`ScrollController`, `TextEditingController`, `PageController`) and timer-based debouncers implement explicit `dispose()` lifecycle overrides to prevent memory leaks.

---

## Production Scenarios Handled

| Scenario | Implementation Details |
| :--- | :--- |
| **Loading State** | Skeleton shimmer placeholders (`ShimmerArticleCard`) matching the exact layout of article cards. |
| **Empty State** | `EmptyStateView` with informative graphics, custom copy, and a "Clear Search" or "Show All" button. |
| **Error State** | `ErrorStateView` with retry button for both initial load and network dropouts. |
| **No Internet Connection** | `NetworkException` caught and mapped to user-friendly messages with a retry action. |
| **Request Timeouts** | Explicit 15-second connect and receive timeouts via Dio, handled by `RequestTimeoutException`. |
| **Pagination Errors** | `PaginationFooter` displays an inline retry banner at the bottom without dismissing already loaded articles. |
| **No Duplicate Loads** | `isLoadingMore` guard prevents concurrent duplicate requests when fast scrolling; deduplication via ID hashing prevents repeat cards. |
| **Missing / Null Fields** | Fallback values for null images (stylized rocket placeholder), empty summaries, and missing authors (falls back to `news_site`). |
| **Dark Mode & Text Scaling** | High-contrast dark theme; typography uses relative scaling compatible with accessibility font settings. |
| **Disposal of Controllers** | All `TextEditingController`, `ScrollController`, `PageController`, and `Debouncer` instances are disposed of cleanly. |

---

## Folder Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart          # Base URL, endpoints, news site categories
│   │   └── app_colors.dart             # Palette for light and dark modes
│   ├── errors/
│   │   └── exceptions.dart             # Typed AppException hierarchy
│   ├── network/
│   │   └── api_client.dart             # Dio wrapper with timeouts and error mapping
│   ├── theme/
│   │   └── app_theme.dart              # Light & Dark ThemeData configurations
│   └── utils/
│       ├── date_formatter.dart         # Standard and relative date formatting
│       ├── debouncer.dart              # Search input debounce utility
│       └── url_launcher_helper.dart    # Safe URL launcher with SnackBar fallback
├── data/
│   ├── models/
│   │   ├── article_model.dart          # Null-safe Article domain model
│   │   ├── article_response_model.dart # Paginated response wrapper
│   │   └── author_model.dart           # Author model
│   └── repositories/
│       ├── news_repository.dart        # Abstract contract
│       └── news_repository_impl.dart   # Implementation using ApiClient
├── viewmodels/
│   ├── article_detail_viewmodel.dart   # Detail screen state & bookmarks
│   ├── news_list_viewmodel.dart        # List state, pagination, filtering, search
│   └── theme_viewmodel.dart            # Light / Dark theme toggling
├── views/
│   ├── screens/
│   │   ├── article_detail_pager_screen.dart # Gmail-style swipe pager
│   │   ├── article_detail_view.dart         # Single article detail view
│   │   └── discover_screen.dart             # Main list/grid screen
│   └── widgets/
│       ├── article_card.dart           # Reusable card (list & grid mode)
│       ├── category_pills.dart         # Horizontal category filter pills
│       ├── empty_state_view.dart       # Reusable empty view with action
│       ├── error_state_view.dart       # Reusable error view with retry
│       ├── pagination_footer.dart      # Loading spinner & retry banner
│       ├── responsive_layout.dart      # Phone vs. Tablet LayoutBuilder helper
│       ├── search_input_bar.dart       # Styled search field with clear/filter
│       └── shimmer_article_card.dart   # Skeleton shimmer placeholder
└── main.dart                           # MultiProvider setup & MaterialApp
```

---

## Dependencies & Packages

- **`provider: ^6.1.2`**: Dependency injection and reactive state management.
- **`dio: ^5.7.0`**: Advanced HTTP client with timeout configuration and error classification.
- **`cached_network_image: ^3.4.1`**: Memory and disk image caching with placeholder/error builder.
- **`url_launcher: ^6.3.1`**: Launches original article URLs in the system browser.
- **`intl: ^0.19.0`**: Date formatting for publication timestamps.
- **`shimmer: ^3.0.0`**: Smooth shimmer effect for loading states.
- **`share_plus: ^10.1.2`**: Native platform sharing functionality.
- **`mocktail: ^1.0.4`**: Null-safe mocking library for unit and widget testing.
- **`flutter_lints: ^6.0.0`**: Official Flutter linting rules.

---

## Setup & Running Instructions

### Prerequisites
- Flutter SDK **^3.12** / **3.44+**
- Dart SDK **^3.12**
- Android Studio / Xcode / Chrome / Windows desktop runtime

### Steps
1. **Clone or extract** the repository:
   ```bash
   cd simple_news_app
   ```
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run code analysis**:
   ```bash
   flutter analyze
   ```
   *(Expected output: No issues found!)*
4. **Run test suite**:
   ```bash
   flutter test
   ```
   *(Expected output: All 19 tests passed!)*
5. **Run the application**:
   - On Android: `flutter run -d android`
   - On iOS: `flutter run -d ios`
   - On Chrome / Web: `flutter run -d chrome`
   - On Windows: `flutter run -d windows`

---

## Testing

The project includes unit and widget tests covering:
- **Model Tests (`test/unit/article_model_test.dart`)**:
  - Full JSON parsing and field verification.
  - Graceful handling of missing or null fields.
  - Pagination parsing (`hasNextPage`, `count`).
- **Repository Tests (`test/unit/news_repository_test.dart`)**:
  - API client query parameter forwarding (`limit`, `offset`, `search`, `news_site`).
  - Handling of network failure exceptions.
  - Detail article lookup by ID.
- **ViewModel Tests (`test/unit/news_list_viewmodel_test.dart`)**:
  - Initial state verification.
  - Transition from `loading` to `loaded`.
  - Empty state when 0 articles match.
  - Error state handling and error messages.
  - Pagination loading with deduplication.
  - Category filter selection and search clearing.
- **Widget Tests (`test/widget_test.dart`)**:
  - `ArticleCard` component rendering.
  - `ErrorStateView` display and retry callback invocation.
  - `EmptyStateView` display and action callback invocation.

Run all tests with:
```bash
flutter test
```

---

## Assumptions & Design Adaptations

1. **Category Pills & Authors**:
   As explicitly highlighted in the task specification note (*"Some data in the UI (categories, author avatars, 'Trending') isn't in the API. Treat the design as a reference and adapt it, for example by using news_site in place of the category or author."*):
   - Category pills represent the available `news_site` publishers from Spaceflight News API (e.g. `NASA`, `SpaceNews`, `European Spaceflight`, etc.).
   - Author name displays the first author in the API response, or defaults to the `news_site` if the author list is omitted.
   - Author avatar renders a colored circular avatar with author initials matching the design.
2. **Swipe Navigation**:
   The detail screen uses a horizontal `PageView.builder` initialized to the tapped article index, enabling users to swipe between news articles like Gmail. When swiping near the boundary of loaded articles, subsequent pages are automatically loaded in the background.
