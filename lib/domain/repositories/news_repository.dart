
import 'package:dartz/dartz.dart';
import 'package:khel_milap/domain/entities/news.dart';
abstract class NewsRepository{
  Future<Either<Exception,List<News>>> getNews();
}
