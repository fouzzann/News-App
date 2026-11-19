import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../core/errors/exceptions.dart';
import '../core/utils/debouncer.dart';
import '../data/models/article_model.dart';
import '../data/repositories/news_repository.dart';

enum ViewState {
  initial,
  loading,
  loaded,
  empty,
  error,
}

/// ViewModel for the news list / Discover screen
class NewsListViewModel extends ChangeNotifier {
  final NewsRepository _newsRepository;
  final Debouncer _searchDebouncer;

  NewsListViewModel({
    required NewsRepository repository,
    Debouncer? debouncer,
  })  : _newsRepository = repository,
        _searchDebouncer = debouncer ?? Debouncer(delay: const Duration(milliseconds: 400));

  // State properties
  ViewState _state = ViewState.initial;
  List<Article> _articles = [];
  String? _errorMessage;
  int _totalCount = 0;
  int _offset = 0;
  final int _limit = ApiConstants.defaultLimit;
  bool _hasMorePages = true;

  // Pagination loading & error state
  bool _isLoadingMore = false;
  String? _paginationError;

  // Filters
  String _searchQuery = '';
  String _selectedCategory = 'All';

  // Getters
  ViewState get state => _state;
  List<Article> get articles => List.unmodifiable(_articles);
  String? get errorMessage => _errorMessage;
  int get totalCount => _totalCount;
  bool get hasMorePages => _hasMorePages;
  bool get isLoadingMore => _isLoadingMore;
  String? get paginationError => _paginationError;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  bool get isLoading => _state == ViewState.loading;
  bool get isLoaded => _state == ViewState.loaded;
  bool get isEmpty => _state == ViewState.empty;
  bool get hasError => _state == ViewState.error;

  /// Initial load or full reload with current filters
  Future<void> loadArticles() async {
    _state = ViewState.loading;
    _errorMessage = null;
    _offset = 0;
    _hasMorePages = true;
    _paginationError = null;
    notifyListeners();

    try {
      final response = await _newsRepository.getArticles(
        limit: _limit,
        offset: _offset,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        newsSite: _selectedCategory != 'All' ? _selectedCategory : null,
      );

      _totalCount = response.count;
      _articles = List<Article>.from(response.results);
      _offset = _articles.length;
      _hasMorePages = response.hasNextPage;

      if (_articles.isEmpty) {
        _state = ViewState.empty;
      } else {
        _state = ViewState.loaded;
      }
    } on AppException catch (e) {
      _errorMessage = e.message;
      _state = ViewState.error;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _state = ViewState.error;
    } finally {
      notifyListeners();
    }
  }

  /// Pull-to-refresh without full-screen loading spinner
  Future<void> refreshArticles() async {
    _offset = 0;
    _paginationError = null;

    try {
      final response = await _newsRepository.getArticles(
        limit: _limit,
        offset: 0,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        newsSite: _selectedCategory != 'All' ? _selectedCategory : null,
      );

      _totalCount = response.count;
      _articles = List<Article>.from(response.results);
      _offset = _articles.length;
      _hasMorePages = response.hasNextPage;

      if (_articles.isEmpty) {
        _state = ViewState.empty;
      } else {
        _state = ViewState.loaded;
      }
      _errorMessage = null;
    } on AppException catch (e) {
      // If refresh fails but we already have items, show a subtle error or keep items
      if (_articles.isEmpty) {
        _errorMessage = e.message;
        _state = ViewState.error;
      }
    } catch (_) {
      if (_articles.isEmpty) {
        _errorMessage = 'Failed to refresh articles.';
        _state = ViewState.error;
      }
    } finally {
      notifyListeners();
    }
  }

  /// Loads the next page of articles as the user scrolls
  Future<void> loadMoreArticles() async {
    // Prevent duplicate loads or loading when no more pages or during initial loading
    if (_isLoadingMore || !_hasMorePages || _state == ViewState.loading) {
      return;
    }

    _isLoadingMore = true;
    _paginationError = null;
    notifyListeners();

    try {
      final response = await _newsRepository.getArticles(
        limit: _limit,
        offset: _offset,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        newsSite: _selectedCategory != 'All' ? _selectedCategory : null,
      );

      final newArticles = response.results;
      _totalCount = response.count;
      
      // Deduplicate new articles against existing items
      final existingIds = _articles.map((a) => a.id).toSet();
      final filteredNew = newArticles.where((a) => !existingIds.contains(a.id)).toList();

      _articles = [..._articles, ...filteredNew];
      _offset += newArticles.length;
      _hasMorePages = response.hasNextPage;
    } on AppException catch (e) {
      _paginationError = e.message;
    } catch (_) {
      _paginationError = 'Failed to load more articles. Tap to retry.';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Retries loading the next page when a pagination error occurred
  Future<void> retryPagination() async {
    _paginationError = null;
    await loadMoreArticles();
  }

  /// Updates search query with debouncing
  void onSearchChanged(String query) {
    final trimmed = query.trim();
    if (_searchQuery == trimmed) return;

    _searchQuery = trimmed;
    _searchDebouncer.run(() {
      loadArticles();
    });
  }

  /// Clears the search input and reloads immediately
  void clearSearch() {
    _searchDebouncer.cancel();
    if (_searchQuery.isNotEmpty) {
      _searchQuery = '';
      loadArticles();
    }
  }

  /// Selects a category filter pill and reloads immediately
  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    loadArticles();
  }

  /// Automatically fetch next page if user swipes near the end of loaded list in detail pager
  void fetchNextPageIfNeeded(int currentIndex) {
    if (currentIndex >= _articles.length - 2 && _hasMorePages && !_isLoadingMore) {
      loadMoreArticles();
    }
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    super.dispose();
  }
}
