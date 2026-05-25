import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:socbay/blocs/product_category/product_category_bloc.dart';
import 'package:socbay/blocs/product_category/product_category_event.dart';
import 'package:socbay/blocs/product_category/product_category_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/product_category.dart';
import 'package:socbay/data/model/product_model.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';

class ProductCategoryScreen extends StatefulWidget {
  final Map<String, dynamic>? args;

  const ProductCategoryScreen({super.key, this.args});

  @override
  State<ProductCategoryScreen> createState() => _ProductCategoryScreenState();
}

class _ProductCategoryScreenState extends State<ProductCategoryScreen> {
  late ProductCategoryScreenBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    _bloc.add(ProductCategoryScreenGetListEvent());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductCategoryScreenBloc, ProductCategoryScreenState>(
        builder: _builder, listener: listener);
  }

  void listener(BuildContext context, ProductCategoryScreenState state) {}

  Widget _builder(BuildContext context, ProductCategoryScreenState state) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Loại Sản phẩm',
        isBackNavigation: widget.args != null ? widget.args!['is_back'] : false,
      ),
      body: LoadingIndicator(
        isLoading: _bloc.isLoading,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: (_bloc.listProductCategoryModel.length / 2).ceil(),
            itemBuilder: _buildItemProductCategory,
          ),
        ),
      ),
    );
  }

  Widget _buildItemProductCategory(BuildContext context, int index) {
    List<ProductCategory> rowsItem;
    if (_bloc.listProductCategoryModel.length - index * 2 <= 0) {
      rowsItem = [];
    } else {
      if (_bloc.listProductCategoryModel.length - index * 2 <= 2) {
        rowsItem = _bloc.listProductCategoryModel.sublist(index * 2);
      } else {
        rowsItem =
            _bloc.listProductCategoryModel.sublist(index * 2, index * 2 + 2);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: paddingHorizontal, vertical: paddingVertical),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: AlignedGridView.count(
              //controller: _scrollController,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              crossAxisCount: 2,
              itemCount: rowsItem.length,
              itemBuilder: (BuildContext childContext, int childIndex) {
                ProductCategory productCategoryInfo = rowsItem[childIndex];
                return _itemProduct(productCategoryInfo);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _itemProduct(ProductCategory productCategoryInfo) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, Routes.productScreen,
            arguments: {'cateId': productCategoryInfo.id,"is_back": true});
      },
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageUtil.loadNetWorkImage(
                  url: productCategoryInfo.image != null
                      ? "$protocol${AppConfig.instance.values.apiUrl}${productCategoryInfo.image!}"
                      : "",
                  fit: BoxFit.contain,
                  height: context.width / 2.8,
                  // width: double.infinity
              ),
              const SizedBox(height: 8),
              Text(
                productCategoryInfo.name ?? "",
                maxLines: 2,
                style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 13,
                    color: ColorUtil.bangladeshGreen),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    _bloc.add(ProductCategoryScreenGetListEvent());
  }

  void goToProductViewMore(ProductModel item) {
    Navigator.pushNamed(context, Routes.productViewMoreScreen, arguments: item);
  }
}
