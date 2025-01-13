import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:khel_milap/domain/repositories/news_repository.dart';

import '../entities/news.dart';

class GetNews{
  final NewsRepository newsRepository;

  GetNews({required this.newsRepository});

  Future<Either<Exception,List<News>>> call(){
    return newsRepository.getNews();
  }

}
