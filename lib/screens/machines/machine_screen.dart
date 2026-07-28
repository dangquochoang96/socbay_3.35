import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:socbay/blocs/product/product_screen_bloc.dart';
import 'package:socbay/blocs/product/product_screen_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/product_model.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';

import '../../blocs/product/product_screen_event.dart';
import '../../utils/color_util.dart';

class ProductScreen extends StatefulWidget {
  final Map<String, dynamic>? args;
  const ProductScreen({super.key, this.args});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late ProductScreenBloc _bloc;
  late ScrollController _scrollController;
  int offSet = 0;
  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    _bloc.add(ProductScreenGetProductCategoryEvent(offSet: offSet));
    _scrollController = ScrollController()..addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductScreenBloc, ProductScreenState>(
      builder: _builder,
      listener: listener,
    );
  }

  void listener(BuildContext context, ProductScreenState state) {}
  //// ADDING THE SCROLL LISTINER
  void _scrollListener() {}

  Widget _builder(BuildContext context, ProductScreenState state) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Sản phẩm',
        isBackNavigation: widget.args != null ? widget.args!['is_back'] : false,
      ),
      body: LoadingIndicator(
        isLoading: _bloc.isLoading,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            shrinkWrap: true,
            controller: _scrollController,
            itemCount: (_bloc.listProductModel.length / 2).ceil(),
            itemBuilder: _buildItemProductCategory,
          ),
        ),
      ),
    );
  }

  Widget _buildItemProductCategory(BuildContext context, int index) {
    List<ProductModel> rowsItem;
    if (_bloc.listProductModel.length - index * 2 <= 0) {
      rowsItem = [];
    } else {
      if (_bloc.listProductModel.length - index * 2 <= 2) {
        rowsItem = _bloc.listProductModel.sublist(index * 2);
      } else {
        rowsItem = _bloc.listProductModel.sublist(index * 2, index * 2 + 2);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: paddingHorizontal,
        vertical: paddingVertical,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.4),
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
                ProductModel productInfo = rowsItem[childIndex];
                return _itemProduct(productInfo);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemProduct(ProductModel productInfo) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.productDetail,
          arguments: productInfo,
        );
      },
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: context.width / 3,
                width: context.width / 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: ImageUtil.loadNetWorkImage(
                    url:
                        productInfo.images!.isNotEmpty &&
                            productInfo.images![0].link != null
                        ? "$protocol${AppConfig.instance.values.apiUrl}${productInfo.images![0].link!}"
                        : "",
                    height: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Text(
                productInfo.name ?? "",
                maxLines: 2,
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: 13,
                  color: ColorUtil.bangladeshGreen,
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    _bloc.add(ProductScreenGetProductCategoryEvent());
  }

  void goToProductViewMore(ProductModel item) {
    Navigator.pushNamed(context, Routes.productViewMoreScreen, arguments: item);
  }
}
