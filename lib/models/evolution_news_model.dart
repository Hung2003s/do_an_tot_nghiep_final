class EvolutionNews {
  final String newsId;
  final String animalId;
  final String news;
  final String imageUrl;

  EvolutionNews({
    required this.newsId,
    required this.animalId,
    required this.news,
    required this.imageUrl,
  });

  // Factory constructor để tạo object từ Map
  factory EvolutionNews.fromMap(Map<String, dynamic> map) {
    return EvolutionNews(
      newsId: map['news_id'] ?? '',
      animalId: map['animal_id'] ?? '',
      news: map['news'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  // Phương thức để chuyển object thành Map
  Map<String, dynamic> toMap() {
    return {
      'news_id': newsId,
      'animal_id': animalId,
      'news': news,
      'imageUrl': imageUrl,
    };
  }
}
