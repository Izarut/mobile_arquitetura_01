import 'package:flutter/material.dart';
import 'package:product_app/data/datasources/product_remote_datasource.dart';
import 'package:product_app/data/repositories/product_repository_impl.dart';
import 'package:product_app/presentation/pages/product_page.dart';
import 'package:product_app/presentation/viewmodel/product_viewmodel.dart';

void main() {
  final remoteDataSource = ProductRemoteDatasource();
  final repository = ProductRepositoryImpl(remoteDataSource);
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