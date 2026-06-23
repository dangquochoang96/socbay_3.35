// ignore_for_file: constant_identifier_names

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_format_money_vietnam/flutter_format_money_vietnam.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/machine/core_replacement_service/core_replacement_service_bloc.dart';
import 'package:socbay/blocs/machine/core_replacement_service/core_replacement_service_event.dart';
import 'package:socbay/blocs/machine/core_replacement_service/core_replacement_service_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/model/user_model.dart';
import 'package:socbay/onepay_paygate/onepay_paygate_flutter.dart';
import 'package:socbay/paths/images.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:socbay/widgets/text_field_default.dart';

class CoreReplacementServiceScreen extends StatefulWidget {
  const CoreReplacementServiceScreen({super.key});

  @override
  State<CoreReplacementServiceScreen> createState() =>
      _CoreReplacementServiceScreenState();
}

class _CoreReplacementServiceScreenState
    extends State<CoreReplacementServiceScreen> {
  late CoreReplacementServiceBloc _bloc;
  final _isVertical = false;
  IconData? _selectedIcon;
  late double _rating;
  late TextEditingController _feedbackController;
  late TextEditingController _validateRatingController;
  // ignore: prefer_typing_uninitialized_variables
  late dynamic _totalPriced;

  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    _bloc.add(CoreReplatementServiceStartEvent());
    _rating = _bloc.rating;
    _feedbackController = TextEditingController();
    _validateRatingController = TextEditingController();
    _validateRatingController.text = "";
    super.initState();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _validateRatingController.dispose();
    super.dispose();
  }

  void _createPayment() {
    final amount = _totalPriced?.toString();
    if (amount == null) {
      return;
    }
    //Môi trường Test
    // var ACCESS_CODE_PAYGATE = "6BEB2546"; // Onepay send for merchant
    // var MERCHANT_PAYGATE = "TESTONEPAY"; //  Merchant register with onepay
    // var HASH_KEY = "6D0870CDE5F24F34F3915FB0045120DB"; // Onepay send for merchant
    // var URL_SCHEMES = "merchantappscheme"; // get CFBundleURLSchemes in Info.plist
    const ACCESS_CODE_PAYGATE = "A2905C04";
    const MERCHANT_PAYGATE = "OP_SHOMEAPP";
    const HASH_KEY = "6C6F8CF98A8C9C37214E613411F3E3A1";
    const URL_SCHEMES = "merchantappscheme";

    var entity = OPPaymentEntity(
      amount: double.parse(amount),
      orderInformation: "${App.instance.userApp?.phone}",
      currency: OnepayCurrency.vnd,
      accessCode: ACCESS_CODE_PAYGATE,
      merchant: MERCHANT_PAYGATE,
      hashKey: HASH_KEY,
      urlSchemes: URL_SCHEMES,
    );
    OnePayPaygate.open(
      context: context,
      entity: entity,
      onPayResult: (OPPaymentResult result) {
        if (result.isSuccess) {
          setState(() {
            _bloc.add(
              OrderPaymentStatusUpdatedEvent(_bloc.orderDetailModel!.id!),
            );
          });
          showDialog(
            context: context,
            builder: (context) => const AlertDialog(
              title: Text("Thông báo"),
              content: Text("Thanh toán thành công"),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Thông báo"),
              content: Text(result.message ?? "Thanh toán không thành công"),
            ),
          );
        }
      },
      onPayFail: (error) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Lỗi"),
            content: Text(error.errorCase.name),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      CoreReplacementServiceBloc,
      CoreReplatementServiceState
    >(builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, CoreReplatementServiceState state) {}

  Widget _builder(BuildContext context, CoreReplatementServiceState state) {
    final hasData = _hasData;
    if (_bloc.isLoading) {
      return Scaffold(
        appBar: MyAppBar(
          title: "Chi tiết lần thay lõi",
          isBackNavigation: true,
          centerTitle: true,
        ),
        body: const SafeArea(
          child: LoadingIndicator(isLoading: true, child: SizedBox.expand()),
        ),
      );
    }

    if (!hasData) {
      return Scaffold(
        appBar: MyAppBar(
          title: "Chi tiết lần thay lõi",
          isBackNavigation: true,
          centerTitle: true,
        ),
        body: SafeArea(child: _buildEmptyState()),
      );
    }

    final isCustomer = App.instance.userApp?.isUserCustomer() == true;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: MyAppBar(
        title: "Chi tiết lần thay lõi",
        isBackNavigation: true,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16).copyWith(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStaffInfoCard(),
              _buildActionCard(),
              _buildPriceCard(),
              if (_bloc.orderDetailModel?.orderFilterCoresModel != null &&
                  _bloc.orderDetailModel!.orderFilterCoresModel!.any(
                    (item) => item.replaceDatePromise != "",
                  ))
                _buildUpdateCard(),
              _buildReviewCard(),
              if (_bloc.orderDetailModel?.images != null &&
                  _bloc.orderDetailModel!.images!.isNotEmpty)
                _buildMediaCard(),
              if (_bloc.orderDetailModel?.paymentStatus == '1') ...[
                const SizedBox(height: 16),
                Center(
                  child: ImageUtil.loadAssetsImage(
                    fileName: Images.successPayment,
                    width: 150,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: isCustomer ? _buildFloatingBookingButton() : null,
      bottomNavigationBar: _showBottomSheetFeedback(),
    );
  }

  bool get _hasData {
    final coreModels = _bloc.orderDetailModel?.orderFilterCoresModel;
    return _bloc.orderDetailModel != null &&
        coreModels != null &&
        coreModels.isNotEmpty;
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "Không có dữ liệu",
        style: TextStyle(fontSize: 16, color: Colors.black54),
      ),
    );
  }

  Widget _buildFloatingBookingButton() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: ColorUtil.green,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorUtil.green.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.serviceScreen,
              arguments: {
                "listService": [],
                "index": "",
                "productId": _bloc
                    .orderDetailModel
                    ?.orderFilterCoresModel?[0]
                    .orderDetailId,
              },
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_circle_outline_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: 6),
                Text(
                  "Đặt lịch",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _showBottomSheetFeedback() {
    if (App.instance.userApp?.isUserCustomer() == true) {
      final hasPayment = _bloc.orderDetailModel?.paymentStatus == '0';

      return SafeArea(
        bottom: true,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
            border: Border(top: BorderSide(color: Colors.grey.shade100)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      Routes.feedbackScreen,
                      arguments: {
                        "fbId": "0",
                        "orderId": _bloc.orderDetailModel?.id.toString() ?? "",
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.feedback_outlined,
                    color: ColorUtil.brightYellow,
                    size: 16,
                  ),
                  label: const Text(
                    "Khiếu nại",
                    style: TextStyle(
                      color: ColorUtil.brightYellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(
                      color: ColorUtil.brightYellow,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              if (hasPayment) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _createPayment,
                    icon: const Icon(
                      Icons.payment_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    label: const Text(
                      "Thanh toán",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorUtil.red,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _buildCard({
    required String title,
    required Widget child,
    IconData? icon,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: ColorUtil.bangladeshGreen.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: ColorUtil.bangladeshGreen, size: 20),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColorUtil.bangladeshGreen,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: valueColor ?? ColorUtil.raisinBlack,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffInfoCard() {
    var staffName = _bloc.orderDetailModel?.staff != null
        ? _bloc.orderDetailModel?.staff?.username
        : '';
    return _buildCard(
      title: "Thông tin kỹ thuật viên",
      icon: Icons.person_outline,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorUtil.bangladeshGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.engineering_outlined,
              color: ColorUtil.bangladeshGreen,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Kỹ thuật viên phụ trách",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    _goToStaffInfo(_bloc.orderDetailModel?.staff);
                  },
                  child: Text(
                    staffName ?? 'Không có thông tin',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: ColorUtil.bangladeshGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildActionCard() {
    return _buildCard(
      title: "Thông tin lõi thay",
      icon: Icons.water_drop_outlined,
      child: Column(
        children: [
          if (_bloc.orderDetailModel?.orderFilterCoresModel != null)
            for (var item in _bloc.orderDetailModel!.orderFilterCoresModel!)
              if (!(item.price == "0.00" && item.replaceDatePromise != ""))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.name ?? "",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          (item.price ?? "0")
                              .substring(
                                0,
                                (item.price ?? "0").contains(".")
                                    ? (item.price ?? "0").indexOf(".")
                                    : null,
                              )
                              .toString()
                              .toVND(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: ColorUtil.red,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildPriceCard() {
    var sumPrice = _bloc.totalPriceForOrder;
    var totalPrice = _bloc.orderDetailModel?.price;
    var discount = _bloc.orderDetailModel?.chietKhau;
    var subPoint = _bloc.orderDetailModel?.truTichDiem;
    var savePoint = _bloc.orderDetailModel?.tichDiem;
    Decimal heso = Decimal.parse("1000");
    var cal =
        (Decimal.parse(totalPrice ?? "0") -
        Decimal.parse(subPoint ?? "0") * heso -
        Decimal.parse(discount ?? "0"));
    _totalPriced = cal > Decimal.parse("0") ? cal : 0;
    if (_totalPriced == 0) {
      _bloc.orderDetailModel?.paymentStatus == '1';
    }

    return _buildCard(
      title: "Chi tiết thanh toán",
      icon: Icons.receipt_long_outlined,
      child: Column(
        children: [
          _buildInfoRow("Ngày thực hiện:", _bloc.createDate),
          _buildInfoRow("Tổng tiền:", (sumPrice.toInt()).toString().toVND()),
          _buildInfoRow(
            "Thuế VAT:",
            (_bloc.orderDetailModel?.vatAmount != null)
                ? '${_bloc.orderDetailModel?.vatAmount}%'
                : '',
          ),
          _buildInfoRow("Chiết khấu:", (discount ?? '0').toString().toVND()),
          _buildInfoRow(
            "Trừ tích điểm:",
            (Decimal.parse(subPoint ?? "0") * heso).toString().toVND(),
          ),
          const Divider(height: 24, color: Color(0xFFEFEFEF)),
          _buildInfoRow(
            "Tổng thanh toán:",
            _totalPriced.toString().toVND(),
            valueColor: ColorUtil.brightYellow,
            isBold: true,
          ),
          if (_bloc.orderDetailModel?.type == '2')
            _buildInfoRow(
              "Tích điểm:",
              savePoint ?? "0",
              valueColor: ColorUtil.bangladeshGreen,
              isBold: true,
            ),
        ],
      ),
    );
  }

  Widget _buildUpdateCard() {
    return _buildCard(
      title: "Lịch thay lõi tiếp theo",
      icon: Icons.event_repeat_outlined,
      child: Column(
        children: [
          if (_bloc.orderDetailModel?.orderFilterCoresModel != null)
            for (var item in _bloc.orderDetailModel!.orderFilterCoresModel!)
              if (item.replaceDatePromise != "")
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.name ?? "",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.replaceDatePromise ?? "",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: ColorUtil.bangladeshGreen,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildReviewCard() {
    Widget trailingReviewBtn =
        (_bloc.rating != 0 ||
            _bloc.des != "" ||
            App.instance.userApp?.isUserCustomer() == false)
        ? const SizedBox()
        : IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.rate_review_outlined, size: 20),
            color: ColorUtil.brightYellow,
            onPressed: () {
              _ratingAndNote();
            },
          );

    return _buildCard(
      title: "Đánh giá dịch vụ",
      icon: Icons.star_border_outlined,
      trailing: trailingReviewBtn,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ratingBarDisplay(),
          if (_bloc.des.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                _bloc.des,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ] else if (_bloc.rating == 0 &&
              App.instance.userApp?.isUserCustomer() == true) ...[
            const SizedBox(height: 12),
            const Text(
              "Bạn chưa có đánh giá nào cho dịch vụ này.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMediaCard() {
    return _buildCard(
      title: "Hình ảnh đơn hàng",
      icon: Icons.image_outlined,
      child: SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _bloc.orderDetailModel!.images?.length ?? 0,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    children: [
                      _fullScreenHeroWidget(
                        "$protocol${AppConfig.instance.values.apiUrl}/${_bloc.orderDetailModel!.images![index]}",
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _ratingBar() {
    return RatingBar.builder(
      initialRating: _bloc.rating,
      minRating: 1,
      direction: _isVertical ? Axis.vertical : Axis.horizontal,
      allowHalfRating: true,
      unratedColor: Colors.amber.withAlpha(50),
      itemCount: 5,
      itemSize: 30.0,
      itemPadding: const EdgeInsets.symmetric(horizontal: 0.0),
      itemBuilder: (context, _) =>
          Icon(_selectedIcon ?? Icons.star, color: Colors.amber),
      onRatingUpdate: (rating) {
        setState(() {
          _rating = rating;
        });
      },
      updateOnDrag: true,
      tapOnlyMode: true,
    );
  }

  Widget _ratingBarDisplay() {
    return RatingBarIndicator(
      rating: _bloc.rating,
      direction: _isVertical ? Axis.vertical : Axis.horizontal,
      unratedColor: Colors.amber.withAlpha(50),
      itemCount: 5,
      itemSize: 30.0,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) =>
          Icon(_selectedIcon ?? Icons.star, color: Colors.amber),
    );
  }

  Future<void> _ratingAndNote() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          title: const Text(
            'Đánh giá và nhận xét',
            textAlign: TextAlign.center,
          ),
          content: Column(
            children: [
              _ratingBar(),
              TextFieldDefault(controller: _feedbackController, maxLines: 3),
              if (_validateRatingController.text != "")
                Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: TextField(
                    controller: _validateRatingController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildButtonDialog(
                  isPositive: false,
                  text: 'Hủy',
                  action: () {
                    Navigator.pop(context);
                    _feedbackController.clear();
                  },
                ),
                const SizedBox(width: 16),
                _buildButtonDialog(
                  isPositive: true,
                  text: 'Gửi',
                  action: () {
                    if (_feedbackController.text == "" || _rating == 0) {
                      context.showSnackBarError(
                        "Vui lòng nhập đầy đủ thông tin đánh giá!",
                      );
                      return;
                    }
                    _bloc.add(
                      OrderFeedbackTaskProcessedEvent(
                        _bloc.orderDetailModel!.id!,
                        _feedbackController.text,
                        _rating,
                      ),
                    );
                    Navigator.pop(context);
                    _feedbackController.clear();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildButtonDialog({isPositive, action, text}) {
    return Expanded(child: _button(isPositive, action, text));
  }

  StatelessWidget _button(isPositive, action, text) {
    return ButtonWidget(
      color: isPositive ? ColorUtil.bangladeshGreen : Colors.grey,
      borderRadius: BorderRadius.circular(30),
      padding: const EdgeInsets.symmetric(vertical: 10),
      onTap: () {
        if (action == null) {
          Navigator.pop(context);
        } else {
          action();
        }
      },
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  Widget _fullScreenHeroWidget(String img) {
    return FullScreenWidget(
      child: Hero(
        tag: img,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ImageUtil.loadNetWorkImage(
            url: img,
            height: 100,
            fit: BoxFit.contain,
          ),
          //fit: BoxFit.cover,
        ),
      ),
    );
  }

  Future _goToStaffInfo(UserModel? staffInfo) async {
    await Navigator.pushNamed(
      context,
      Routes.staffInfoScreen,
      arguments: {
        "id": staffInfo?.id,
        "name": staffInfo?.username,
        "staffInfo": staffInfo,
      },
    );
  }
}
