import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:product_app/data/datasources/product_cache_datasource.dart';
import 'package:product_app/data/datasources/product_remote_datasource.dart';
import 'package:product_app/data/repositories/product_repository_impl.dart';
import 'package:product_app/presentation/pages/product_page.dart';
import 'package:product_app/presentation/viewmodel/product_viewmodel.dart';

void main() {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final remoteDataSource = ProductRemoteDatasource(dio);
  final cacheDataSource = ProductCacheDatasource();
  final repository = ProductRepositoryImpl(remoteDataSource, cacheDataSource);
  final viewModel = ProductViewModel(repository);

  runApp(MyApp(viewModel: viewModel));
}

class MyApp extends StatelessWidget {
  final ProductViewModel viewModel;

  const MyApp({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ProductPage(viewModel: viewModel),
    );
  }
}
