import 'package:flutter/material.dart';
import 'package:product_app/core/errors/failure.dart';
import 'package:product_app/data/datasources/auth_remote_datasource.dart';
import 'package:product_app/data/repositories/auth_repository_impl.dart';
import 'package:product_app/presentation/session/session_manager.dart';
import 'package:product_app/presentation/pages/home_page.dart';
import 'package:product_app/presentation/viewmodel/product_viewmodel.dart';
import 'package:product_app/data/datasources/product_remote_datasource.dart';
import 'package:product_app/data/datasources/product_cache_datasource.dart';
import 'package:product_app/data/repositories/product_repository_impl.dart';

// Estado interno da tela de login
enum _LoginStatus { idle, loading, error }

class _LoginState {
  final _LoginStatus status;
  final String? errorMessage;

  const _LoginState({this.status = _LoginStatus.idle, this.errorMessage});

  _LoginState copyWith({_LoginStatus? status, String? errorMessage}) {
    return _LoginState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => status == _LoginStatus.loading;
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _stateNotifier = ValueNotifier(const _LoginState());

  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _stateNotifier.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Valida os campos antes de chamar a API
    if (!_formKey.currentState!.validate()) return;

    _stateNotifier.value = const _LoginState(status: _LoginStatus.loading);

    try {
      final datasource = AuthRemoteDatasource();
      final repository = AuthRepositoryImpl(datasource);

      final session = await repository.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Salva sessão e navega para a tela de produtos
      SessionManager.instance.saveSession(session);

      if (!mounted) return;

      // Monta o viewModel de produtos e navega substituindo a rota atual
      final remoteDataSource = ProductRemoteDatasource();
      final cacheDataSource = ProductCacheDatasource();
      final productRepository =
          ProductRepositoryImpl(remoteDataSource, cacheDataSource);
      final viewModel = ProductViewModel(productRepository);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(viewModel: viewModel),
        ),
      );
    } on Failure catch (f) {
      _stateNotifier.value = _LoginState(
        status: _LoginStatus.error,
        errorMessage: f.message,
      );
    } catch (e) {
      _stateNotifier.value = const _LoginState(
        status: _LoginStatus.error,
        errorMessage: 'Erro inesperado. Tente novamente.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ícone / logo
                  Icon(
                    Icons.shopping_bag_rounded,
                    size: 72,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Product App',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    'Faça login para continuar',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.outline,
                        ),
                  ),
                  const SizedBox(height: 36),

                  // Campo de usuário
                  TextFormField(
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Usuário',
                      hintText: 'ex: emilys',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o nome de usuário.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo de senha
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(),
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe a senha.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Botão de login / loading
                  ValueListenableBuilder<_LoginState>(
                    valueListenable: _stateNotifier,
                    builder: (context, state, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Mensagem de erro
                          if (state.status == _LoginStatus.error &&
                              state.errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: colorScheme.onErrorContainer,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      state.errorMessage!,
                                      style: TextStyle(
                                        color: colorScheme.onErrorContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Botão principal
                          FilledButton(
                            onPressed:
                                state.isLoading ? null : _handleLogin,
                            child: state.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text('Entrar'),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Dica de credenciais de teste
                  Text(
                    'Teste: usuário emilys / senha emilyspass',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
