import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:socbay/blocs/product/product_detail_bloc.dart';
import 'package:socbay/blocs/product/product_detail_event.dart';
import 'package:socbay/blocs/product/product_detail_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/utils/theme_util.dart';
import 'package:socbay/widgets/my_app_bar.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ProductDetailScreenBloc _bloc;

  bool isLike = false;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    _bloc.add(ProductDetailScreenStartedEvent());
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductDetailScreenBloc, ProductDetailScreenState>(
        builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, ProductDetailScreenState state) {}

  Widget _builder(BuildContext context, ProductDetailScreenState state) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Chi tiết sản phẩm",
        isBackNavigation: true,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: paddingHorizontal,
          vertical: paddingVertical,
        ),
        children: [
          Container(
              padding:const EdgeInsets.only(top: 0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                height: context.width - paddingHorizontal * 2,
                child: FullScreenWidget(
                  child: Hero(
                    tag: _bloc.product.images!.isNotEmpty &&
                        _bloc.product.images![0].link == null
                        ? ""
                        : "$protocol${AppConfig.instance.values.apiUrl}" +
                        _bloc.product.images![0].link!,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ImageUtil.loadNetWorkImage(
                          url: _bloc.product.images!.isNotEmpty &&
                              _bloc.product.images![0].link == null
                              ? ""
                              : "$protocol${AppConfig.instance.values.apiUrl}" +
                              _bloc.product.images![0].link!, height: 0, fit: BoxFit.contain),
                      //fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              _bloc.product.name??'',
              style: const TextStyle(
                  color: ColorUtil.bangladeshGreen,
                  fontSize: 20,
                  fontWeight: MyFontWeight.bold),
            ),
          ),
          const Divider(color: Colors.grey, thickness: 1, height: 40),
          const Text(
            "Mô tả:",
            style: TextStyle(
                color: ColorUtil.bangladeshGreen,
                fontWeight: MyFontWeight.bold,
                fontSize: 18),
          ),
          Html(data: _bloc.product.content??""),
        ],
      ),
    );
  }
}
