
import 'package:dartz/dartz.dart';
import 'package:khel_milap/data/data_source/news_remote_data_source.dart';
import 'package:khel_milap/domain/entities/news.dart';
import 'package:khel_milap/domain/repositories/news_repository.dart';

class NewsRepositoryImpl implements NewsRepository{
  NewsRepositoryImpl({required this.remoteDataSource});
  final NewsRemoteDataSource remoteDataSource;

  @override
  Future<Either<Exception, List<News>>> getNews() async {
    try{
      final news = await remoteDataSource.fetchNews();
      print(news);
      return Right(news);
    } catch(e){
      return Left(Exception("Server exception"));
    }
  }

}
