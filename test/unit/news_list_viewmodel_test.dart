import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:simple_news_app/core/errors/exceptions.dart';
import 'package:simple_news_app/data/models/article_model.dart';
import 'package:simple_news_app/data/models/article_response_model.dart';
import 'package:simple_news_app/data/repositories/news_repository.dart';
import 'package:simple_news_app/viewmodels/news_list_viewmodel.dart';

class MockNewsRepository extends Mock implements NewsRepository {}

void main() {
  late MockNewsRepository mockRepository;
  late NewsListViewModel viewModel;

  setUp(() {
    mockRepository = MockNewsRepository();
    viewModel = NewsListViewModel(repository: mockRepository);
  });

  group('NewsListViewModel Tests', () {
    const sampleArticle1 = Article(
      id: 1,
      title: 'First Article',
      url: 'https://example.com/1',
      newsSite: 'NASA',
      summary: 'Summary 1',
    );

    const sampleArticle2 = Article(
      id: 2,
      title: 'Second Article',
      url: 'https://example.com/2',
      newsSite: 'SpaceNews',
      summary: 'Summary 2',
    );

    test('Initial state is ViewState.initial and lists are empty', () {
      expect(viewModel.state, ViewState.initial);
      expect(viewModel.articles, isEmpty);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.selectedCategory, 'All');
      expect(viewModel.searchQuery, isEmpty);
    });

    test('loadArticles sets state to loaded on successful response', () async {
      when(
        () => mockRepository.getArticles(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
          search: any(named: 'search'),
          newsSite: any(named: 'newsSite'),
        ),
      ).thenAnswer(
        (_) async => const ArticleResponse(
          count: 2,
          next: 'https://api.example.com/next',
          results: [sampleArticle1, sampleArticle2],
        ),
      );

      await viewModel.loadArticles();

      expect(viewModel.state, ViewState.loaded);
      expect(viewModel.articles.length, 2);
      expect(viewModel.hasMorePages, true);
      expect(viewModel.errorMessage, isNull);
    });

    test('loadArticles sets state to empty when 0 articles are returned', () async {
      when(
        () => mockRepository.getArticles(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
          search: any(named: 'search'),
          newsSite: any(named: 'newsSite'),
        ),
      ).thenAnswer(
        (_) async => const ArticleResponse(
          count: 0,
          results: [],
        ),
      );

      await viewModel.loadArticles();

      expect(viewModel.state, ViewState.empty);
      expect(viewModel.articles, isEmpty);
    });

    test('loadArticles sets state to error when repository throws exception', () async {
      when(
        () => mockRepository.getArticles(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
          search: any(named: 'search'),
          newsSite: any(named: 'newsSite'),
        ),
      ).thenThrow(const NetworkException(message: 'Connection failed'));

      await viewModel.loadArticles();

      expect(viewModel.state, ViewState.error);
      expect(viewModel.errorMessage, 'Connection failed');
      expect(viewModel.articles, isEmpty);
    });

    test('loadMoreArticles appends new articles and avoids duplicates', () async {
      int callCount = 0;
      when(
        () => mockRepository.getArticles(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
          search: any(named: 'search'),
          newsSite: any(named: 'newsSite'),
        ),
      ).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          return const ArticleResponse(
            count: 3,
            next: 'https://example.com/next',
            results: [sampleArticle1],
          );
        } else {
          return const ArticleResponse(
            count: 3,
            next: null,
            results: [sampleArticle2],
          );
        }
      });

      await viewModel.loadArticles();
      expect(viewModel.articles.length, 1);

      await viewModel.loadMoreArticles();
      expect(viewModel.articles.length, 2);
      expect(viewModel.articles.map((a) => a.id).toList(), [1, 2]);
      expect(viewModel.hasMorePages, false);
    });

    test('selectCategory updates category and reloads', () async {
      when(
        () => mockRepository.getArticles(
          limit: any(named: 'limit'),
          offset: 0,
          search: any(named: 'search'),
          newsSite: 'NASA',
        ),
      ).thenAnswer(
        (_) async => const ArticleResponse(
          count: 1,
          results: [sampleArticle1],
        ),
      );

      viewModel.selectCategory('NASA');

      expect(viewModel.selectedCategory, 'NASA');
      // allow async loadArticles to complete
      await pumpEventQueue();
      expect(viewModel.articles.length, 1);
    });

    test('clearSearch clears query and reloads', () async {
      when(
        () => mockRepository.getArticles(
          limit: any(named: 'limit'),
          offset: 0,
          search: null,
          newsSite: null,
        ),
      ).thenAnswer(
        (_) async => const ArticleResponse(
          count: 2,
          results: [sampleArticle1, sampleArticle2],
        ),
      );

      viewModel.clearSearch();
      await pumpEventQueue();

      expect(viewModel.searchQuery, isEmpty);
    });
  });
}
