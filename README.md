# News App (Flutter)

A modern, production-grade Flutter news application developed for the Flutter Developer assignment at **Mallow Technologies**.

The application connects to the live **Spaceflight News API (v4)**, mirrors the provided mobile UI design mockups, strictly adheres to the **MVVM (Model-View-ViewModel)** architectural pattern, and delivers a responsive experience across Android, iOS, tablets, and iPads.

---

## Highlights & Badges

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Architecture](https://img.shields.io/badge/Architecture-MVVM-orange)
![State Management](https://img.shields.io/badge/State%20Management-Provider-blue)
![Theme](https://img.shields.io/badge/Theme-Light%20(Default)%20%7C%20Pure%20Black%20AMOLED-black)
![Tests](https://img.shields.io/badge/Tests-26%20Passed%20(100%25)-brightgreen)
![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Tablet-blueviolet)

---

## Table of Contents
1. [Core Features](#core-features)
2. [Architecture Overview (MVVM)](#architecture-overview-mvvm)
3. [State Management Justification](#state-management-justification)
4. [Pagination Implementation](#pagination-implementation)
5. [Network Resilience & Cloudflare Image Bypass](#network-resilience--cloudflare-image-bypass)
6. [Theming: Default Light & Pure Black AMOLED](#theming-default-light--pure-black-amoled)
7. [Project Structure](#project-structure)
8. [Setup & Running Instructions](#setup--running-instructions)
9. [Automated Testing](#automated-testing)
10. [Production Scenarios Handled](#production-scenarios-handled)

---

## Core Features

### 1. Animated Splash Screen
* **Branded Entrance:** Features the application icon (`asset/App Icon .png`) in an elevated squircle card with smooth scale (`Curves.easeOutBack`) and fade animations.
* **Background Pre-fetch:** Proactively loads page 1 articles in the background while the splash animation plays, ensuring zero waiting time when transitioning into the Discover feed.
* **Smooth Fade Route:** Transitions seamlessly into the main screen without abrupt flashes.

### 2. Discover & Feed Screen
* **Initial Page Load:** Loads 15 articles on the first request (`limit=15`, `offset=0`).
* **Infinite Scroll Pagination:** A `ScrollController` detects when the user is within 250px of the bottom and fetches the next batch automatically.
* **Pull-to-Refresh:** Refreshes feed data using standard swipe-down gestures while preserving the existing list during loading.
* **Real-time Debounced Search:** 400ms debouncer prevents excessive API spam while typing queries.
* **News Site / Category Filter Pills:** Filter news by publishers (NASA, SpaceNews, European Spaceflight, Teslarati, SpacePolicyOnline, Arstechnica, NASASpaceflight).
* **Publisher Brand Marks:** Authentic brand marks (e.g., CNN red pill, NASA insignia, NSF badge, SpaceNews brand mark) with dynamic favicon fallback.
* **Responsive Layout:** Automatically switches from a single-column list on mobile to an adaptive multi-column grid on tablets and iPads.

### 3. Article Detail View with Horizontal Swipe Navigation
* **Gmail-Style Horizontal Paging:** Swipe left/right between articles seamlessly using Flutter's `PageView.builder`.
* **Proactive Prefetching:** Automatically triggers background pagination when the user swipes within 2 articles of the loaded list end.
* **Hero Image Transitions:** Smooth shared element transitions from the card thumbnail to the full header hero image.
* **Top Bar Actions:**
  * Circular Back button.
  * Bookmark toggle.
  * **3-Dot Horizontal Action Menu (`Icons.more_horiz_rounded`):** Opens a modal bottom sheet with quick actions: Copy Link (with Clipboard integration), Open in Browser, and Article Details.
* **Read Full Article:** Launches original article URL in the user's browser with multi-mode fallback (`externalApplication` -> `platformDefault` -> `inAppBrowserView`) and Android 11+ package visibility queries.

---

## Architecture Overview (MVVM)

The project strictly follows the **MVVM (Model-View-ViewModel)** architectural pattern with clean layer boundaries:

```
┌────────────────────────────────────────────────────────┐
│                      VIEW LAYER                        │
│   DiscoverScreen, ArticleDetailView, SplashScreen      │
│   Widgets: ArticleCard, AppNetworkImage, etc.          │
└──────────────────────────▲─────────────────────────────┘
                           │ (Watches state & dispatches actions)
┌──────────────────────────┴─────────────────────────────┐
│                   VIEWMODEL LAYER                      │
│   NewsListViewModel, ThemeViewModel                    │
│   (ChangeNotifier - State, Pagination, Debouncing)    │
└──────────────────────────▲─────────────────────────────┘
                           │ (Calls repository interfaces)
┌──────────────────────────┴─────────────────────────────┐
│                   REPOSITORY LAYER                     │
│   NewsRepository (Interface)                           │
│   NewsRepositoryImpl (Dio Client + Error Mapper)       │
└──────────────────────────▲─────────────────────────────┘
                           │ (Parses raw JSON to Models)
┌──────────────────────────┴─────────────────────────────┐
│                      DATA LAYER                        │
│   Article, ArticleResponse, Author                     │
│   ApiClient (Dio), ApiConstants, AppException          │
└────────────────────────────────────────────────────────┘
```

### Layer Separation Responsibilities:
1. **Views (UI):** Stateless and lightweight Stateful widgets responsible only for rendering UI and delegating user interactions to ViewModels. Zero business logic or HTTP calls.
2. **ViewModels (Business Logic & State):** Extends `ChangeNotifier`. Manages UI states (`initial`, `loading`, `loaded`, `empty`, `error`), offset-based pagination, search debouncing, and list deduplication.
3. **Repository Layer:** Abstract contract (`NewsRepository`) and implementation (`NewsRepositoryImpl`). Decouples network client details from the ViewModel layer, enabling effortless mock testing.
4. **Core & Data:** Typed network models with null-safe JSON deserializers, Dio interceptors, and a custom `AppException` hierarchy.

---

## State Management Justification

**Provider (`provider: ^6.1.2`)** was selected as the state management solution for this application:

* **Official Recommendation:** Recommended by the Google Flutter team for production apps of this scope.
* **Granular Rebuilds:** Using `Consumer` and `context.select()`, only the specific widgets that depend on altered state rebuild (e.g., pagination spinner or theme icon), leaving the rest of the widget tree untouched.
* **Clean Inversion of Control:** Repositories and ViewModels are injected down the widget tree using `MultiProvider`, making dependencies easily swappable with mocks in unit tests.
* **No Boilerplate Overhead:** Unlike BloC or Redux, Provider does not require event/state classes for every small user interaction, resulting in clean, readable, and maintainable code.

---

## Pagination Implementation

Pagination is implemented using offset-limit pagination matching the Spaceflight News API v4:

1. **Page 1 (Initial Load):**
   * Endpoint: `https://api.spaceflightnewsapi.net/v4/articles/?limit=15&offset=0`
   * Loads the first 15 articles along with `count` (total available items) and `next` URL.
2. **Infinite Scroll Trigger:**
   * A `ScrollController` in `DiscoverScreen` listens to the user's scroll position.
   * When `maxScroll - currentScroll <= 250`, `loadMoreArticles()` is triggered.
3. **Concurrency & Race Condition Locks:**
   * The `_isLoadingMore` flag prevents concurrent network requests.
   * `_hasMorePages` halts further requests once the API indicates `next == null`.
4. **Duplicate Protection:**
   * Incoming items are filtered against existing IDs using a Set (`existingIds`) to prevent duplicate items from appearing in the feed.
5. **Horizontal Pager Prefetching:**
   * In `ArticleDetailPagerScreen`, swiping near the end of the loaded list (`currentIndex >= articles.length - 2`) triggers background pagination so the user never encounters a navigation block.

---

## Network Resilience & Cloudflare Image Bypass

### The Problem:
Publishers such as **NASASpaceFlight** (`nasaspaceflight.com`) and **SpaceflightNow** (`spaceflightnow.com`) host their images behind aggressive **Cloudflare Bot Fight Mode / Anti-Hotlink Protection**. When mobile apps request images directly from their media directories, Cloudflare rejects the connection with **`HTTP 403 Forbidden`**.

### The Solution in `AppNetworkImage`:
* **Direct Bypass via High-Speed CDN:** Known Cloudflare-protected hosts are routed through `wsrv.nl` (an open-source global image CDN cache), returning `HTTP 200 OK` and serving the image immediately.
* **In-Flight Dynamic Fallback:** If any direct image request returns an HTTP error, the widget's `errorBuilder` automatically retries through the proxy CDN before showing the fallback icon.
* **Browser Request Headers:** Injects standard browser `User-Agent` and `Accept` headers into image requests.
* **Shimmer Animation:** Animated skeleton placeholders provide smooth visual feedback while images download.

---

## Theming: Default Light & Pure Black AMOLED

* **Default Theme:** **Light Mode** as requested, featuring clean backgrounds (`#F8F9FA`), crisp white cards, and vibrant primary blue accents (`#0062FF`).
* **Pure Black AMOLED Dark Mode:** Built with a true pure black background (`#000000`) and elevated dark surfaces (`#121212`), eliminating battery drain on OLED screens and eliminating dark-blue tinting.
* **One-Tap Switcher:** Located in the top app bar for instant, smooth theme toggling.

---

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart      # Base URLs, endpoints, timeouts, categories
│   │   └── app_colors.dart         # Light & Pure Black Dark palettes
│   ├── errors/
│   │   └── exceptions.dart         # Typed AppException hierarchy
│   ├── network/
│   │   └── api_client.dart         # Dio HTTP client configuration
│   ├── theme/
│   │   └── app_theme.dart          # Light and AMOLED Dark ThemeData
│   └── utils/
│       ├── date_formatter.dart     # Relative and absolute date formatting
│       ├── debouncer.dart          # Search debouncing utility
│       └── url_launcher_helper.dart# Multi-mode browser launch helper
├── data/
│   ├── models/
│   │   ├── article_model.dart      # Article entity with null-safety
│   │   ├── article_response_model.dart # Paginated response wrapper
│   │   └── author_model.dart       # Author entity
│   └── repositories/
│       ├── news_repository.dart    # Abstract repository interface
│       └── news_repository_impl.dart # Concrete repository with Dio
├── viewmodels/
│   ├── news_list_viewmodel.dart    # Feed state, search, filter, pagination
│   ├── article_detail_viewmodel.dart # Article detail and sharing state
│   └── theme_viewmodel.dart        # Theme mode persistence & toggle
├── views/
│   ├── screens/
│   │   ├── splash_screen.dart      # Animated branded splash screen
│   │   ├── discover_screen.dart    # Main feed with search & filters
│   │   ├── article_detail_view.dart# Article detail content with 3-dot menu
│   │   └── article_detail_pager_screen.dart # Horizontal swipe pager
│   └── widgets/
│       ├── app_network_image.dart  # CDN-resilient image loader with shimmer
│       ├── article_card.dart       # List and Grid article cards
│       ├── category_pills.dart     # Horizontal category filter list
│       ├── empty_state_view.dart   # No search results / empty state
│       ├── error_state_view.dart   # Network error view with retry button
│       ├── pagination_footer.dart  # Bottom pagination loading spinner
│       ├── publisher_logo.dart     # Publisher brand badge (CNN, NASA, etc.)
│       ├── responsive_layout.dart  # Phone vs. Tablet layout builder
│       └── search_input_bar.dart   # Search field with clear button
└── main.dart                       # App entry point & MultiProvider setup
```

---

## Setup & Running Instructions

### Prerequisites:
* Flutter SDK (3.x or higher)
* Dart SDK (3.x or higher)
* Android Studio / Xcode / VS Code with Flutter extension
* An active Android Emulator, iOS Simulator, or connected physical device

### Installation & Execution:
1. **Clone the repository:**
   ```bash
   git clone <repository_url>
   cd simple_news_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run static analysis:**
   ```bash
   dart analyze lib test
   ```

4. **Run the automated test suite:**
   ```bash
   flutter test
   ```

5. **Launch the application:**
   ```bash
   flutter run
   ```

---

## Automated Testing

The project includes an automated test suite with **26 comprehensive tests** across unit, repository, viewmodel, and widget layers:

```bash
$ flutter test

00:01 +26: All tests passed!
```

### Test Coverage Breakdown:
| Test File | Layer | Description |
|:---|:---|:---|
| `article_model_test.dart` | Unit (Models) | JSON deserialization, null fallbacks, pagination parsing |
| `news_list_viewmodel_test.dart` | Unit (ViewModels) | Initial state, loading, loaded, empty, error, pagination, deduplication, search clear, category selection |
| `news_repository_test.dart` | Unit (Repository) | Successful API responses, query parameter encoding, typed `AppException` mapping |
| `publisher_logo_test.dart` | Unit (Widgets) | Brand mark rendering for CNN, NASA, NSF, SpaceNews, Teslarati |
| `theme_viewmodel_test.dart` | Unit (ViewModels) | Default light mode, toggling to pure black dark mode |
| `widget_test.dart` | Widget | `SplashScreen` animations & branding, `ArticleCard` content rendering, `ErrorStateView` retry callback, `EmptyStateView` action callback |

---

## Production Scenarios Handled

* **Offline & Connectivity Loss:** Displays an inline `ErrorStateView` with a single-tap **Try Again** button that preserves previous queries and category filters.
* **Cloudflare WAF / 403 Forbidden on Media:** Bypasses hotlink blocks on publisher media servers via `wsrv.nl` CDN proxying.
* **Android 11+ Package Visibility (`<queries>`):** Declares web intent filters in `AndroidManifest.xml` so external URLs launch properly across all Android versions.
* **URL Launch Fallback Strategy:** Attempts `LaunchMode.externalApplication`, falls back to `LaunchMode.platformDefault`, and finally `LaunchMode.inAppBrowserView` before prompting the user.
* **Debounced Search:** Avoids network request storms by debouncing keyboard input by 400ms.
* **Memory Management:** All `ScrollController`, `TextEditingController`, and `AnimationController` instances are cleanly disposed in their respective state objects.
* **Screen Adaptability:** Fluid typography, flexible slivers, and adaptive grid sizing prevent layout overflows (`RenderFlex` overflow) on devices of all aspect ratios.

---

## Author & Evaluation Notes
* **Project Name:** News App
* **Evaluation Target:** Flutter Developer Assignment — Mallow Technologies
* **Status:** Complete, tested, and production-ready.
