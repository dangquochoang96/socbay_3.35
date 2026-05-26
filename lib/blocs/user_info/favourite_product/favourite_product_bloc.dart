import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/user_info/favourite_product/favourite_product_event.dart';
import 'package:socbay/blocs/user_info/favourite_product/favourite_product_state.dart';
import 'package:socbay/data/model/product_model.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';

class FavouriteProductScreenBloc
    extends Bloc<FavouriteProductEvent, FavouriteProductState> {
  FavouriteProductScreenBloc({required this.apiRepository})
    : super(FavouriteProductInitialState()) {
    on<FavouriteProductStartedEvent>(_mapStartedEventToState);
  }

  final ApiRepository apiRepository;
  List<ProductModel> listProduct = [];
  bool isLoading = false;
  FutureOr<void> _mapStartedEventToState(
    FavouriteProductStartedEvent event,
    Emitter<FavouriteProductState> emit,
  ) async {
    isLoading = true;
    emit(FavouriteProductInitialState());
    final res = await apiRepository.getProducts(isLike: 1);
    if (res.status == HttpStatus.ok && res.data != null) {
      listProduct = res.data!;
    }
    isLoading = false;
    emit(FavouriteProductInitialState());
  }
}
