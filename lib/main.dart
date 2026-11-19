import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/news_repository.dart';
import 'data/repositories/news_repository_impl.dart';
import 'viewmodels/news_list_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'views/screens/discover_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SimpleNewsApp());
}

class SimpleNewsApp extends StatelessWidget {
  const SimpleNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme Management
        ChangeNotifierProvider<ThemeViewModel>(
          create: (_) => ThemeViewModel(),
        ),
        // Repository Layer
        Provider<NewsRepository>(
          create: (_) => NewsRepositoryImpl(),
        ),
        // ViewModel Layer (injected with repository)
        ChangeNotifierProvider<NewsListViewModel>(
          create: (context) => NewsListViewModel(
            repository: context.read<NewsRepository>(),
          ),
        ),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVm, _) {
          return MaterialApp(
            title: 'Simple News App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeVm.themeMode,
            home: const DiscoverScreen(),
          );
        },
      ),
    );
  }
}
