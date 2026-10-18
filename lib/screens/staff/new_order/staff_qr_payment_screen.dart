import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_format_money_vietnam/flutter_format_money_vietnam.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socbay/blocs/staff/new_order/staff_new_order_bloc.dart';
import 'package:socbay/blocs/staff/new_order/staff_new_order_event.dart';
import 'package:socbay/blocs/staff/new_order/staff_new_order_state.dart';
import 'package:socbay/data/model/order_detail_model.dart';
import 'package:socbay/data/model/order_payment_model.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/widgets/dialog/custom_alert_dialog.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';

class StaffOrderQrPaymentScreen extends StatefulWidget {
  final OrderDetailModel? order;
  final OrderPaymentModel? orderPayment;

  const StaffOrderQrPaymentScreen({
    super.key,
    this.order,
    this.orderPayment,
  });

  @override
  State<StaffOrderQrPaymentScreen> createState() =>
      _StaffOrderQrPaymentScreenState();
}

class _StaffOrderQrPaymentScreenState extends State<StaffOrderQrPaymentScreen> {
  late StaffNewOrderBloc _bloc;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<StaffNewOrderBloc>(context);
  }

  void _listener(BuildContext context, StaffNewOrderState state) {
    if (state is StaffNewOrderInitialState) {
      setState(() {
        _isLoading = _bloc.isLoading;
      });
    }
    if (state is StaffNewOrderUploadPaymentProofSuccessState) {
      setState(() {
        _isLoading = false;
      });
      if (state.paymentStatus == 0) {
        context.showSnackBarSuccess('Đã ghi nhận khách chưa thanh toán');
      } else {
        context.showSnackBarSuccess('Đã lưu ảnh bill thanh toán');
      }
      _goToOrderManager();
    }
    if (state is StaffNewOrderUploadPaymentProofFailState) {
      context.showSnackBar(state.message);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _goToOrderManager() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.orderManagerScreen,
      (route) => route.isFirst,
    );
  }

  void _confirmExit() {
    CustomAlertDialog.show(
      context,
      title: 'Xác nhận rời trang',
      content:
          'Đơn hàng đã được tạo thành công trên hệ thống. Bạn có muốn chuyển đến màn hình Quản lý đơn hàng không?',
      leftText: 'Ở lại',
      rightText: 'Đến QLĐH',
      isRightPositive: true,
      leftAction: () {
        Navigator.pop(context);
      },
      rightAction: () {
        Navigator.pop(context);
        _goToOrderManager();
      },
    );
  }

  void _handleCustomerNotPaid() {
    final orderPaymentId = widget.orderPayment?.id;
    if (orderPaymentId == null) {
      context.showSnackBar(
        'Không tìm thấy mã thanh toán để cập nhật trạng thái.',
      );
      return;
    }

    CustomAlertDialog.show(
      context,
      title: 'Xác nhận',
      content: 'Ghi nhận khách chưa thanh toán cho đơn hàng này?',
      leftText: 'Hủy',
      rightText: 'Xác nhận',
      isRightPositive: true,
      leftAction: () => Navigator.pop(context),
      rightAction: () {
        Navigator.pop(context);
        _bloc.add(
          StaffNewOrderUploadPaymentProofEvent(
            orderPaymentId: orderPaymentId,
            notes: '',
            files: [],
            paymentStatus: 0,
          ),
        );
      },
    );
  }

  void _handleCustomerPaid() {
    final orderPaymentId = widget.orderPayment?.id;
    if (orderPaymentId == null) {
      context.showSnackBar('Không tìm thấy thông tin thanh toán để lưu bill.');
      return;
    }
    _showPaymentProofSheet(orderPaymentId: orderPaymentId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaffNewOrderBloc, StaffNewOrderState>(
      listener: _listener,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, StaffNewOrderState state) {
    final orderPayment = widget.orderPayment;
    final qrUrl = orderPayment?.qrUrl ?? '';
    final amount = int.tryParse(orderPayment?.amount ?? '');
    final orderId = widget.order?.id ?? int.tryParse(orderPayment?.orderId ?? '');
    final orderIdDisplay = widget.order?.code ?? orderId?.toString() ?? '';
    final formattedAmount = amount != null
        ? amount.toString().toVND()
        : (orderPayment?.amount ?? '');
    final transferContent = orderPayment?.transferContent ?? '';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmExit();
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F6F8),
          appBar: MyAppBar(
            title: 'Quét QR chuyển khoản',
            isBackNavigation: true,
            onBack: _confirmExit,
          ),
          body: LoadingIndicator(
            isLoading: _isLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.qr_code_2_rounded,
                        color: Color(0xFF2563EB),
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Quét QR để chuyển khoản',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColorUtil.raisinBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      orderIdDisplay.isNotEmpty ? 'Đơn hàng #$orderIdDisplay' : '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: ColorUtil.spanishGray,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: qrUrl.isNotEmpty
                          ? Image.network(
                              qrUrl,
                              height: 260,
                              width: 260,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const SizedBox(
                                height: 220,
                                width: 220,
                                child: Center(
                                  child: Text(
                                    'Không tải được mã QR.\nVui lòng kiểm tra kết nối mạng.',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(
                              height: 220,
                              width: 220,
                              child: Center(
                                child: Text(
                                  'Chưa có mã QR thanh toán.',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    _buildQrInfoRow(
                      'Số tiền',
                      formattedAmount,
                      isHighlight: true,
                      copyValue: amount?.toString() ?? orderPayment?.amount,
                    ),
                    _buildQrInfoRow(
                      'Nội dung CK',
                      transferContent,
                      copyValue: transferContent,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _handleCustomerNotPaid,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Khách chưa thanh toán',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: ColorUtil.raisinBlack,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleCustomerPaid,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorUtil.green,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Khách đã thanh toán',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _isLoading ? null : _confirmExit,
                      child: const Text(
                        'Về Quản lý đơn hàng',
                        style: TextStyle(
                          color: ColorUtil.spanishGray,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQrInfoRow(
    String label,
    String value, {
    bool isHighlight = false,
    String? copyValue,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
          if (copyValue != null && copyValue.trim().isNotEmpty) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: copyValue.trim()));
                context.showSnackBar('Đã sao chép $label');
              },
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(
                  Icons.copy_rounded,
                  size: 18,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showPaymentProofSheet({required int orderPaymentId}) {
    final notesController = TextEditingController();
    final List<File> billFiles = [];

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    const Text(
                      'Xác nhận thanh toán',
                      style: TextStyle(
                        color: ColorUtil.raisinBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Chụp hoặc chọn ảnh bill chuyển khoản của khách hàng. Ảnh này sẽ được gửi cho kế toán kiểm tra.',
                      style: TextStyle(
                        color: ColorUtil.spanishGray,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final files = await _pickPaymentBillImages(
                                source: ImageSource.camera,
                              );
                              if (files.isNotEmpty) {
                                setSheetState(() {
                                  billFiles.addAll(files);
                                });
                              }
                            },
                            icon: const Icon(Icons.photo_camera_outlined),
                            label: const Text('Chụp bill'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final files = await _pickPaymentBillImages(
                                source: ImageSource.gallery,
                                allowMultiple: true,
                              );
                              if (files.isNotEmpty) {
                                setSheetState(() {
                                  billFiles.addAll(files);
                                });
                              }
                            },
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Chọn ảnh'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (billFiles.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              color: ColorUtil.spanishGray,
                              size: 34,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Chưa có ảnh bill',
                              style: TextStyle(color: ColorUtil.spanishGray),
                            ),
                          ],
                        ),
                      )
                    else
                      SizedBox(
                        height: 104,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: billFiles.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 10),
                          itemBuilder: (_, index) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.file(
                                    billFiles[index],
                                    width: 92,
                                    height: 104,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: InkWell(
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
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildTextFieldWrapper(
                      TextField(
                        controller: notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Ghi chú cho kế toán (nếu có)...',
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (billFiles.isEmpty) {
                            context.showSnackBar(
                              'Vui lòng chụp hoặc chọn ít nhất 1 ảnh bill.',
                            );
                            return;
                          }
                          final notes = notesController.text.trim();
                          Navigator.of(sheetContext).pop();
                          _bloc.add(
                            StaffNewOrderUploadPaymentProofEvent(
                              orderPaymentId: orderPaymentId,
                              notes: notes,
                              files: billFiles,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorUtil.green,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Lưu ảnh bill',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(notesController.dispose);
  }

  Widget _buildTextFieldWrapper(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: child,
    );
  }

  Future<List<File>> _pickPaymentBillImages({
    required ImageSource source,
    bool allowMultiple = false,
  }) async {
    final List<File> selectedFiles = [];

    if (source == ImageSource.camera) {
      if (!await Permission.camera.request().isGranted) {
        if (!mounted) return selectedFiles;
        CustomAlertDialog.show(
          context,
          leftText: 'Cài đặt',
          rightText: 'Hủy',
          isLeftPositive: true,
          leftAction: () {
            Navigator.pop(context);
            openAppSettings();
          },
          content: 'Vui lòng cấp quyền truy cập camera.',
        );
        return selectedFiles;
      }
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        selectedFiles.add(File(pickedFile.path));
      }
    } else if (allowMultiple) {
      bool isGranted = true;
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        isGranted = await Permission.photos.request().isGranted;
      }
      if (!isGranted) {
        if (mounted) {
          context.showSnackBar('Vui lòng cấp quyền truy cập thư viện ảnh.');
        }
        return selectedFiles;
      }
      final pickedFiles = await _picker.pickMultiImage(imageQuality: 70);
      selectedFiles.addAll(pickedFiles.map((item) => File(item.path)));
    } else {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        selectedFiles.add(File(pickedFile.path));
      }
    }

    return selectedFiles;
  }
}
