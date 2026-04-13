import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/product/product_view_more/product_view_more_screen_event.dart';
import 'package:socbay/blocs/product/product_view_more/product_view_more_screen_state.dart';
import 'package:socbay/data/model/product_category.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';

class ProductViewMoreScreenBloc
    extends Bloc<ProductViewMoreScreenEvent, ProductViewMoreScreenState> {
  ProductViewMoreScreenBloc({
    required this.apiRepository,
    required this.productCategory,
  }) : super(ProductViewMoreScreenInitialState()) {
    on<ProductViewMoreScreenStartedEvent>(_mapStartedEventToState);
  }

  final ApiRepository apiRepository;
  ProductCategory productCategory;
  bool isLoading = false;

  FutureOr<void> _mapStartedEventToState(
      ProductViewMoreScreenStartedEvent event,
      Emitter<ProductViewMoreScreenState> emit) async {
    isLoading = true;
    emit(ProductViewMoreScreenInitialState());
    final res =
        await apiRepository.getProductCategoryDetail(productCategory.id ?? -1);
    if (res.data != null && res.status == HttpStatus.ok) {
      productCategory = res.data!;
    }
    isLoading = false;
    emit(ProductViewMoreScreenInitialState());
  }
}
