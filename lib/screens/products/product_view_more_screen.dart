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
        builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, ProductViewMoreScreenState state) {}

  Widget _builder(BuildContext context, ProductViewMoreScreenState state) {
    return Scaffold(
      appBar: MyAppBar(
        isBackNavigation: true,
        title: "${_bloc.productCategory.name}",
      ),
      // body: AlignedGridView.count(
      //   padding: const EdgeInsets.symmetric(
      //     horizontal: paddingHorizontal,
      //     vertical: paddingVertical,
      //   ),
      //   shrinkWrap: true,
      //   physics: const NeverScrollableScrollPhysics(),
      //   mainAxisSpacing: 10,
      //   crossAxisSpacing: 10,
      //   crossAxisCount: 2,
      //   itemCount: _bloc.productCategory.product?.length ?? 0,
      //   itemBuilder: (BuildContext childContext, int childIndex) {
      //     ProductModel productInfo = _bloc.productCategory.product![childIndex];
      //     return _itemProduct(productInfo);
      //   },
      // ),
    );
  }

  // Widget _itemProduct(ProductModel productInfo) {
  //   return GestureDetector(
  //     onTap: () {
  //       Navigator.pushNamed(context, Routes.productDetail,
  //           arguments: productInfo);
  //     },
  //     child: Card(
  //       elevation: 2,
  //       child: Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             ImageUtil.loadNetWorkImage(
  //                 url: productInfo.images?[0].link ?? "",
  //                 height: context.width / 3,
  //                 width: double.infinity),
  //             const SizedBox(height: 8),
  //             Text(
  //               productInfo.name ?? "",
  //               maxLines: 2,
  //               style: const TextStyle(
  //                   overflow: TextOverflow.ellipsis,
  //                   fontSize: 13,
  //                   color: ColorUtil.bangladeshGreen),
  //             ),
  //             const SizedBox(height: 5),
  //             // Row(
  //             //   children: [
  //             //     if (productInfo.price != 0 &&
  //             //         productInfo.price != null)
  //             //       Text(NumberFormatUtil.parseToVND(productInfo.price),
  //             //           style: const TextStyle(
  //             //               fontSize: 12,
  //             //               fontWeight: FontWeight.bold,
  //             //               color: ColorUtil.brightYellow)),
  //             //     const Spacer(),
  //             //     if (productInfo.priceSale != 0 &&
  //             //         productInfo.priceSale != null)
  //             //       Text(NumberFormatUtil.parseToVND(productInfo.priceSale),
  //             //           style: const TextStyle(
  //             //               color: Colors.grey,
  //             //               fontSize: 11,
  //             //               decoration: TextDecoration.lineThrough))
  //             //   ],
  //             // )
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
