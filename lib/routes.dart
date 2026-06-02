import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/auth/forgot_password/forgot_password_screen_bloc.dart';
import 'package:socbay/blocs/auth/new_password/new_password_screen_bloc.dart';
import 'package:socbay/blocs/auth/verify_otp/verify_otp_screen_bloc.dart';
import 'package:socbay/blocs/booking/detail_booking/detail_booking_bloc.dart';
import 'package:socbay/blocs/booking/detail_booking/detail_rent_booking_bloc.dart';
import 'package:socbay/blocs/home/choose_favourite_staff/choose_favourite_staff_bloc.dart';
import 'package:socbay/blocs/home/edit_service/edit_rent_service_bloc.dart';
import 'package:socbay/blocs/home/edit_service/edit_service_bloc.dart';
import 'package:socbay/blocs/home/feedback/feedback_screen_bloc.dart';
import 'package:socbay/blocs/home/news/news_screen_bloc.dart';
import 'package:socbay/blocs/home/service/service_screen_bloc.dart';
import 'package:socbay/blocs/home/staff_info/staff_info_screen_bloc.dart';
import 'package:socbay/blocs/machine/core_replacement_service/core_replacement_service_bloc.dart';
import 'package:socbay/blocs/machine/machine_detail/machine_detail_bloc.dart';
import 'package:socbay/blocs/product/product_detail_bloc.dart';
import 'package:socbay/blocs/product/product_view_more/product_view_more_screen_bloc.dart';
import 'package:socbay/blocs/product_category/product_category_bloc.dart';
import 'package:socbay/blocs/staff/comment_and_rating_list/comment_and_rating_list_bloc.dart';
import 'package:socbay/blocs/staff/new_order/staff_new_order_bloc.dart';
import 'package:socbay/blocs/staff/new_order/staff_new_rent_order_bloc.dart';
import 'package:socbay/blocs/staff/new_task/staff_service_screen_bloc.dart';
import 'package:socbay/blocs/staff/new_task_sale/staff_service_screen_sale_bloc.dart';
import 'package:socbay/blocs/staff/order/order_manager_bloc.dart';
import 'package:socbay/blocs/user_info/account_info/account_info_bloc.dart';
import 'package:socbay/blocs/user_info/change_password/change_password_screen_bloc.dart';
import 'package:socbay/blocs/user_info/favourite_product/favourite_product_bloc.dart';
import 'package:socbay/blocs/user_info/favourite_staff/favourite_staff_bloc.dart';
import 'package:socbay/blocs/user_info/gift/gift_screen_bloc.dart';
import 'package:socbay/blocs/user_info/update_staff/update_staff_screen_bloc.dart';
import 'package:socbay/blocs/user_info/user_address/user_address_screen_bloc.dart';
import 'package:socbay/blocs/user_info/user_new_order/user_new_order_bloc.dart';
import 'package:socbay/blocs/user_info/user_screen_bloc.dart';
import 'package:socbay/data/model/bill_data.dart';
import 'package:socbay/data/model/blog_model.dart';
import 'package:socbay/data/model/notification_response.dart';
import 'package:socbay/data/model/product_category.dart';
import 'package:socbay/data/model/product_model.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/root.dart';
import 'package:socbay/screens/booking/detail_rent_booking_screen.dart';
import 'package:socbay/screens/feedback/feedback_list_screen.dart';
import 'package:socbay/screens/feedback/feedback_screen.dart';
import 'package:socbay/screens/auth/forgot_password_screen.dart';
import 'package:socbay/screens/auth/new_password_screen.dart';
import 'package:socbay/screens/auth/register_screen.dart';
import 'package:socbay/screens/auth/verify_otp_screen.dart';
import 'package:socbay/screens/booking/core_replacement_service_screen.dart';
import 'package:socbay/screens/booking/detail_booking_screen.dart';
import 'package:socbay/screens/commenttechnique/commenttechnique_screen.dart';
import 'package:socbay/screens/evaluate/evaluate_screen.dart';
import 'package:socbay/screens/historyidC/historyidC_screen.dart';
import 'package:socbay/screens/home/choose_favourite_staff_screen.dart';
import 'package:socbay/screens/home/edit_rent_service_screen.dart';
import 'package:socbay/screens/home/edit_service_screen.dart';
import 'package:socbay/screens/home/feedback_detail_screen.dart';
import 'package:socbay/screens/home/feedback_screen.dart';
import 'package:socbay/screens/home/hotline_screen.dart';
import 'package:socbay/screens/home/new_detail_screen.dart';
import 'package:socbay/screens/home/news_screen.dart';
import 'package:socbay/screens/home/search_staff_screen.dart';
import 'package:socbay/screens/home/service_screen.dart';
import 'package:socbay/screens/home/staff_info_screen.dart';
import 'package:socbay/screens/map_screen.dart';
import 'package:socbay/screens/notification/notification_detail_screen.dart';
import 'package:socbay/screens/notification/notification_screen.dart';
import 'package:socbay/screens/machines/machine_detail_screen.dart';
import 'package:socbay/screens/machines/machine_screen.dart';
import 'package:socbay/screens/machines/machine_view_more_screen.dart';
import 'package:socbay/screens/product_category/product_category_screen.dart';
import 'package:socbay/screens/products/product_detail_screen.dart';
import 'package:socbay/screens/staff/customer_information/customer_information_list_screen.dart';
import 'package:socbay/screens/staff/feedback/staff_feedback_screen.dart';
import 'package:socbay/screens/staff/new_order/bill_screen.dart';
import 'package:socbay/screens/staff/new_order/new_rent_order_screen.dart';
import 'package:socbay/screens/staff/new_order/staff_new_order_screen.dart';
import 'package:socbay/screens/staff/new_task/staff_service_screen.dart';
import 'package:socbay/screens/staff/new_task/staff_service_screen_sale.dart';
import 'package:socbay/screens/staff/profile/staff_profile_screen.dart';
import 'package:socbay/screens/user/account_info_screen.dart';
import 'package:socbay/screens/user/address/add_user_address_screen.dart';
import 'package:socbay/screens/user/change_password_screen.dart';
import 'package:socbay/screens/user/favourite_product_screen.dart';
import 'package:socbay/screens/user/favourite_staff_screen.dart';
import 'package:socbay/screens/user/gift_detail_screen.dart';
import 'package:socbay/screens/user/gift_screen.dart';
import 'package:socbay/screens/user/new_order_screen.dart';
import 'package:socbay/screens/user/update_staff_screen.dart';
import 'package:socbay/screens/user/address/user_address_screen.dart';
import 'package:socbay/screens/user/user_profile_screen.dart';

