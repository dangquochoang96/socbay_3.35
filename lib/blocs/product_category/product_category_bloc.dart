import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/product_category/product_category_event.dart';
import 'package:socbay/blocs/product_category/product_category_state.dart';

import 'package:socbay/utils/auth_http.dart' as http;
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/data_provider/api_endpoints.dart';
import 'package:socbay/data/model/product_category.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/utils/logger_util.dart';

class ProductCategoryScreenBloc
    extends Bloc<ProductCategoryScreenEvent, ProductCategoryScreenState> {
  final ApiRepository apiRepository;
  bool isLoading = false;

  List<ProductCategory> listProductCategoryModel = [];

  ProductCategoryScreenBloc({required this.apiRepository})
    : super(ProductCategoryScreenInitialState()) {
    on<ProductCategoryScreenGetListEvent>(_mapGetProductCategoryEventToState);
  }

  FutureOr<void> _mapGetProductCategoryEventToState(
    ProductCategoryScreenGetListEvent event,
    Emitter<ProductCategoryScreenState> emit,
  ) async {
    if (isLoading) return;
    isLoading = true;
    emit(ProductCategoryScreenInitialState());
    try {
      var url = AppConfig.instance.apiUri(ApiEndpoints.productListCate);
      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(res.body));
        List<ProductCategory> newListProductModel = List<ProductCategory>.from(
          l["data"].map((model) => ProductCategory.fromJson(model)),
        );
        listProductCategoryModel.clear();
        listProductCategoryModel.addAll(newListProductModel);
        isLoading = false;
      }
    } catch (exception) {
      LoggerUtil.error("--- LIST CATEGORY PRODUCTS ERROR--- \n$exception");
    }

    // final res = await apiRepository.getProductCategory();
    // isLoading = false;
    // if (res.status == HttpStatus.ok && res.data != null) {
    //   res.data!.removeWhere(
    //       (element) => element.product == null || element.product!.isEmpty);
    //   listProductCategory = res.data!;
    // }
    emit(ProductCategoryScreenInitialState());
  }

  // int getItemCountChildProduct(int index) {
  //   return listProductModel[index].product!.length <= 4
  //       ? listProductCategory[index].product!.length
  //       : 4;
  // }
}
