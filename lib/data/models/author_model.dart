/// Author model representing article author metadata
class Author {
  final String name;
  final Map<String, dynamic>? socials;

  const Author({
    required this.name,
    this.socials,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      name: json['name'] as String? ?? 'Unknown Author',
      socials: json['socials'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (socials != null) 'socials': socials,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Author &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}
