import 'package:flutter/material.dart';
import 'package:product_app/domain/entities/product.dart';
import 'package:product_app/presentation/viewmodel/product_viewmodel.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;
  final ProductViewModel viewModel;

  const ProductFormPage({
    super.key,
    this.product,
    required this.viewModel,
  });

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController priceController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();

    titleController =
        TextEditingController(text: widget.product?.title ?? '');
    priceController =
        TextEditingController(text: widget.product?.price.toString() ?? '');
    descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null
            ? 'Novo Produto'
            : 'Editar Produto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Preço'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Descrição'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final product = Product(
                    id: widget.product?.id ?? 0,
                    title: titleController.text,
                    price: double.parse(priceController.text),
                    description: descriptionController.text,
                    image: widget.product?.image ?? '',
                  );

                  if (widget.product == null) {
                    await viewModel.addProduct(product);
                  } else {
                    await viewModel.updateProduct(product);
                  }

                  Navigator.pop(context);
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}