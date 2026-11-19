import '../models/article_model.dart';
import '../models/article_response_model.dart';

/// Contract for fetching news articles from the remote data source
abstract class NewsRepository {
  /// Fetches a paginated list of articles with optional search and category filters
  Future<ArticleResponse> getArticles({
    int limit = 15,
    int offset = 0,
    String? search,
    String? newsSite,
  });

  /// Fetches a single article's full details by its unique identifier
  Future<Article> getArticleDetails(int id);
}
