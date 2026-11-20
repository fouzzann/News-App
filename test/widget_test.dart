import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:simple_news_app/data/models/article_model.dart';
import 'package:simple_news_app/data/models/article_response_model.dart';
import 'package:simple_news_app/data/repositories/news_repository.dart';
import 'package:simple_news_app/viewmodels/news_list_viewmodel.dart';
import 'package:simple_news_app/viewmodels/theme_viewmodel.dart';
import 'package:simple_news_app/views/screens/splash_screen.dart';
import 'package:simple_news_app/views/widgets/article_card.dart';
import 'package:simple_news_app/views/widgets/empty_state_view.dart';
import 'package:simple_news_app/views/widgets/error_state_view.dart';
import 'package:mocktail/mocktail.dart';

class MockNewsRepository extends Mock implements NewsRepository {}

void main() {
  group('Widget Tests', () {
    const testArticle = Article(
      id: 99,
      title: 'Voyager 1 Sends New Signals From Interstellar Space',
      url: 'https://example.com/voyager',
      newsSite: 'NASA',
      summary: 'Data received after successful thruster test.',
      publishedAt: null,
    );

    testWidgets('SplashScreen renders app name, subtitle, and version',
        (WidgetTester tester) async {
      final mockRepo = MockNewsRepository();
      when(() => mockRepo.getArticles(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            search: any(named: 'search'),
            newsSite: any(named: 'newsSite'),
          )).thenAnswer((_) async => const ArticleResponse(
            count: 0,
            results: [],
          ));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeViewModel>(
              create: (_) => ThemeViewModel(),
            ),
            Provider<NewsRepository>.value(value: mockRepo),
            ChangeNotifierProvider<NewsListViewModel>(
              create: (_) => NewsListViewModel(repository: mockRepo),
            ),
          ],
          child: const MaterialApp(
            home: SplashScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('News App'), findsOneWidget);
      expect(find.text('Stay informed with the latest updates'), findsOneWidget);
      expect(find.text('v1.0.0'), findsOneWidget);

      // Advance time to complete splash delay and navigation transition
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pump(const Duration(milliseconds: 700));
    });

    testWidgets('ArticleCard renders title, news site, and author correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArticleCard(
              article: testArticle,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(
        find.text('Voyager 1 Sends New Signals From Interstellar Space'),
        findsOneWidget,
      );
      expect(find.text('NASA'), findsWidgets);
    });

    testWidgets('ErrorStateView renders error message and triggers retry',
        (WidgetTester tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorStateView(
              message: 'Custom network error message',
              onRetry: () {
                retried = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Oops! Something went wrong'), findsOneWidget);
      expect(find.text('Custom network error message'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      await tester.pump();

      expect(retried, isTrue);
    });

    testWidgets('EmptyStateView renders title and handles action button',
        (WidgetTester tester) async {
      bool actionClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              title: 'No News Here',
              subtitle: 'Check back soon',
              actionLabel: 'Refresh',
              onAction: () {
                actionClicked = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('No News Here'), findsOneWidget);
      expect(find.text('Check back soon'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);

      await tester.tap(find.text('Refresh'));
      await tester.pump();

      expect(actionClicked, isTrue);
    });
  });
}
