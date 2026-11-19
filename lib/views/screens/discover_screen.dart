import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/news_list_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../widgets/article_card.dart';
import '../widgets/category_pills.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_state_view.dart';
import '../widgets/pagination_footer.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/search_input_bar.dart';
import '../widgets/shimmer_article_card.dart';
import 'article_detail_pager_screen.dart';

/// Discover / News List screen matching the reference UI design
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _searchController = TextEditingController();

    // Initial load on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<NewsListViewModel>();
      if (viewModel.state == ViewState.initial) {
        viewModel.loadArticles();
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Trigger pagination when user scrolls within 250px of the bottom
    if (maxScroll - currentScroll <= 250) {
      context.read<NewsListViewModel>().loadMoreArticles();
    }
  }

  void _onArticleTap(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ArticleDetailPagerScreen(initialIndex: index),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar / Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top navigation row with theme switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.searchBarLight,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          onPressed: () {
                            // If search query is active, clear it; otherwise show feedback
                            if (_searchController.text.isNotEmpty) {
                              _searchController.clear();
                              context.read<NewsListViewModel>().clearSearch();
                            }
                          },
                        ),
                      ),
                      Consumer<ThemeViewModel>(
                        builder: (context, themeVm, _) {
                          return IconButton(
                            icon: Icon(
                              themeVm.isDarkMode
                                  ? Icons.light_mode_rounded
                                  : Icons.dark_mode_rounded,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                            tooltip: 'Toggle Theme',
                            onPressed: () => themeVm.toggleTheme(),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Title: "Discover"
                  Text(
                    'Discover',
                    style: theme.textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 4),
                  // Subtitle: "News from all around the world"
                  Text(
                    'News from all around the world',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search Input Bar
                  SearchInputBar(
                    controller: _searchController,
                    onChanged: (query) {
                      context.read<NewsListViewModel>().onSearchChanged(query);
                    },
                    onClear: () {
                      _searchController.clear();
                      context.read<NewsListViewModel>().clearSearch();
                    },
                    onFilterTap: () {
                      // Scroll pills to start or focus
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Use the category pills below to filter news sites'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Category Filter Pills
            Consumer<NewsListViewModel>(
              builder: (context, viewModel, _) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: CategoryPills(
                    selectedCategory: viewModel.selectedCategory,
                    onSelected: (cat) => viewModel.selectCategory(cat),
                  ),
                );
              },
            ),

            const SizedBox(height: 4),

            // Main Articles List / Grid with States
            Expanded(
              child: Consumer<NewsListViewModel>(
                builder: (context, viewModel, _) {
                  // 1. Loading State (Initial or Filter change)
                  if (viewModel.isLoading) {
                    return _buildLoadingList();
                  }

                  // 2. Error State (Initial load failed)
                  if (viewModel.hasError) {
                    return RefreshIndicator(
                      onRefresh: viewModel.refreshArticles,
                      child: ErrorStateView(
                        message: viewModel.errorMessage,
                        onRetry: viewModel.loadArticles,
                      ),
                    );
                  }

                  // 3. Empty State (No results)
                  if (viewModel.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: viewModel.refreshArticles,
                      child: EmptyStateView(
                        title: viewModel.searchQuery.isNotEmpty
                            ? 'No Results Found'
                            : 'No Articles Available',
                        subtitle: viewModel.searchQuery.isNotEmpty
                            ? 'No news articles found for "${viewModel.searchQuery}". Try different keywords.'
                            : 'No articles found in this category. Try selecting another filter.',
                        actionLabel: viewModel.searchQuery.isNotEmpty
                            ? 'Clear Search'
                            : 'Show All Articles',
                        onAction: () {
                          if (viewModel.searchQuery.isNotEmpty) {
                            _searchController.clear();
                            viewModel.clearSearch();
                          } else {
                            viewModel.selectCategory('All');
                          }
                        },
                      ),
                    );
                  }

                  // 4. Loaded State with Responsive List/Grid and Pagination
                  return RefreshIndicator(
                    onRefresh: viewModel.refreshArticles,
                    color: AppColors.primary,
                    child: ResponsiveLayout(
                      phone: (context, constraints) => _buildPhoneList(viewModel),
                      tablet: (context, constraints) => _buildTabletGrid(viewModel, constraints),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) => const ShimmerArticleCard(),
    );
  }

  Widget _buildPhoneList(NewsListViewModel viewModel) {
    final itemCount = viewModel.articles.length + 1; // +1 for pagination footer

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 6, bottom: 24),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == viewModel.articles.length) {
          return PaginationFooter(
            isLoading: viewModel.isLoadingMore,
            error: viewModel.paginationError,
            onRetry: viewModel.retryPagination,
            hasMore: viewModel.hasMorePages,
          );
        }

        final article = viewModel.articles[index];
        return ArticleCard(
          article: article,
          onTap: () => _onArticleTap(index),
        );
      },
    );
  }

  Widget _buildTabletGrid(NewsListViewModel viewModel, BoxConstraints constraints) {
    final crossAxisCount = constraints.maxWidth > 950 ? 3 : 2;
    final articlesCount = viewModel.articles.length;

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final article = viewModel.articles[index];
                return ArticleCard(
                  article: article,
                  isGridItem: true,
                  onTap: () => _onArticleTap(index),
                );
              },
              childCount: articlesCount,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: PaginationFooter(
            isLoading: viewModel.isLoadingMore,
            error: viewModel.paginationError,
            onRetry: viewModel.retryPagination,
            hasMore: viewModel.hasMorePages,
          ),
        ),
      ],
    );
  }
}
