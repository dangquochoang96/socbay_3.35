// ignore_for_file: constant_identifier_names

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_format_money_vietnam/flutter_format_money_vietnam.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:intl/intl.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/machine/core_replacement_service/core_replacement_service_bloc.dart';
import 'package:socbay/blocs/machine/core_replacement_service/core_replacement_service_event.dart';
import 'package:socbay/blocs/machine/core_replacement_service/core_replacement_service_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/model/user_model.dart';
import 'package:socbay/data/model/order_payment_model.dart';
// import 'package:socbay/onepay_paygate/onepay_paygate_flutter.dart';
import 'package:socbay/paths/images.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:socbay/widgets/text_field_default.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:socbay/data/event_bus/event_bus_event.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

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

  // void _createPayment() {
  //   final amount = _totalPriced?.toString();
  //   if (amount == null) {
  //     return;
  //   }
  //   //Môi trường Test
  //   // var ACCESS_CODE_PAYGATE = "6BEB2546"; // Onepay send for merchant
  //   // var MERCHANT_PAYGATE = "TESTONEPAY"; //  Merchant register with onepay
  //   // var HASH_KEY = "6D0870CDE5F24F34F3915FB0045120DB"; // Onepay send for merchant
  //   // var URL_SCHEMES = "merchantappscheme"; // get CFBundleURLSchemes in Info.plist
  //   const ACCESS_CODE_PAYGATE = "A2905C04";
  //   const MERCHANT_PAYGATE = "OP_SHOMEAPP";
  //   const HASH_KEY = "6C6F8CF98A8C9C37214E613411F3E3A1";
  //   const URL_SCHEMES = "merchantappscheme";

  //   var entity = OPPaymentEntity(
  //     amount: double.parse(amount),
  //     orderInformation: "${App.instance.userApp?.phone}",
  //     currency: OnepayCurrency.vnd,
  //     accessCode: ACCESS_CODE_PAYGATE,
  //     merchant: MERCHANT_PAYGATE,
  //     hashKey: HASH_KEY,
  //     urlSchemes: URL_SCHEMES,
  //   );
  //   OnePayPaygate.open(
  //     context: context,
  //     entity: entity,
  //     onPayResult: (OPPaymentResult result) {
  //       if (result.isSuccess) {
  //         setState(() {
  //           _bloc.add(
  //             OrderPaymentStatusUpdatedEvent(_bloc.orderDetailModel!.id!),
  //           );
  //         });
  //         showDialog(
  //           context: context,
  //           builder: (context) => const AlertDialog(
  //             title: Text("Thông báo"),
  //             content: Text("Thanh toán thành công"),
  //           ),
  //         );
  //       } else {
  //         showDialog(
  //           context: context,
  //           builder: (context) => AlertDialog(
  //             title: const Text("Thông báo"),
  //             content: Text(result.message ?? "Thanh toán không thành công"),
  //           ),
  //         );
  //       }
  //     },
  //     onPayFail: (error) {
  //       showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //           title: const Text("Lỗi"),
  //           content: Text(error.errorCase.name),
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      CoreReplacementServiceBloc,
      CoreReplatementServiceState
    >(builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, CoreReplatementServiceState state) {
    if (state is CoreReplacementServiceUploadPaymentProofSuccessState) {
      context.showSnackBar('Tải ảnh minh chứng thanh toán thành công!');
      _bloc.add(CoreReplatementServiceStartEvent());
      App.instance.eventBus.fire(EventBusReloadOrderPaymentsEvent());
    } else if (state is CoreReplacementServiceUploadPaymentProofFailState) {
      context.showSnackBar(state.message);
    }
  }

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
              _buildPaymentInfoCard(),
              if (_bloc.orderDetailModel?.orderFilterCoresModel != null &&
                  _bloc.orderDetailModel!.orderFilterCoresModel!.any(
                    (item) => item.replaceDatePromise != "",
                  ))
                _buildUpdateCard(),
              _buildReviewCard(),
              if (_bloc.orderDetailModel?.images != null &&
                  _bloc.orderDetailModel!.images!.isNotEmpty)
                _buildMediaCard(),
              if (_isOrderPaymentPaid) ...[
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

  bool get _isOrderPaymentPaid =>
      _bloc.orderDetailModel?.orderPayment == null ||
      _bloc.orderDetailModel!.orderPayment!.isEmpty ||
      _bloc.orderDetailModel?.orderPayment?.any(
            (p) => p.paymentStatus == '1',
          ) ==
          true;

  bool get _isOrderPaymentUnpaid =>
      _bloc.orderDetailModel?.orderPayment != null &&
      _bloc.orderDetailModel!.orderPayment!.isNotEmpty &&
      _bloc.orderDetailModel?.orderPayment?.any(
            (p) => p.paymentStatus == '0',
          ) ==
          true;

  Widget _buildPaymentStatusChip() {
    final payments = _bloc.orderDetailModel?.orderPayment;
    String status = '1';
    if (payments != null && payments.isNotEmpty) {
      if (payments.any((p) => p.paymentStatus == '0')) {
        status = '0';
      } else if (payments.any((p) => p.paymentStatus == '2')) {
        status = '2';
      } else {
        status = payments.first.paymentStatus ?? '1';
      }
    }

    String text;
    Color textColor;
    Color bgColor;

    if (status == '1' || payments == null || payments.isEmpty) {
      text = 'Đã thanh toán';
      textColor = ColorUtil.green;
      bgColor = ColorUtil.green.withValues(alpha: 0.1);
    } else if (status == '2') {
      text = 'Chờ xác nhận';
      textColor = ColorUtil.brightYellow;
      bgColor = ColorUtil.brightYellow.withValues(alpha: 0.1);
    } else {
      text = 'Chưa thanh toán';
      textColor = ColorUtil.red;
      bgColor = ColorUtil.red.withValues(alpha: 0.1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildOrderTypeChip() {
    final type = _bloc.orderDetailModel?.type;
    String text;
    Color textColor = ColorUtil.raisinBlack;
    Color bgColor = const Color(0xFFF1F5F9);

    if (type == '1' || type == '2') {
      text = 'Đơn dịch vụ';
      textColor = const Color(0xFF0F766E);
      bgColor = const Color(0xFFF0FDFA);
    } else if (type == '3' || type == '4') {
      text = 'Đơn thuê';
      textColor = const Color(0xFF1D4ED8);
      bgColor = const Color(0xFFEFF6FF);
    } else {
      text = 'Không xác định';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  OrderPaymentModel? get _currentUnpaidPayment {
    final payments = _bloc.orderDetailModel?.orderPayment;
    if (payments == null || payments.isEmpty) return null;
    try {
      return payments.firstWhere((p) => p.paymentStatus == '0');
    } catch (_) {
      return payments.first;
    }
  }

  String get _paymentAmount {
    final unpaidPayment = _currentUnpaidPayment;
    if (unpaidPayment != null) {
      final amount = unpaidPayment.amount;
      if (amount != null && amount.isNotEmpty) {
        return _normalizePaymentAmount(amount);
      }
    }
    final orderTotal = _normalizePaymentAmount(_bloc.finalPrice);
    if (orderTotal.isNotEmpty && orderTotal != '0') {
      return orderTotal;
    }
    return '0';
  }

  String _normalizePaymentAmount(String amount) {
    final cleanAmount = amount
        .replaceAll('.', '')
        .replaceAll('đ', '')
        .replaceAll(',', '')
        .trim();
    final rawAmount = amount.replaceAll('đ', '').replaceAll(',', '').trim();
    final dotIndex = rawAmount.lastIndexOf('.');
    if (dotIndex >= 0 && rawAmount.length - dotIndex <= 3) {
      final parsedAmount = double.tryParse(rawAmount);
      if (parsedAmount != null) {
        return parsedAmount.round().toString();
      }
    }
    return cleanAmount;
  }

  String get _orderCodeForTransfer {
    final order = _bloc.orderDetailModel;
    if (order?.code?.isNotEmpty == true) {
      return order!.code!;
    }
    if (order?.orderCode?.isNotEmpty == true) {
      return order!.orderCode!;
    }
    return order?.id?.toString() ?? '';
  }

  String get _customerPhoneForTransfer {
    return _bloc.orderDetailModel?.user?.phone?.isNotEmpty == true
        ? _bloc.orderDetailModel!.user!.phone!
        : App.instance.userApp?.phone ?? '';
  }

  String get _transferContent {
    final orderCode = _orderCodeForTransfer;
    final phone = _customerPhoneForTransfer;
    if (orderCode.isNotEmpty && phone.isNotEmpty) {
      return '$orderCode $phone';
    }
    if (orderCode.isNotEmpty) {
      return orderCode;
    }
    final unpaidPayment = _currentUnpaidPayment;
    return unpaidPayment?.transferContent ?? '';
  }

  String get _paymentQrUrl {
    final amount = _paymentAmount;
    final addInfo = Uri.encodeQueryComponent(_transferContent);
    final accountName = Uri.encodeQueryComponent('CTCP CN VA DV SHOME');
    return 'https://img.vietqr.io/image/vpbank-551999-compact2.png?amount=$amount&addInfo=$addInfo&accountName=$accountName';
  }

  void _showPermissionSettingsDialog(String permissionName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Yêu cầu quyền truy cập'),
          content: Text(
            'Ứng dụng cần quyền truy cập $permissionName để lưu mã QR. Vui lòng cấp quyền trong Cài đặt thiết bị của bạn.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Bỏ qua',
                style: TextStyle(color: ColorUtil.spanishGray),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorUtil.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Đi tới Cài đặt',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _downloadQrCode(String url) async {
    try {
      PermissionStatus status = PermissionStatus.denied;
      if (Platform.isIOS) {
        status = await Permission.photos.status;
        if (status.isDenied) {
          status = await Permission.photos.request();
        }
        if (status.isPermanentlyDenied) {
          _showPermissionSettingsDialog('Thư viện ảnh');
          return;
        }
        if (!status.isGranted && !status.isLimited) {
          return;
        }
      } else if (Platform.isAndroid) {
        status = await Permission.storage.status;
        if (status.isDenied) {
          status = await Permission.storage.request();
        }
        if (status.isPermanentlyDenied) {
          // Check/Request Permission.photos on Android 13+ (READ_MEDIA_IMAGES)
          final photosStatus = await Permission.photos.status;
          if (photosStatus.isDenied) {
            status = await Permission.photos.request();
          } else {
            status = photosStatus;
          }
          if (status.isPermanentlyDenied) {
            _showPermissionSettingsDialog('Bộ nhớ / Thư viện ảnh');
            return;
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đang tải mã QR...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final result = await ImageGallerySaverPlus.saveImage(
          bytes,
          quality: 100,
          name: "QR_Code_Payment_${DateTime.now().millisecondsSinceEpoch}",
        );

        if (result != null && result['isSuccess'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lưu mã QR thành công vào thư viện ảnh.'),
                backgroundColor: ColorUtil.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Không thể lưu mã QR: ${result?['errorMessage'] ?? 'Lỗi không xác định'}',
                ),
                backgroundColor: ColorUtil.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tải ảnh QR thất bại. Vui lòng thử lại.'),
              backgroundColor: ColorUtil.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xảy ra lỗi: $e'),
            backgroundColor: ColorUtil.red,
          ),
        );
      }
    }
  }

  void _showPaymentQrSheet() {
    final qrUrl = _paymentQrUrl;
    final amount = int.tryParse(_paymentAmount);
    final unpaidPayment = _currentUnpaidPayment;
    final orderPaymentId = unpaidPayment?.id;

    final notesController = TextEditingController();
    final List<File> billFiles = [];
    final picker = ImagePicker();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              margin: const EdgeInsets.all(12),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.qr_code_2_rounded,
                        color: Color(0xFF2563EB),
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Thanh toán chuyển khoản',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColorUtil.raisinBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Vui lòng quét mã QR chuyển khoản, sau đó tải ảnh bill minh chứng bên dưới.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColorUtil.spanishGray,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.network(
                            qrUrl,
                            height: 220,
                            width: 220,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const SizedBox(
                              height: 180,
                              child: Center(
                                child: Text(
                                  'Không tải được mã QR.\nVui lòng kiểm tra kết nối mạng.',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => _downloadQrCode(qrUrl),
                            icon: const Icon(
                              Icons.download_rounded,
                              color: Color(0xFF2563EB),
                              size: 18,
                            ),
                            label: const Text(
                              'Lưu mã QR về máy',
                              style: TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildPaymentQrInfoRow(
                      'Số tiền',
                      amount != null
                          ? amount.toString().toVND()
                          : _paymentAmount,
                      isHighlight: true,
                    ),
                    _buildPaymentQrInfoRow('Nội dung CK', _transferContent),
                    const SizedBox(height: 16),

                    const Divider(color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 12),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Tải lên ảnh minh chứng (ảnh bill)',
                        style: TextStyle(
                          color: ColorUtil.raisinBlack,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    final pickedFile = await picker.pickImage(
                                      source: ImageSource.camera,
                                      imageQuality: 50,
                                    );
                                    if (pickedFile != null) {
                                      setSheetState(() {
                                        billFiles.add(File(pickedFile.path));
                                      });
                                    }
                                  },
                            icon: const Icon(Icons.photo_camera_outlined),
                            label: const Text('Chụp bill'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    final pickedFiles = await picker
                                        .pickMultiImage(imageQuality: 50);
                                    if (pickedFiles.isNotEmpty) {
                                      setSheetState(() {
                                        billFiles.addAll(
                                          pickedFiles.map((x) => File(x.path)),
                                        );
                                      });
                                    }
                                  },
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Chọn ảnh'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (billFiles.isNotEmpty)
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: billFiles.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (_, index) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    billFiles[index],
                                    width: 80,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: () {
                                      setSheetState(() {
                                        billFiles.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: notesController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Nhập ghi chú thanh toán (nếu có)...',
                          hintStyle: TextStyle(
                            color: ColorUtil.spanishGray,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.of(sheetContext).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('Bỏ qua'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                (isSubmitting ||
                                    billFiles.isEmpty ||
                                    orderPaymentId == null)
                                ? null
                                : () {
                                    setSheetState(() {
                                      isSubmitting = true;
                                    });
                                    _bloc.add(
                                      CoreReplacementServiceUploadPaymentProofEvent(
                                        orderPaymentId: orderPaymentId,
                                        notes: notesController.text.trim(),
                                        files: billFiles,
                                        paymentStatus: 2,
                                      ),
                                    );
                                    Navigator.of(sheetContext).pop();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorUtil.green,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Gửi minh chứng',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentQrInfoRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: ColorUtil.spanishGray, fontSize: 13),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isHighlight ? ColorUtil.red : ColorUtil.raisinBlack,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                fontSize: isHighlight ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
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
      final hasPayment = _isOrderPaymentUnpaid;

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
                    onPressed: _showPaymentQrSheet,
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

  Widget _buildInfoRowWithWidget(String label, Widget valueWidget) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
            child: Align(alignment: Alignment.centerRight, child: valueWidget),
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
    var discount = _bloc.orderDetailModel?.chietKhau;
    var subPoint = _bloc.orderDetailModel?.truTichDiem;
    var savePoint = _bloc.orderDetailModel?.tichDiem;
    Decimal heso = Decimal.parse("1000");
    _totalPriced = _bloc.finalPrice;

    return _buildCard(
      title: "Chi tiết thanh toán",
      icon: Icons.receipt_long_outlined,
      child: Column(
        children: [
          _buildInfoRowWithWidget("Loại đơn:", _buildOrderTypeChip()),
          if (_bloc.orderDetailModel?.orderPayment != null &&
              _bloc.orderDetailModel!.orderPayment!.isNotEmpty)
            _buildInfoRowWithWidget(
              "Trạng thái thanh toán:",
              _buildPaymentStatusChip(),
            ),
          _buildInfoRow("Ngày thực hiện:", _bloc.createDate),
          if (_bloc.orderDetailModel?.ghichu != null &&
              _bloc.orderDetailModel!.ghichu!.trim().isNotEmpty)
            _buildInfoRow("Ghi chú:", _bloc.orderDetailModel!.ghichu!.trim()),
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

  Widget _buildPaymentInfoCard() {
    final payments = _bloc.orderDetailModel?.orderPayment;
    if (payments == null || payments.isEmpty) return const SizedBox.shrink();

    return _buildCard(
      title: 'Chi tiết giao dịch thanh toán',
      icon: Icons.payments_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < payments.length; i++) ...[
            if (i > 0) ...[
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFE2E8F0), height: 1),
              const SizedBox(height: 12),
            ],
            _buildSinglePaymentDetail(payments[i], i + 1),
          ],
        ],
      ),
    );
  }

  Widget _buildSinglePaymentDetail(OrderPaymentModel payment, int indexNo) {
    // Map method: 1 -> Chuyển khoản, 0 -> Tiền mặt
    String methodText = 'Không xác định';
    if (payment.method == '1') {
      methodText = 'Chuyển khoản';
    } else if (payment.method == '0') {
      methodText = 'Tiền mặt';
    } else {
      methodText = payment.method ?? 'Chuyển khoản';
    }

    final double amountValue = double.tryParse(payment.amount ?? '0') ?? 0;

    String formattedDate = '';
    if (payment.createdAt != null) {
      try {
        final parsedDate = DateTime.parse(payment.createdAt!);
        formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
      } catch (_) {
        formattedDate = payment.createdAt!;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Giao dịch #${payment.id}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: ColorUtil.bangladeshGreen,
              ),
            ),
            if (formattedDate.isNotEmpty)
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 11,
                  color: ColorUtil.spanishGray,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        _buildInfoRow('Phương thức:', methodText),
        _buildInfoRow(
          'Số tiền:',
          amountValue.toInt().toString().toVND(),
          valueColor: ColorUtil.red,
          isBold: true,
        ),
        _buildInfoRow(
          "Trạng thái thanh toán:",
          payment.paymentStatus == "1"
              ? "Đã thanh toán"
              : payment.paymentStatus == "2"
              ? "Chờ xác nhận"
              : "Chưa thanh toán",
          valueColor: payment.paymentStatus == "1"
              ? ColorUtil.green
              : payment.paymentStatus == "2"
              ? ColorUtil.brightYellow
              : ColorUtil.red,
          isBold: true,
        ),
        if (payment.notes?.isNotEmpty == true)
          _buildInfoRow('Ghi chú:', payment.notes!),
        if (payment.proofImages != null && payment.proofImages!.isNotEmpty) ...[
          const SizedBox(height: 10),
          const Text(
            'Hình ảnh minh chứng:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: ColorUtil.spanishGray,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: payment.proofImages!.length,
              itemBuilder: (context, imgIndex) {
                final String rawPath = payment.proofImages![imgIndex];
                final String imgUrl = ImageUtil.getUrlFromStoragePath(rawPath);
                return Container(
                  margin: const EdgeInsets.only(right: 10.0),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FullScreenWidget(
                      disposeLevel: DisposeLevel.Medium,
                      child: Hero(
                        tag: 'payment_proof_img_${payment.id}_$imgIndex',
                        child: ImageUtil.loadNetWorkImage(
                          url: imgUrl,
                          height: 80,
                          width: 80,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
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
