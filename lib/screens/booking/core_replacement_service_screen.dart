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
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/onepay_paygate/onepay_paygate_flutter.dart';
import 'package:socbay/paths/images.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/button_widget.dart';
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
    _bloc.close();
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
    var staffName = _bloc.orderDetailModel?.staff != null
        ? _bloc.orderDetailModel?.staff?.username
        : '';
    return Scaffold(
      appBar: MyAppBar(
        title: "Chi tiết lần thay lõi",
        isBackNavigation: true,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            //shrinkWrap: true,
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromRGBO(4, 107, 80, 1),
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Expanded(child: _tableAction())],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 15, right: 15),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.black26),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Expanded(child: _tablePrice())],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 15, top: 10, right: 15),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    // Bỏ ButtonWidget
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Thông tin kỹ thuật viên: ",
                          style: TextStyle(color: Colors.black),
                        ),
                        WidgetSpan(
                          child: GestureDetector(
                            // Sử dụng GestureDetector
                            onTap: () {
                              _goToStaffInfo(_bloc.orderDetailModel?.staff);
                            },
                            child: Text(
                              staffName!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: ColorUtil.bangladeshGreen,
                                decorationThickness: 1,
                                decoration: TextDecoration.underline,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Container(
              //   margin: const EdgeInsets.only(left: 15, top: 10),
              //   child: Align(
              //       alignment: Alignment.centerLeft,
              //       child: ButtonWidget(
              //         onTap: () {
              //           _goToStaffInfo(_bloc.orderDetailModel?.staff);
              //         },
              //         child: RichText(
              //           text: TextSpan(children: [
              //             const TextSpan(
              //                 text: "Thông tin kỹ thuật viên: ",
              //                 style: TextStyle(color: Colors.black)),
              //             TextSpan(
              //               text: staffName,
              //               style: const TextStyle(
              //                   fontWeight: FontWeight.w600,
              //                   color: ColorUtil.bangladeshGreen,
              //                   decorationThickness: 1,
              //                   decoration: TextDecoration.underline,
              //                   fontSize: 13),
              //             )
              //           ]),
              //         ),
              //       )),
              // ),
              // const SizedBox(height: 10.0),
              Column(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: _heading('Đánh giá và nhận xét dịch vụ'),
                  ),
                  _ratingBarDisplay(),
                  Container(
                    margin: const EdgeInsets.only(left: 15, right: 15),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1.0, color: Colors.black26),
                      ),
                    ),
                    child: Text(_bloc.des),
                  ),
                ],
              ),

              Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromRGBO(4, 107, 80, 1),
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: _tableUpdate(),
              ),
              Wrap(
                spacing: 8.0, // gap between adjacent chips
                runSpacing: 4.0, // gap between lines
                direction: Axis.horizontal, // main axis (rows or columns)
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 15, top: 5),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Hình ảnh đơn hàng: "),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 15, top: 0),
                    child: _buildMediaRow(),
                  ),
                ],
              ),
              if (_bloc.orderDetailModel?.paymentStatus == '1') ...[
                Container(
                  margin: const EdgeInsets.only(left: 15, top: 0),
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
      bottomNavigationBar: _showBottomSheetFeedback(),
    );
  }

  Widget _showBottomSheetFeedback() {
    if (App.instance.userApp?.isUserCustomer() == true) {
      final buttonWidth = (context.width - 40) / 3;
      final itemWidth = buttonWidth.clamp(96.0, 140.0);

      ButtonStyle buttonStyle(Color backgroundColor) {
        return ButtonStyle(
          backgroundColor: WidgetStateProperty.all(backgroundColor),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        );
      }

      return SafeArea(
        bottom: true,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: itemWidth,
                child: ElevatedButton.icon(
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
                    Icons.feedback,
                    color: ColorUtil.brightYellow,
                    size: 16,
                  ),
                  label: const Text(
                    "Khiếu nại",
                    style: TextStyle(color: ColorUtil.white, fontSize: 13),
                  ),
                  style: buttonStyle(ColorUtil.bangladeshGreen),
                ),
              ),
              if (_bloc.orderDetailModel?.paymentStatus == '0')
                SizedBox(
                  width: itemWidth,
                  child: ElevatedButton.icon(
                    onPressed: _createPayment,
                    icon: const Icon(
                      Icons.payment,
                      color: ColorUtil.brightYellow,
                      size: 16,
                    ),
                    label: const Text(
                      "Thanh toán",
                      style: TextStyle(color: ColorUtil.white, fontSize: 13),
                    ),
                    style: buttonStyle(ColorUtil.red),
                  ),
                ),
              SizedBox(
                width: itemWidth,
                child: ElevatedButton.icon(
                  onPressed: () {
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
                  icon: const Icon(
                    Icons.add,
                    color: ColorUtil.brightYellow,
                    size: 16,
                  ),
                  label: const Text(
                    "Đặt lịch",
                    style: TextStyle(color: ColorUtil.white, fontSize: 13),
                  ),
                  style: buttonStyle(ColorUtil.bangladeshGreen),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _tableAction() {
    return Table(
      columnWidths: const {1: FlexColumnWidth(2)},
      border: TableBorder.symmetric(
        inside: const BorderSide(
          width: 1,
          color: Color.fromRGBO(4, 107, 80, 1),
        ),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(
            border: Border.all(color: const Color.fromRGBO(4, 107, 80, 1)),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            color: ColorUtil.bangladeshGreen,
          ),
          children: const [
            TableCell(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Tên lõi",
                  style: TextStyle(color: ColorUtil.white),
                ),
              ),
            ),
            TableCell(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Thành tiền",
                  style: TextStyle(color: ColorUtil.white),
                ),
              ),
            ),
          ],
        ),
        if (_bloc.orderDetailModel?.orderFilterCoresModel != null)
          for (var item in _bloc.orderDetailModel!.orderFilterCoresModel!)
            if (!(item.price == "0.00" && item.replaceDatePromise != "")) ...[
              TableRow(
                children: [
                  TableCell(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          top: 3.0,
                          bottom: 3.0,
                        ),
                        child: Text(item.name ?? ""),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          top: 3.0,
                          bottom: 3.0,
                        ),
                        child: Text(
                          (item.price ?? "0")
                              .substring(
                                0,
                                (item.price ?? "0").contains(".")
                                    ? (item.price ?? "0").indexOf(".")
                                    : null,
                              )
                              .toVND(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
      ],
    );
  }

  Widget _tablePrice() {
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
    return Table(
      children: [
        TableRow(
          children: [
            TableCell(
              child: Container(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: const Text("Ngày thực hiện:"),
              ),
            ),
            TableCell(child: Text(_bloc.createDate)),
          ],
        ),
        TableRow(
          children: [
            TableCell(
              child: Container(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: const Text("Tổng tiền:"),
              ),
            ),
            TableCell(child: Text((sumPrice.toInt()).toVND())),
          ],
        ),
        if (_bloc.orderDetailModel?.type == '4')
          TableRow(
            children: [
              TableCell(
                child: Container(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: const Text("Thuế VAT:"),
                ),
              ),
              TableCell(
                child: Text(
                  (_bloc.orderDetailModel?.vatAmount != null)
                      ? '${_bloc.orderDetailModel?.vatAmount}%'
                      : '',
                ),
              ),
            ],
          ),
        TableRow(
          children: [
            TableCell(
              child: Container(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: const Text("Chiết khấu:"),
              ),
            ),
            TableCell(child: Text((discount ?? '0').toVND())),
          ],
        ),
        TableRow(
          children: [
            TableCell(
              child: Container(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: const Text("Trừ tích điểm:"),
              ),
            ),
            TableCell(
              child: Text(
                (Decimal.parse(subPoint ?? "0") * heso).toString().toVND(),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            TableCell(
              child: Container(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: const Text("Tổng tiền thanh toán:"),
              ),
            ),
            TableCell(
              child: Text(
                _totalPriced.toString().toVND(),
                style: const TextStyle(
                  color: ColorUtil.brightYellow,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (_bloc.orderDetailModel?.type == '2')
          TableRow(
            children: [
              TableCell(
                child: Container(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: const Text("Tích điểm:"),
                ),
              ),
              TableCell(child: Text((savePoint ?? "0"))),
            ],
          ),
      ],
    );
  }

  Widget _tableUpdate() {
    return Table(
      border: TableBorder.symmetric(
        inside: const BorderSide(
          width: 1,
          color: Color.fromRGBO(4, 107, 80, 1),
        ),
        //outside: const BorderSide(width: 1),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(
            border: Border.all(color: const Color.fromRGBO(4, 107, 80, 1)),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            color: ColorUtil.bangladeshGreen,
          ),
          children: const [
            TableCell(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Tên lõi",
                  style: TextStyle(color: ColorUtil.white),
                ),
              ),
            ),
            TableCell(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Ngày thay tiếp theo",
                  style: TextStyle(color: ColorUtil.white),
                ),
              ),
            ),
          ],
        ),
        if (_bloc.orderDetailModel != null &&
            _bloc.orderDetailModel!.orderFilterCoresModel != null)
          for (var item in _bloc.orderDetailModel!.orderFilterCoresModel!)
            if (item.replaceDatePromise != "") ...[
              TableRow(
                children: [
                  TableCell(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          top: 3.0,
                          bottom: 3.0,
                        ),
                        child: Text(item.name ?? ""),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
                        child: Text(item.replaceDatePromise ?? ""),
                      ),
                    ),
                  ),
                ],
              ),
            ],
      ],
    );
  }

  Widget _buildMediaRow() {
    return _bloc.orderDetailModel != null &&
            _bloc.orderDetailModel!.images != null &&
            _bloc.orderDetailModel!.images!.isNotEmpty
        ? SizedBox(
            height: 200,
            width: double.infinity,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ListView.builder(
                itemCount: _bloc.orderDetailModel!.images?.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return _buildItemMedia(
                    "$protocol${AppConfig.instance.values.apiUrl}/${_bloc.orderDetailModel!.images![index]}",
                  );
                },
              ),
            ),
          )
        : Container();
  }

  Widget _buildItemMedia(String url) {
    return Row(
      children: [
        Stack(children: [_fullScreenHeroWidget(url)]),
        const SizedBox(width: 5),
      ],
    );
  }

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(left: 15),
    child: Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            //fontSize: 13.0,
            //color: ColorUtil.bangladeshGreen,
          ),
        ),
        _bloc.rating != 0 ||
                _bloc.des != "" ||
                App.instance.userApp?.isUserCustomer() == false
            ? const Icon(Icons.rate_review, color: Colors.white12)
            : IconButton(
                icon: const Icon(Icons.rate_review),
                color: ColorUtil.brightYellow,
                onPressed: () {
                  /* Your code */
                  _ratingAndNote();
                },
              ),
      ],
    ),
  );

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

  Future _goToStaffInfo(UserProfile? staffInfo) async {
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
