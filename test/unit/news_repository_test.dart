import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:simple_news_app/core/constants/api_constants.dart';
import 'package:simple_news_app/core/errors/exceptions.dart';
import 'package:simple_news_app/core/network/api_client.dart';
import 'package:simple_news_app/data/repositories/news_repository_impl.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late NewsRepositoryImpl repository;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = NewsRepositoryImpl(apiClient: mockApiClient);
  });

  group('NewsRepositoryImpl Tests', () {
    final mockJsonResponse = {
      'count': 1,
      'next': null,
      'previous': null,
      'results': [
        {
          'id': 1,
          'title': 'Artemis II Prepares for Launch',
          'url': 'https://example.com/artemis',
          'news_site': 'NASA',
          'summary': 'Astronauts ready for lunar flyby.',
          'published_at': '2026-05-15T12:00:00Z',
        }
      ],
    };

    test('getArticles returns ArticleResponse on successful API call', () async {
      when(
        () => mockApiClient.get(
          ApiConstants.articlesEndpoint,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => mockJsonResponse);

      final result = await repository.getArticles(limit: 10, offset: 0);

      expect(result.count, 1);
      expect(result.results.length, 1);
      expect(result.results.first.title, 'Artemis II Prepares for Launch');
      expect(result.results.first.newsSite, 'NASA');
      verify(
        () => mockApiClient.get(
          ApiConstants.articlesEndpoint,
          queryParameters: {'limit': 10, 'offset': 0},
        ),
      ).called(1);
    });

    test('getArticles includes search and category filters when specified', () async {
      when(
        () => mockApiClient.get(
          ApiConstants.articlesEndpoint,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => mockJsonResponse);

      await repository.getArticles(
        limit: 15,
        offset: 0,
        search: 'Mars',
        newsSite: 'SpaceNews',
      );

      verify(
        () => mockApiClient.get(
          ApiConstants.articlesEndpoint,
          queryParameters: {
            'limit': 15,
            'offset': 0,
            'search': 'Mars',
            'news_site': 'SpaceNews',
          },
        ),
      ).called(1);
    });

    test('getArticles rethrows typed AppException when network failure occurs', () async {
      when(
        () => mockApiClient.get(
          ApiConstants.articlesEndpoint,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(const NetworkException());

      expect(
        () => repository.getArticles(),
        throwsA(isA<NetworkException>()),
      );
    });

    test('getArticleDetails returns Article on successful API call', () async {
      final articleJson = {
        'id': 42,
        'title': 'Hubble Captures Distant Galaxy',
        'url': 'https://example.com/hubble',
        'news_site': 'NASA',
        'summary': 'Spectacular new view.',
      };

      when(
        () => mockApiClient.get('${ApiConstants.articlesEndpoint}42/'),
      ).thenAnswer((_) async => articleJson);

      final result = await repository.getArticleDetails(42);

      expect(result.id, 42);
      expect(result.title, 'Hubble Captures Distant Galaxy');
    });
  });
}
