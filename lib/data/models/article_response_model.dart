import 'article_model.dart';

/// Paginated API response model for articles endpoint
class ArticleResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<Article> results;

  const ArticleResponse({
    required this.count,
    this.next,
    this.previous,
    this.results = const [],
  });

  bool get hasNextPage => next != null && next!.trim().isNotEmpty;

  factory ArticleResponse.fromJson(Map<String, dynamic> json) {
    List<Article> parsedResults = [];
    if (json['results'] is List) {
      parsedResults = (json['results'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => Article.fromJson(item))
          .toList();
    }

    return ArticleResponse(
      count: json['count'] as int? ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: parsedResults,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((article) => article.toJson()).toList(),
    };
  }
}
