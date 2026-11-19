/// API Constants for Spaceflight News API
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.spaceflightnewsapi.net/v4';
  static const String articlesEndpoint = '/articles/';
  
  static const int defaultLimit = 15;
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Predefined news sites for category pills / filters
  static const List<String> newsSiteCategories = [
    'All',
    'NASA',
    'SpaceNews',
    'European Spaceflight',
    'Teslarati',
    'SpacePolicyOnline',
    'Arstechnica',
    'NASASpaceflight',
  ];
}
