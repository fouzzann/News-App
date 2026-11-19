import 'package:flutter_test/flutter_test.dart';
import 'package:simple_news_app/data/models/article_model.dart';
import 'package:simple_news_app/data/models/article_response_model.dart';
import 'package:simple_news_app/data/models/author_model.dart';

void main() {
  group('Article & Author Models Test', () {
    test('Author.fromJson parses accurately with valid data', () {
      final json = {
        'name': 'John Doe',
        'socials': {'twitter': '@johndoe'},
      };

      final author = Author.fromJson(json);
      expect(author.name, 'John Doe');
      expect(author.socials?['twitter'], '@johndoe');
    });

    test('Author.fromJson falls back gracefully when name is null', () {
      final json = <String, dynamic>{};
      final author = Author.fromJson(json);
      expect(author.name, 'Unknown Author');
    });

    test('Article.fromJson parses complete article JSON correctly', () {
      final json = {
        'id': 101,
        'title': 'James Webb Space Telescope Discovers New Exoplanet',
        'authors': [
          {'name': 'Dr. Jane Smith'}
        ],
        'url': 'https://example.com/article/101',
        'image_url': 'https://example.com/image.jpg',
        'news_site': 'NASA',
        'summary': 'A groundbreaking observation revealing atmospheric composition.',
        'published_at': '2026-05-20T10:30:00Z',
        'updated_at': '2026-05-20T12:00:00Z',
        'featured': true,
      };

      final article = Article.fromJson(json);

      expect(article.id, 101);
      expect(article.title, 'James Webb Space Telescope Discovers New Exoplanet');
      expect(article.authors.length, 1);
      expect(article.primaryAuthor, 'Dr. Jane Smith');
      expect(article.authorInitials, 'DJ');
      expect(article.hasValidImage, true);
      expect(article.newsSite, 'NASA');
      expect(article.featured, true);
      expect(article.publishedAt?.year, 2026);
    });

    test('Article.fromJson handles null or missing fields safely', () {
      final json = {
        'id': 102,
      };

      final article = Article.fromJson(json);

      expect(article.id, 102);
      expect(article.title, 'Untitled Article');
      expect(article.authors, isEmpty);
      expect(article.primaryAuthor, 'Space News');
      expect(article.authorInitials, 'SN');
      expect(article.hasValidImage, false);
      expect(article.summary, 'No summary available.');
      expect(article.publishedAt, isNull);
    });

    test('ArticleResponse.fromJson parses pagination correctly', () {
      final json = {
        'count': 120,
        'next': 'https://api.spaceflightnewsapi.net/v4/articles/?limit=10&offset=10',
        'previous': null,
        'results': [
          {
            'id': 1,
            'title': 'Test Article 1',
            'url': 'https://example.com/1',
            'news_site': 'SpaceNews',
            'summary': 'Summary 1',
          },
          {
            'id': 2,
            'title': 'Test Article 2',
            'url': 'https://example.com/2',
            'news_site': 'NASA',
            'summary': 'Summary 2',
          }
        ],
      };

      final response = ArticleResponse.fromJson(json);

      expect(response.count, 120);
      expect(response.hasNextPage, true);
      expect(response.results.length, 2);
      expect(response.results.first.id, 1);
      expect(response.results.last.id, 2);
    });
  });
}
