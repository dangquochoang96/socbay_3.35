import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:socbay/blocs/user_info/favourite_product/favourite_product_bloc.dart';
import 'package:socbay/blocs/user_info/favourite_product/favourite_product_event.dart';
import 'package:socbay/blocs/user_info/favourite_product/favourite_product_state.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/product_model.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';

class FavouriteProductScreen extends StatefulWidget {
  const FavouriteProductScreen({super.key});

  @override
  State<FavouriteProductScreen> createState() => _FavouriteProductScreenState();
}

class _FavouriteProductScreenState extends State<FavouriteProductScreen> {
  late FavouriteProductScreenBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    _bloc.add(FavouriteProductStartedEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FavouriteProductScreenBloc, FavouriteProductState>(
        builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, FavouriteProductState state) {}

  Widget _builder(BuildContext context, FavouriteProductState state) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Sản phẩm yêu thích",
        isBackNavigation: true,
        centerTitle: true,
      ),
      body: LoadingIndicator(
        isLoading: _bloc.isLoading,
        child: Visibility(
          visible: _bloc.isLoading || _bloc.listProduct.isNotEmpty,
          replacement: const Center(
            child: Text("Trống"),
          ),
          child: AlignedGridView.count(
              padding: const EdgeInsets.symmetric(
                  horizontal: paddingHorizontal, vertical: 20),
              shrinkWrap: true,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              crossAxisCount: 2,
              itemCount: _bloc.listProduct.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildItemProduct(_bloc.listProduct[index]);
              }),
        ),
      ),
    );
  }

  Widget _buildItemProduct(ProductModel itemProduct) {
    return Card(
      elevation: 2,
      child: ButtonWidget(
        padding: const EdgeInsets.all(8),
        onTap: () {
          Navigator.pushNamed(context, Routes.productDetail,
              arguments: itemProduct);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImageUtil.loadNetWorkImage(
                url: itemProduct.images?[0].link ?? "",
                height: context.width * 0.4,
                width: context.width * 0.4),
            const SizedBox(height: 8),
            Text(
              itemProduct.name ?? "",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 13, color: ColorUtil.bangladeshGreen),
            ),
            const SizedBox(height: 5),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     if (itemProduct.price != 0 && itemProduct.price != null)
            //       Text(NumberFormatUtil.parseToVND(itemProduct.price),
            //           overflow: TextOverflow.ellipsis,
            //           style: const TextStyle(
            //               fontSize: 12,
            //               fontWeight: FontWeight.bold,
            //               color: ColorUtil.brightYellow)),
            //     if (itemProduct.priceSale != 0 && itemProduct.priceSale != null)
            //       Text(NumberFormatUtil.parseToVND(itemProduct.priceSale),
            //           overflow: TextOverflow.ellipsis,
            //           style: const TextStyle(
            //               color: Colors.grey,
            //               fontSize: 11,
            //               decoration: TextDecoration.lineThrough))
            //   ],
            // )
          ],
        ),
      ),
    );
  }
}
