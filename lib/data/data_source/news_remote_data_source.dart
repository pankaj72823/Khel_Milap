import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/news_model.dart';

abstract class NewsRemoteDataSource {
  Future<List<NewsModel>> fetchNews();
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource{

  NewsRemoteDataSourceImpl({required this.client});

  final http.Client client;
  @override
  Future<List<NewsModel>> fetchNews() async {
    final response = await client.get(
        Uri.parse(
          "${dotenv.env['NEWS_BASE_URL']}/news/v1/index"
        ),
      headers: {
          'x-rapidapi-host': dotenv.env['NEWS_API_HOST'] ?? '',
          'x-rapidapi-key': dotenv.env['NEWS_API_KEY'] ?? '',
      },
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['storyList'];
      print(data);
      return (data as List)
          .where((item) => item.containsKey('story')) // Ensure the item has a 'story' key
          .map((item) => NewsModel.fromJson(item['story']))
          .toList();
    } else {
      throw Exception('Failed to fetch news');
    }
  }

}