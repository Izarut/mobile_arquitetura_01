import 'package:flutter/material.dart';
import 'package:product_app/presentation/session/session_manager.dart';
import 'package:product_app/presentation/pages/login_page.dart';
import 'package:product_app/presentation/viewmodel/product_state.dart';
import 'package:product_app/presentation/viewmodel/product_viewmodel.dart';
import 'package:product_app/presentation/pages/product_detail_page.dart';
import 'package:product_app/presentation/pages/product_form_page.dart';

class ProductPage extends StatefulWidget {
  final ProductViewModel viewModel;

  const ProductPage({super.key, required this.viewModel});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  void initState() {
    super.initState();
    // Bloqueia acesso sem login — redireciona para LoginPage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!SessionManager.instance.isAuthenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    });
  }

  void _handleLogout() {
    SessionManager.instance.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionManager.instance.currentUser;
    final username = session?.username ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Produtos'),
            if (username.isNotEmpty)
              Text(
                'Olá, $username',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer
                          .withOpacity(0.8),
                    ),
              ),
          ],
        ),
        actions: [
          // Botão de recarregar
          ValueListenableBuilder<ProductState>(
            valueListenable: widget.viewModel.state,
            builder: (context, state, _) {
              if (state.isLoading) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Recarregar da API',
                onPressed: widget.viewModel.loadProducts,
              );
            },
          ),
          // Botão de logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sair'),
                  content: const Text('Deseja encerrar sua sessão?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _handleLogout();
                      },
                      child: const Text('Sair'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<ProductState>(
        valueListenable: widget.viewModel.state,
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

      // Botão de adicionar produto
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductFormPage(viewModel: widget.viewModel),
            ),
          );
        },
        tooltip: 'Adicionar produto',
        child: const Icon(Icons.add),
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
            'Nenhum produto carregado ainda.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Busque produtos da API ou adicione um manualmente.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: widget.viewModel.loadProducts,
            icon: const Icon(Icons.cloud_download_outlined),
            label: const Text('Carregar da API'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ProductFormPage(viewModel: widget.viewModel),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar manualmente'),
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
    final products = state.products;

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 64),
            const SizedBox(height: 16),
            const Text('Nenhum produto encontrado.'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: widget.viewModel.loadProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Recarregar'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (fromCache)
          MaterialBanner(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            content: const Text(
              'Sem conexão com a API — exibindo dados salvos localmente.',
            ),
            leading: const Icon(Icons.wifi_off),
            actions: [
              TextButton(
                onPressed: widget.viewModel.loadProducts,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        Expanded(
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailPage(product: product),
                      ),
                    );
                  },
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          product.favorite
                              ? Icons.star
                              : Icons.star_border,
                          color: product.favorite ? Colors.amber : null,
                        ),
                        onPressed: () {
                          widget.viewModel.toggleFavorite(product.id);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductFormPage(
                                product: product,
                                viewModel: widget.viewModel,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          widget.viewModel.deleteProduct(product.id);
                        },
                      ),
                    ],
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
              onPressed: widget.viewModel.loadProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
