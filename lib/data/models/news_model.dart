import '../../domain/entities/news.dart';

class NewsModel extends News {
  const NewsModel({
    required super.id,
    required super.headline,
    required super.description,
    required super.imageID,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'],
      headline: json['hline'],
      description: json['intro'],
      imageID: json['imageId'],
    );
  }
}