import 'package:flutter/material.dart';
import 'package:product_app/presentation/session/session_manager.dart';
import 'package:product_app/presentation/pages/login_page.dart';
import 'package:product_app/presentation/pages/product_page.dart';
import 'package:product_app/presentation/pages/favorites_page.dart';
import 'package:product_app/presentation/viewmodel/product_viewmodel.dart';
import 'package:product_app/presentation/viewmodel/product_state.dart';

class HomePage extends StatefulWidget {
  final ProductViewModel viewModel;

  const HomePage({super.key, required this.viewModel});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Bloqueia acesso sem login
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

    // Títulos e ícones de cada aba
    final tabs = ['Produtos', 'Favoritos'];
    final icons = [Icons.shopping_bag_outlined, Icons.star_outline];
    final activeIcons = [Icons.shopping_bag, Icons.star];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tabs[_currentIndex]),
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
          // Botão recarregar (só na aba de produtos)
          if (_currentIndex == 0)
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

      // Conteúdo das abas — IndexedStack mantém o estado de cada aba
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ProductPage(viewModel: widget.viewModel),
          FavoritesPage(viewModel: widget.viewModel),
        ],
      ),

      // Barra de navegação inferior com contador de favoritos
      bottomNavigationBar: ValueListenableBuilder<ProductState>(
        valueListenable: widget.viewModel.state,
        builder: (context, state, _) {
          final favCount = state.products.where((p) => p.favorite).length;

          return NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.shopping_bag_outlined),
                selectedIcon: Icon(Icons.shopping_bag),
                label: 'Produtos',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: favCount > 0,
                  label: Text('$favCount'),
                  child: Icon(activeIcons[1]),
                ),
                selectedIcon: Badge(
                  isLabelVisible: favCount > 0,
                  label: Text('$favCount'),
                  child: Icon(activeIcons[1]),
                ),
                label: 'Favoritos',
              ),
            ],
          );
        },
      ),
    );
  }
}
