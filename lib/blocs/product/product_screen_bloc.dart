import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/product/product_screen_event.dart';
import 'package:socbay/blocs/product/product_screen_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/api_endpoints.dart';
import 'package:socbay/data/model/product_model.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/utils/logger_util.dart';
import 'package:socbay/utils/auth_http.dart' as http;

class ProductScreenBloc extends Bloc<ProductScreenEvent, ProductScreenState> {
  final ApiRepository apiRepository;
  final Map<String, dynamic> args;
  bool isLoading = false;
  int offset = 0;
  List<ProductModel> listProductModel = [];

  ProductScreenBloc({required this.apiRepository, required this.args})
    : super(ProductScreenInitialState()) {
    on<ProductScreenGetProductCategoryEvent>(
      _mapGetProductCategoryEventToState,
    );
  }

  FutureOr<void> _mapGetProductCategoryEventToState(
    ProductScreenGetProductCategoryEvent event,
    Emitter<ProductScreenState> emit,
  ) async {
    // if (isLoading) return;
    isLoading = true;
    emit(ProductScreenInitialState());
    var categoryId = args.isNotEmpty ? args['cateId'] : null;
    try {
      var url = AppConfig.instance.apiUri(ApiEndpoints.productSearch, {
        'page': event.refresh ? "0" : offset.toString(),
        'cate': categoryId.toString(),
      });
      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(res.body));
        List<ProductModel> newListProductModel = List<ProductModel>.from(
          l["data"]["data"].map((model) => ProductModel.fromJson(model)),
        );
        event.refresh ? listProductModel.clear() : listProductModel;
        listProductModel.addAll(newListProductModel);
        offset = listProductModel.length;
        isLoading = false;
      }
    } catch (exception) {
      LoggerUtil.log(exception.toString());
    }
    emit(ProductScreenInitialState());
  }
}
