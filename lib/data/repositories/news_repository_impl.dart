import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../models/article_model.dart';
import '../models/article_response_model.dart';
import 'news_repository.dart';

/// Concrete implementation of [NewsRepository] using [ApiClient]
class NewsRepositoryImpl implements NewsRepository {
  final ApiClient _apiClient;

  NewsRepositoryImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  @override
  Future<ArticleResponse> getArticles({
    int limit = ApiConstants.defaultLimit,
    int offset = 0,
    String? search,
    String? newsSite,
  }) async {
    final queryParameters = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };

    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    if (newsSite != null &&
        newsSite.trim().isNotEmpty &&
        newsSite.trim().toLowerCase() != 'all') {
      queryParameters['news_site'] = newsSite.trim();
    }

    try {
      final responseData = await _apiClient.get(
        ApiConstants.articlesEndpoint,
        queryParameters: queryParameters,
      );

      if (responseData is Map<String, dynamic>) {
        return ArticleResponse.fromJson(responseData);
      } else {
        throw const ParseException(message: 'Malformed response from articles API.');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(message: e.toString());
    }
  }

  @override
  Future<Article> getArticleDetails(int id) async {
    try {
      final responseData = await _apiClient.get(
        '${ApiConstants.articlesEndpoint}$id/',
      );

      if (responseData is Map<String, dynamic>) {
        return Article.fromJson(responseData);
      } else {
        throw const ParseException(message: 'Malformed response for article detail.');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(message: e.toString());
    }
  }
}
