import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:socbay/application.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/data_provider/api_endpoints.dart';
import 'package:socbay/data/model/banner_model.dart';
import 'package:socbay/data/model/blog_model.dart';
import 'package:socbay/data/model/home_service_model.dart';
import 'package:socbay/data/model/order_filter_core_model.dart';
import 'package:socbay/data/model/order_model.dart';
import 'package:socbay/data/model/product_model.dart';
import 'package:socbay/data/model/staff_sales_income_model.dart';
import 'package:socbay/data/model/user_model.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/utils/logger_util.dart';
import 'home_event.dart';
import 'home_state.dart';
import 'package:socbay/utils/auth_http.dart' as http;

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ApiRepository apiRepository;
  UserModel? user;
  List<OrderModel> lstMachine = [];
  List<BlogModel> blogs = [];
  List<ProductModel> products = [];
  List<BannerModel> banners = [];
  List<HomeServiceModel> services = [];
  List<HomeServiceModel> allServices = [];
  List<UserModel> favouriteStaffs = [];
  List<StaffSalesIncomeModel> staffSalesIncomes = [];
  List<OrderFilterCoreModel> orderFilterCore = [];
  bool isLoading = false;
  int totalOrderAll = 0;
  double totalPriceAll = 0;
  double totalChietKhauAll = 0;
  double totalTruTichDiem = 0;
  HomeBloc({required this.apiRepository}) : super(HomeInitialState()) {
    on<HomeStartedEvent>(_mapHomeStartedEventToState);
    on<HomeScreenGetUserProductEvent>(_mapGetProductsUsertoState);
    on<HomeScreenGetBlogsEvent>(_mapGetBlogsToState);
    on<HomeScreenGetListServiceEvent>(_mapGetListServiceEventToState);
    on<HomeScreenGetListBannerEvent>(_mapGetBannerEventToState);
    // on<HomeScreenGetProductsEvent>(_mapGetProductsEventToState);
  }

  FutureOr<void> _mapHomeStartedEventToState(
    HomeStartedEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (isLoading) return;
    isLoading = true;
    emit(HomeInitialState());
    user = App.instance.userApp;
    if (!(App.instance.userApp?.isUserCustomer() == true)) {
      await _mapGetSalesIncome();
    }
    await Future.wait([
      _mapGetProductsUsertoState(null, emit),
      _mapGetBlogsToState(null, emit),
      _mapGetListServiceEventToState(null, emit),
      _mapGetBannerEventToState(null, emit),
      // _mapGetProductsEventToState(null, emit),
      _mapGetLastReplaceFilterCore(),
    ]).then((value) {
      isLoading = false;
      emit(HomeInitialState());
    });
  }

  Future<void> _mapGetProductsUsertoState(
    HomeScreenGetUserProductEvent? event,
    Emitter<HomeState> emit,
  ) async {
    try {
      var url = AppConfig.instance.apiUri(
        ApiEndpoints.userProducts(App.instance.userApp?.id.toString()),
      );
      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(res.body));
        var m = Map<String, dynamic>.from(l["data"]);
        lstMachine = List<OrderModel>.from(
          m["listProducts"].map((model) => OrderModel.fromJson(model)),
        );
      }
    } catch (exception) {
      LoggerUtil.log(exception.toString());
    }
  }

  Future<void> _mapGetSalesIncome() async {
    try {
      var url = AppConfig.instance.apiUri(
        ApiEndpoints.orderSalesIncome(App.instance.userApp?.id),
      );
      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(res.body));
        staffSalesIncomes = List<StaffSalesIncomeModel>.from(
          l["data"].map((model) => StaffSalesIncomeModel.fromJson(model)),
        );
        totalOrderAll = 0;
        totalPriceAll = 0;
        totalChietKhauAll = 0;
        totalTruTichDiem = 0;
        for (var e in staffSalesIncomes) {
          if (e.status == '2') {
            totalPriceAll = totalPriceAll + double.parse(e.totalPrice ?? "0");
            totalChietKhauAll =
                totalChietKhauAll + double.parse(e.totalChietKhau ?? "0");
            totalTruTichDiem =
                totalTruTichDiem + int.parse(e.totalTruTichDiem ?? "0");
          }
          totalOrderAll = totalOrderAll + int.parse(e.totalOrder ?? "0");
        }
        totalPriceAll =
            totalPriceAll - totalTruTichDiem * 1000 - totalChietKhauAll;
        //print(blogs);
      }
    } catch (ex) {
      LoggerUtil.error(ex.toString());
    }
  }

  Future<void> _mapGetBlogsToState(
    HomeScreenGetBlogsEvent? event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final url = Uri.parse(
        ApiEndpoints.geyserBlogs,
      ).replace(queryParameters: {'page': '1'});
      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(
          json.decode(utf8.decode(res.bodyBytes)),
        );
        final data = Map<String, dynamic>.from(l["data"]);
        blogs = List<BlogModel>.from(
          data["data"].map((model) => BlogModel.fromJson(model)),
        );
      }
    } catch (ex) {
      LoggerUtil.error(ex.toString());
    }
  }

  Future<void> _mapGetListServiceEventToState(
    HomeScreenGetListServiceEvent? event,
    Emitter<HomeState> emit,
  ) async {
    allServices = App.instance.userApp!.isUserCustomer()
        ? HomeServiceModel.serviceList
        : App.instance.userApp!.isUserRole()
        ? HomeServiceModel.staffServiceList
        : HomeServiceModel.staffServiceListSale;
  }

  Future<void> _mapGetBannerEventToState(
    HomeScreenGetListBannerEvent? event,
    Emitter<HomeState> emit,
  ) async {
    final res = await apiRepository.getBanners();
    if (res.status == HttpStatus.ok && res.data != null) {
      banners = res.data!;
    }
  }

  // Future<void> _mapGetProductsEventToState(
  //     HomeScreenGetProductsEvent? event, Emitter<HomeState> emit) async {
  //   try {
  //     var url = Uri.http(
  //         AppConfig.instance.values.apiUrl, "/api/product/list", {'page': "0"});
  //     var res = await http.get(url);
  //     if (res.statusCode == HttpStatus.ok) {
  //       var l = Map<String, dynamic>.from(json.decode(res.body));
  //       products = List<ProductModel>.from(
  //           l["data"].map((model) => ProductModel.fromJson(model)));
  //     }
  //   } catch (ex) {
  //     LoggerUtil.error(ex.toString());
  //   }
  // }

  Future<void> _mapGetLastReplaceFilterCore() async {
    try {
      var url = AppConfig.instance.apiUri(
        ApiEndpoints.orderLastReplaceFilterCore(App.instance.userApp?.id),
      );
      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = json.decode(res.body) as Map<String, dynamic>;
        orderFilterCore = (l["data"] as List)
            .map((model) => OrderFilterCoreModel.fromJson(model))
            .toList()
            .cast<OrderFilterCoreModel>();
      }
    } catch (ex) {
      LoggerUtil.error(ex.toString());
    }
  }
}
