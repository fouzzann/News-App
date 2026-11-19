import 'package:flutter/foundation.dart';
import '../core/errors/exceptions.dart';
import '../data/models/article_model.dart';
import '../data/repositories/news_repository.dart';

/// ViewModel managing state for a single article detail
class ArticleDetailViewModel extends ChangeNotifier {
  final NewsRepository _newsRepository;
  Article _article;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isBookmarked = false;

  ArticleDetailViewModel({
    required NewsRepository repository,
    required Article initialArticle,
  })  : _newsRepository = repository,
        _article = initialArticle;

  Article get article => _article;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isBookmarked => _isBookmarked;

  void toggleBookmark() {
    _isBookmarked = !_isBookmarked;
    notifyListeners();
  }

  /// Fetches latest article detail by ID
  Future<void> refreshDetails() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedArticle = await _newsRepository.getArticleDetails(_article.id);
      _article = updatedArticle;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Could not refresh article details.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
