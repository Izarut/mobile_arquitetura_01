import 'package:flutter/material.dart';
import 'package:product_app/presentation/pages/product_page.dart';
import 'package:product_app/presentation/viewmodel/product_viewmodel.dart';

class HomePage extends StatelessWidget {
  final ProductViewModel viewModel;

  const HomePage({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tela Inicial'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.shopping_bag),
          label: const Text('Ver Produtos'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductPage(viewModel: viewModel),
              ),
            );
          },
        ),
      ),
    );
  }
}