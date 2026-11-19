import '../../core/utils/date_formatter.dart';
import 'author_model.dart';

/// Article model representing a news item from Spaceflight News API
class Article {
  final int id;
  final String title;
  final List<Author> authors;
  final String url;
  final String? imageUrl;
  final String newsSite;
  final String summary;
  final DateTime? publishedAt;
  final DateTime? updatedAt;
  final bool featured;

  const Article({
    required this.id,
    required this.title,
    this.authors = const [],
    required this.url,
    this.imageUrl,
    required this.newsSite,
    required this.summary,
    this.publishedAt,
    this.updatedAt,
    this.featured = false,
  });

  /// Primary author name fallback to news site if author is missing
  String get primaryAuthor {
    if (authors.isNotEmpty && authors.first.name.trim().isNotEmpty) {
      return authors.first.name.trim();
    }
    return newsSite.isNotEmpty ? newsSite : 'Space News';
  }

  /// Initials for the circular author avatar
  String get authorInitials {
    final name = primaryAuthor.trim();
    if (name.isEmpty) return 'SN';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  /// Whether the article has a usable image URL
  bool get hasValidImage =>
      imageUrl != null && imageUrl!.trim().isNotEmpty && imageUrl!.startsWith('http');

  /// Formatted publication date
  String get formattedPublishedDate => DateFormatter.formatStandard(publishedAt);

  /// Relative publication date
  String get relativePublishedDate => DateFormatter.formatRelative(publishedAt);

  factory Article.fromJson(Map<String, dynamic> json) {
    // Parse authors safely
    List<Author> parsedAuthors = [];
    if (json['authors'] is List) {
      parsedAuthors = (json['authors'] as List)
          .whereType<Map<String, dynamic>>()
          .map((authorJson) => Author.fromJson(authorJson))
          .toList();
    }

    return Article(
      id: json['id'] as int? ?? 0,
      title: (json['title'] as String?)?.trim() ?? 'Untitled Article',
      authors: parsedAuthors,
      url: (json['url'] as String?)?.trim() ?? '',
      imageUrl: (json['image_url'] as String?)?.trim(),
      newsSite: (json['news_site'] as String?)?.trim() ?? 'Space News',
      summary: (json['summary'] as String?)?.trim() ?? 'No summary available.',
      publishedAt: DateFormatter.parseIso(json['published_at'] as String?),
      updatedAt: DateFormatter.parseIso(json['updated_at'] as String?),
      featured: json['featured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'authors': authors.map((a) => a.toJson()).toList(),
      'url': url,
      'image_url': imageUrl,
      'news_site': newsSite,
      'summary': summary,
      'published_at': publishedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'featured': featured,
    };
  }

  Article copyWith({
    int? id,
    String? title,
    List<Author>? authors,
    String? url,
    String? imageUrl,
    String? newsSite,
    String? summary,
    DateTime? publishedAt,
    DateTime? updatedAt,
    bool? featured,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      newsSite: newsSite ?? this.newsSite,
      summary: summary ?? this.summary,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      featured: featured ?? this.featured,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Article && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