import 'blocs/comment_technique/comment_technique_bloc.dart';
import 'blocs/historyidC/historyidC_screen_bloc.dart';
import 'blocs/home/feedbackid/feedbackid_screen_bloc.dart';
import 'blocs/home/hotline/hotline_screen_bloc.dart';
import 'blocs/home/search_staff/search_staff_screen_bloc.dart';
import 'blocs/product/product_screen_bloc.dart';
import 'blocs/technique/technique_screen_bloc.dart';
import 'blocs/user_Information/customer_information_list_bloc.dart';
import 'blocs/user_info/notification/notification_screen_bloc.dart';
import 'screens/staff/comment_and_rating/comment_and_rating_list_screen.dart';
import 'screens/staff/feedback/staff_feedback_detail_screen.dart';
import 'screens/staff/order_manager/order_mng_screen.dart';

import 'blocs/staff/order/order_manager_bloc_bySale.dart';
import 'screens/staff/order_manager/order_mng_screen_bySale.dart';

class Routes {
  static const String root = '/';

  static const String userNewOrderScreen = '/userNewOrderScreen';

  static const String userProfileScreen = '/userProfileScreen';
  static const String staffProfileScreen = '/staffProfileScreen';
  static const String accountInfoScreen = '/accountInfoScreen';
  static const String notificationScreen = '/notificationScreen';
  static const String notificationDetailScreen = '/notificationDetailScreen';
  static const String giftScreen = '/giftScreen';
  static const String favouriteProduct = '/favouriteProduct';
  static const String favouriteStaff = '/favouriteStaff';
  static const String productDetail = '/productDetail';
  static const String machineDetail = '/machineDetail';
  static const String register = '/register';
  static const String verifyOTP = '/verifyOTP';
  static const String productScreen = '/productScreen';
  static const String productViewMoreScreen = '/productViewMoreScreen';
  static const String newsScreen = '/newsScreen';
  static const String newDetail = '/newDetail';
  static const String giftDetail = '/giftDetail';
  static const String updateStaffScreen = '/updateStaffScreen';
  static const String changePasswordScreen = '/changePasswordScreen';
  static const String forgotPasswordScreen = '/forgotPasswordScreen';
  static const String newPasswordScreen = '/newPasswordScreen';
  static const String feedbackScreen = '/feedbackScreen';
  static const String staffFeedbackScreen = '/staffFeedbackScreen';
  static const String serviceScreen = '/serviceScreen';
  static const String mapScreen = '/mapScreen';
  static const String chooseFavouriteStaffScreen =
      '/chooseFavouriteStaffScreen';
  static const String searchStaffScreen = '/searchStaffScreen';
  static const String hotlineScreen = '/hotlineScreen';
  static const String techniqueScreen = '/techniqueScreen';
  static const String staffInfoScreen = '/staffInfoScreen';
  static const String editServiceScreen = '/editServiceScreen';
  static const String editRentServiceScreen = '/editRentServiceScreen';
  static const String userAddressScreen = '/userAddressScreen';
  static const String addUserAddressScreen = '/addUserAddressScreen';
  static const String detailBookingScreen = '/detailBookingScreen';
  static const String detailRentBookingScreen = '/detailRentBookingScreen';
  // static const String detailTaskProcessedScreen = '/detailTaskProcessed';
  static const String productCategoryScreen = '/productCategoryScreen';
  static const String coreReplacementServiceScreen = '/coreReplatementService';
  static const String staffCommentAndRatingList = '/CommentAndRatingList';
  static const String orderManagerScreen = '/OrderManagerScreen';
  static const String staffServiceScreen = '/staffServiceScreen';
  static const String createOrderScreen = '/createOrderScreen';
  static const String createRentOrderScreen = '/createRentOrderScreen';
  static const String billScreen = '/BillScreen';
  static const String detailFeedBackScreen = '/detailFeedbackScreen';
  static const String histoyridCScreen = '/histoyridCScreen';
  static const String staffDetailFeedBackScreen = '/staffDetailFeedbackScreen';
  static const String staffCustomerInformationList =
      '/CustomerInformationList'; //
  static const String evaluateScreen = '/evaluateScreen';
  static const String staffCommentTechniqueList = '/staffCommentTechniqueList';
  static const String feedbackkScreen = '/feedbackkScreen';
  static const String staffFeedbackListScreen = '/staffFeedbackListScreen';
  static const String staffServiceScreenSale = '/staffServiceScreenSale';
  // static const String rentBookingServiceScreen = '/rentBookingServiceScreen';
  static const String orderManagerScreenBySale = '/orderManagerScreenBySale';
  CupertinoPageRoute routePage(RouteSettings settings) {
    return CupertinoPageRoute(
      settings: settings,
      builder: (BuildContext context) {
        final ApiRepository apiRepository =
            RepositoryProvider.of<ApiRepository>(context);
        switch (settings.name) {
          case root:
            return const Root();
          case userProfileScreen:
            return BlocProvider<UserScreenBloc>(
              create: (context) => UserScreenBloc(apiRepository: apiRepository),
              child: const UserProfileScreen(),
            );
          case accountInfoScreen:
            return BlocProvider<AccountInfoBloc>(
              create: (context) =>
                  AccountInfoBloc(apiRepository: apiRepository),
              child: const AccountInfoScreen(),
            );

          case userNewOrderScreen:
            return BlocProvider<UserNewOrderBloc>(
              create: (ctx) => UserNewOrderBloc(
                apiRepository: apiRepository,
                // args: settings.arguments as Map<String, dynamic>
              ),
              child: const UserNewOrderScreen(),
            );

          case notificationScreen:
            return BlocProvider<NotificationScreenBloc>(
              create: (context) =>
                  NotificationScreenBloc(apiRepository: apiRepository),
              child: const NotificationScreen(),
            );
          case notificationDetailScreen:
            return NotificationDetailScreen(
              notificationResponse: settings.arguments as NotificationResponse,
            );
          case giftScreen:
            return BlocProvider<GiftScreenBloc>(
              create: (context) => GiftScreenBloc(apiRepository: apiRepository),
              child: const GiftScreen(),
            );
          case favouriteProduct:
            return BlocProvider<FavouriteProductScreenBloc>(
              create: (context) =>
                  FavouriteProductScreenBloc(apiRepository: apiRepository),
              child: const FavouriteProductScreen(),
            );
          case favouriteStaff:
            return BlocProvider<FavouriteStaffBloc>(
              create: (context) =>
                  FavouriteStaffBloc(apiRepository: apiRepository),
              child: const FavouriteStaffScreen(),
            );

          case productDetail:
            return BlocProvider<ProductDetailScreenBloc>(
              create: (context) => ProductDetailScreenBloc(
                apiRepository: apiRepository,
                product: settings.arguments as ProductModel,
              ),
              child: const ProductDetailScreen(),
            );
          case machineDetail:
            return BlocProvider<MachineDetailScreenBloc>(
              create: (context) => MachineDetailScreenBloc(
                apiRepository: apiRepository,
                args: settings.arguments as Map<String, dynamic>,
              ),
              child: const MachineDetailScreen(),
            );
          case register:
            return const RegisterScreen();
          case verifyOTP:
            return BlocProvider<VerifyOtpScreenBloc>(
              create: (context) => VerifyOtpScreenBloc(
                apiRepository: apiRepository,
                args: settings.arguments as Map<String, dynamic>,
              ),
              child: const VerifyOTPScreen(userData: {}),
            );
          case productScreen:
            return BlocProvider<ProductScreenBloc>(
              create: (context) => ProductScreenBloc(
                apiRepository: apiRepository,
                args: settings.arguments as Map<String, dynamic>,
              ),
              child: ProductScreen(
                args: settings.arguments as Map<String, dynamic>,
              ),
            );
          case productCategoryScreen:
            return BlocProvider<ProductCategoryScreenBloc>(
              create: (context) =>
                  ProductCategoryScreenBloc(apiRepository: apiRepository),
              child: const ProductCategoryScreen(),
            );
          case productViewMoreScreen:
            return BlocProvider<ProductViewMoreScreenBloc>(
              create: (context) => ProductViewMoreScreenBloc(
                apiRepository: apiRepository,
                productCategory: settings.arguments as ProductCategory,
              ),
              child: const ProductViewMoreScreen(),
            );
          case newsScreen:
            return BlocProvider<NewsScreenBloc>(
              create: (context) => NewsScreenBloc(apiRepository: apiRepository),
              child: const NewsScreen(),
            );
          case newDetail:
            return NewDetailScreen(blogModel: settings.arguments as BlogModel);
          case giftDetail:
            return GiftDetailScreen(
              args: settings.arguments as Map<String, dynamic>,
            );
          case updateStaffScreen:
            return BlocProvider<UpdateStaffScreenBloc>(
              create: (context) =>
                  UpdateStaffScreenBloc(apiRepository: apiRepository),
              child: const UpdateStaffScreen(),
            );
          case changePasswordScreen:
            return BlocProvider<ChangePasswordScreenBloc>(
              create: (context) =>
                  ChangePasswordScreenBloc(apiRepository: apiRepository),
              child: const ChangePasswordScreen(),
            );
          case forgotPasswordScreen:
            return BlocProvider<ForgotPasswordScreenBloc>(
              create: (context) =>
                  ForgotPasswordScreenBloc(apiRepository: apiRepository),
              child: const ForgotPasswordScreen(),
            );
          case newPasswordScreen:
            return BlocProvider<NewPasswordScreenBloc>(
              create: (context) => NewPasswordScreenBloc(
                apiRepository: apiRepository,
                args: settings.arguments as Map<String, dynamic>,
              ),
              child: const NewPasswordScreen(),
            );
          case feedbackScreen:
            return BlocProvider<FeedbackScreenBloc>(
              create: (context) => FeedbackScreenBloc(
                apiRepository: apiRepository,
                args: settings.arguments as Map<String, dynamic>,
              ),
              child: const FeedbackScreen(),
            );
          case staffFeedbackScreen:
            return BlocProvider<FeedbackScreenBloc>(
              create: (context) => FeedbackScreenBloc(
                apiRepository: apiRepository,
                args: settings.arguments as Map<String, dynamic>,
              ),
              child: const StaffFeedbackScreen(),
            );
          case staffFeedbackListScreen:
            return BlocProvider<FeedbackScreenidBloc>(
              create: (context) => FeedbackScreenidBloc(
                apiRepository: apiRepository,
                args: settings.arguments as Map<String, dynamic>,
              ),
              child: const StaffFeedbackListScreen(),
            );
          case serviceScreen:
            return BlocProvider<ServiceScreenBloc>(
              create: (context) => ServiceScreenBloc(
                apiRepository: apiRepository,
                args: settings.arguments as Map<String, dynamic>,
              ),
              child: const ServiceScreen(),
            );
          case mapScreen:
            return const MapScreen();
          case chooseFavouriteStaffScreen:
            return BlocProvider<ChooseFavouriteStaffBloc>(
              create: (context) => ChooseFavouriteStaffBloc(
                apiRepository: apiRepository,
                args: settings.arguments as Map<String, dynamic>,
              ),
              child: const ChooseFavouriteStaffScreen(),
            );
          case searchStaffScreen:
            return BlocProvider<SearchStaffScreenBloc>(
              create: (context) => SearchStaffScreenBloc(
                apiRepository: apiRepository,
                args: settings.arguments as Map<String, dynamic>,
              ),
              child: const SearchStaffScreen(),
            );
          // case techniqueScreen:
          //   return BlocProvider<TechniqueScreenBloc>(
          //     create: (context) => TechniqueScreenBloc( apiRepository),
          //     child:const TechniqueScreen(),
          //   );
          case hotlineScreen:
            return BlocProvider<HotlineScreenBloc>(
              create: (context) => HotlineScreenBloc(apiRepository),
              child: const HotlineScreen(),
            );
          case staffCustomerInformationList:
            return BlocProvider<CustomerInformationListBloc>(
              create: (builderContext) =>
                  CustomerInformationListBloc(apiRepository),
              child: const CustomerInformationListScreen(),
            );
          case staffInfoScreen:
            return BlocProvider<StaffInfoScreenBloc>(
              create: (context) => StaffInfoScreenBloc(
                apiRepository: apiRepository,
                args: settings.arguments as Map<String, dynamic>,
              ),
              child: const StaffInfoScreen(),
            );
          case editServiceScreen:
            return BlocProvider<EditServiceBloc>(
              create: (ctx) => EditServiceBloc(
                apiRepository: apiRepository,
                args: settings.arguments as Map<String, dynamic>,
              ),
              child: EditServiceScreen(
                args: settings.arguments as Map<String, dynamic>,
              ),
            );
          case editRentServiceScreen:
            return BlocProvider<EditRentServiceBloc>(
              create: (ctx) => EditRentServiceBloc(
                apiRepository: apiRepository,
                args: settings.arguments as Map<String, dynamic>,
              ),
              child: EditRentServiceScreen(
                args: settings.arguments as Map<String, dynamic>,
              ),
            );
          case userAddressScreen:
            return BlocProvider<UserAddressScreenBloc>(
              create: (ctx) =>
                  UserAddressScreenBloc(apiRepository: apiRepository),
              child: const UserAddressScreen(),
            );
          case addUserAddressScreen:
            return BlocProvider<UserAddressScreenBloc>(
              create: (ctx) =>
                  UserAddressScreenBloc(apiRepository: apiRepository),
              child: AddUserAddressScreen(arguments: settings.arguments),
            );
          case detailBookingScreen:
            return BlocProvider<DetailBookingBloc>(
              create: (ctx) => DetailBookingBloc(
                apiRepository: apiRepository,
                args: settings.arguments as Map<String, dynamic>,
              ),
              child: const DetailBookingScreen(),
            );
          case detailRentBookingScreen:
            return BlocProvider<DetailRentBookingBloc>(
              create: (ctx) => DetailRentBookingBloc(
                apiRepository: apiRepository,
                args: settings.arguments as Map<String, dynamic>,
              ),
              child: const DetailRentBookingScreen(),
            );
          case coreReplacementServiceScreen:
            return BlocProvider<CoreReplacementServiceBloc>(
              create: (builderContext) => CoreReplacementServiceBloc(
                apiRepository: apiRepository,
                args: settings.arguments as Map<String, dynamic>,
              ),
              child: const CoreReplacementServiceScreen(),
            );
          case staffCommentAndRatingList:
            return BlocProvider<CommentAndRatingBloc>(
              create: (builderContext) =>
                  CommentAndRatingBloc(apiRepository: apiRepository),
              child: const CommentAndRatingListScreen(),
            );
          case staffCommentTechniqueList:
            return BlocProvider<CommentTechniqueBloc>(
              create: (builderContext) => CommentTechniqueBloc(
                apiRepository: apiRepository,
                args: settings.arguments as Map<String, dynamic>,
              ),
              child: const CommentTechniqueListScreen(),
            );
          case orderManagerScreen:
            return BlocProvider<OrderManagerBloc>(
              create: (builderContext) =>
                  OrderManagerBloc(apiRepository: apiRepository),
              child: const OrderManagerScreen(),
            );
          case histoyridCScreen:
            return BlocProvider<HistoryidCScreenBloc>(
              create: (ctx) => HistoryidCScreenBloc(
                apiRepository: apiRepository,
                args: settings.arguments as Map<String, dynamic>,
              ),
              child: const HistoryidCScreen(),
            );
          case staffServiceScreen:
            return BlocProvider<StaffServiceScreenBloc>(
              create: (context) => StaffServiceScreenBloc(
                apiRepository: apiRepository,
                args: settings.arguments as Map<String, dynamic>,
              ),
              child: const StaffServiceScreen(),
            );
          case staffServiceScreenSale:
            return BlocProvider<StaffServiceSaleScreenBloc>(
              create: (context) => StaffServiceSaleScreenBloc(
                apiRepository: apiRepository,
                args: settings.arguments as Map<String, dynamic>,
              ),
              child: const StaffServiceSaleScreen(),
            );
          // case rentBookingServiceScreen:
          //   return BlocProvider<StaffServiceSaleScreenBloc>(
          //     create: (context) => StaffServiceSaleScreenBloc(
          //       apiRepository: apiRepository,
          //       args: settings.arguments as Map<String, dynamic>,
          //     ),
          //     child: const StaffServiceSaleScreen(
          //       initialOrderType: TaskOrderType.rent,
          //     ),
          //   );
          case createOrderScreen:
            return BlocProvider<StaffNewOrderBloc>(
              create: (ctx) => StaffNewOrderBloc(
                apiRepository: apiRepository,
                args: settings.arguments as Map<String, dynamic>,
              ),
              child: const StaffNewOrderScreen(),
            );
          case createRentOrderScreen:
            return BlocProvider<StaffNewRentOrderBloc>(
              create: (ctx) => StaffNewRentOrderBloc(
                apiRepository: apiRepository,
                args: settings.arguments as Map<String, dynamic>,
              ),
              child: const StaffNewRentOrderScreen(),
            );
          case billScreen:
            return BlocProvider<StaffNewOrderBloc>(
              create: (context) =>
                  StaffNewOrderBloc(apiRepository: apiRepository, args: {}),
              child: BillScreen(billData: settings.arguments as BillData),
            );
          case staffDetailFeedBackScreen:
            return BlocProvider<FeedbackScreenBloc>(
              create: (context) => FeedbackScreenBloc(
                apiRepository: apiRepository,
                args: settings.arguments as Map<String, dynamic>,
              ),
              child: const StaffDetailFeedbackScreen(),
            );
          case detailFeedBackScreen:
            return BlocProvider<FeedbackScreenBloc>(
              create: (context) => FeedbackScreenBloc(
                apiRepository: apiRepository,
                args: settings.arguments as Map<String, dynamic>,
              ),
              child: const DetailFeedbackScreen(),
            );
          case staffProfileScreen:
            return BlocProvider<StaffInfoScreenBloc>(
              create: (context) => StaffInfoScreenBloc(
                apiRepository: apiRepository,
                args: settings.arguments as Map<String, dynamic>,
              ),
              child: const StaffProfileScreen(),
            );
          case evaluateScreen:
            return BlocProvider<TechniqueScreenBloc>(
              create: (builderContext) => TechniqueScreenBloc(
                apiRepository: apiRepository,
                args: settings.arguments as Map<String, dynamic>,
              ),
              child: const EvaluateScreen(),
            );
          case feedbackkScreen:
            return BlocProvider<TechniqueScreenBloc>(
              create: (builderContext) => TechniqueScreenBloc(
                apiRepository: apiRepository,
                args: settings.arguments as Map<String, dynamic>,
              ),
              child: const FeedbackkScreen(),
            );
          case orderManagerScreenBySale:
            return BlocProvider<OrderManagerBlocBySale>(
              create: (builderContext) =>
                  OrderManagerBlocBySale(apiRepository: apiRepository),
              child: const OrderManagerScreenBySale(),
            );
        }
        return const Scaffold();
      },
    );
  }
}
