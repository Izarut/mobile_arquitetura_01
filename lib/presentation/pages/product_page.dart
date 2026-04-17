import 'package:flutter/material.dart';
import 'package:product_app/presentation/viewmodel/product_state.dart';
import 'package:product_app/presentation/viewmodel/product_viewmodel.dart';

class ProductPage extends StatelessWidget {
  final ProductViewModel viewModel;

  const ProductPage({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ValueListenableBuilder<ProductState>(
        valueListenable: viewModel.state,
        builder: (context, state, _) {
          return switch (state.status) {
            ProductStatus.initial => _buildInitial(context),

            ProductStatus.loading => _buildLoading(),

            ProductStatus.success => _buildProductList(
                context,
                state,
                fromCache: false,
              ),

            ProductStatus.cached => _buildProductList(
                context,
                state,
                fromCache: true,
              ),

            ProductStatus.error => _buildError(context, state),
          };
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: viewModel.loadProducts,
        icon: const Icon(Icons.refresh),
        label: const Text('Carregar'),
      ),
    );
  }

  Widget _buildInitial(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Toque em "Carregar" para buscar os produtos',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Carregando produtos...'),
        ],
      ),
    );
  }

  Widget _buildProductList(
    BuildContext context,
    ProductState state, {
    required bool fromCache,
  }) {
    return Column(
      children: [
        if (fromCache)
          MaterialBanner(
            backgroundColor:
                Theme.of(context).colorScheme.secondaryContainer,
            content: const Text(
              'Sem conexão com a API — exibindo dados salvos localmente.',
            ),
            leading: const Icon(Icons.wifi_off),
            actions: [
              TextButton(
                onPressed: viewModel.loadProducts,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),

        Expanded(
          child: ListView.builder(
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              final product = state.products[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.image,
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, size: 48),
                    ),
                  ),
                  title: Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    'R\$ ${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, ProductState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Não foi possível carregar os produtos',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage ?? 'Erro desconhecido',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: viewModel.loadProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
