import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/product/product_detail_event.dart';
import 'package:socbay/blocs/product/product_detail_state.dart';
import 'package:socbay/data/model/product_model.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';

class ProductDetailScreenBloc
    extends Bloc<ProductDetailScreenEvent, ProductDetailScreenState> {
  ProductDetailScreenBloc({
    required this.product,
    required this.apiRepository,
  }) : super(ProductDetailScreenInitialState()) {
    on<ProductDetailScreenStartedEvent>(_mapStartedEventToState);
    on<ProductDetailScreenLikeProductEvent>(_mapLikeProductEventToState);
  }

  ProductModel product;
  final ApiRepository apiRepository;
  bool isLoading = false;

  FutureOr<void> _mapStartedEventToState(ProductDetailScreenStartedEvent event,
      Emitter<ProductDetailScreenState> emit) async {
    isLoading = true;
    emit(ProductDetailScreenInitialState());
    final res = await apiRepository.getProductDetail(product: product);
    if (res.data != null && res.status == HttpStatus.ok) {
      product = res.data!;
    }
    isLoading = false;
    emit(ProductDetailScreenInitialState());
  }

  FutureOr<void> _mapLikeProductEventToState(
      ProductDetailScreenLikeProductEvent event,
      Emitter<ProductDetailScreenState> emit) async {
    if (product.id == null) return;
    isLoading = true;
    emit(ProductDetailScreenInitialState());
    final res = await apiRepository.likeProduct(
        productId: product.id!, isLike: event.isLike);
    if (res.data != null && res.status == HttpStatus.ok) {
      product = res.data!;
    }
    isLoading = false;
    emit(ProductDetailScreenInitialState());
  }
}
