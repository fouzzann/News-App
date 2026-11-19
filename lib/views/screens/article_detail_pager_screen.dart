import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/news_list_viewmodel.dart';
import 'article_detail_view.dart';

/// Full-screen horizontal swipe pager for articles (Gmail-style swipe navigation)
class ArticleDetailPagerScreen extends StatefulWidget {
  final int initialIndex;

  const ArticleDetailPagerScreen({
    super.key,
    required this.initialIndex,
  });

  @override
  State<ArticleDetailPagerScreen> createState() => _ArticleDetailPagerScreenState();
}

class _ArticleDetailPagerScreenState extends State<ArticleDetailPagerScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Check if we need to load more immediately on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsListViewModel>().fetchNextPageIfNeeded(_currentIndex);
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Trigger proactive next page loading when user is near the end
    context.read<NewsListViewModel>().fetchNextPageIfNeeded(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsListViewModel>(
      builder: (context, viewModel, child) {
        final articles = viewModel.articles;

        if (articles.isEmpty) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('No article selected.'),
            ),
          );
        }

        return Scaffold(
          body: PageView.builder(
            controller: _pageController,
            itemCount: articles.length,
            onPageChanged: _onPageChanged,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final article = articles[index];
              return ArticleDetailView(
                key: ValueKey('article_detail_${article.id}'),
                article: article,
                onBack: () => Navigator.of(context).pop(),
              );
            },
          ),
        );
      },
    );
  }
}
