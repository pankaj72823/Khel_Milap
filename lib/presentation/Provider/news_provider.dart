import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/data_source/news_remote_data_source.dart';
import '../../data/repositories_implementation/news_repository_impl.dart';
import '../../domain/entities/news.dart';
import '../../domain/repositories/news_repository.dart';
import '../../domain/use_cases/get_news.dart';
import 'package:http/http.dart' as http;

final newsProvider = FutureProvider<List<News>>((ref) async {
  final getNews = ref.watch(getNewsUseCaseProvider);
  final result = await getNews.call();
  return result.fold((error) => throw error, (news) => news);
});

final getNewsUseCaseProvider = Provider<GetNews>((ref) {
  final repository = ref.watch(newsRepositoryProvider);
  return GetNews(newsRepository: repository);
});


final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  final dataSource = ref.watch(newsRemoteDataSourceProvider);
  return NewsRepositoryImpl(remoteDataSource: dataSource);
});

final newsRemoteDataSourceProvider = Provider<NewsRemoteDataSource>((ref) {
  return NewsRemoteDataSourceImpl(client : http.Client());
});
