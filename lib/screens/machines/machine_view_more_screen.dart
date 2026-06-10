import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/product/product_view_more/product_view_more_screen_bloc.dart';
import 'package:socbay/blocs/product/product_view_more/product_view_more_screen_event.dart';
import 'package:socbay/blocs/product/product_view_more/product_view_more_screen_state.dart';
import 'package:socbay/widgets/my_app_bar.dart';

class ProductViewMoreScreen extends StatefulWidget {
  const ProductViewMoreScreen({super.key});

  @override
  State<ProductViewMoreScreen> createState() => _ProductViewMoreScreenState();
}

class _ProductViewMoreScreenState extends State<ProductViewMoreScreen> {
  late ProductViewMoreScreenBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    _bloc.add(ProductViewMoreScreenStartedEvent());
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductViewMoreScreenBloc, ProductViewMoreScreenState>(
      builder: _builder,
      listener: _listener,
    );
  }

  void _listener(BuildContext context, ProductViewMoreScreenState state) {}

  Widget _builder(BuildContext context, ProductViewMoreScreenState state) {
    return Scaffold(
      appBar: MyAppBar(
        isBackNavigation: true,
        title: "${_bloc.productCategory.name}",
      ),
    );
  }
}
