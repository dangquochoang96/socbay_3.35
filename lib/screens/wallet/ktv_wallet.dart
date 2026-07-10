import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:socbay/blocs/staff/wallet/ktv_wallet_bloc.dart';
import 'package:socbay/blocs/staff/wallet/ktv_wallet_event.dart';
import 'package:socbay/blocs/staff/wallet/ktv_wallet_state.dart';
import 'package:socbay/data/model/wallet_model.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/utils/number_format_utils.dart';
import 'package:socbay/widgets/my_app_bar.dart';

class KtvWalletScreen extends StatefulWidget {
  const KtvWalletScreen({super.key});

  @override
  State<KtvWalletScreen> createState() => _KtvWalletScreenState();
}

class _KtvWalletScreenState extends State<KtvWalletScreen> {
  late KtvWalletBloc _bloc;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<KtvWalletBloc>(context);
    _bloc.add(KtvWalletStartedEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KtvWalletBloc, KtvWalletState>(
      listener: _listener,
      builder: _builder,
    );
  }

  void _listener(BuildContext context, KtvWalletState state) {
    if (state is KtvWalletSubmitLoadingState) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              ColorUtil.bangladeshGreen,
            ),
          ),
        ),
      );
    } else if (state is KtvWalletSubmitSuccessState) {
      // Pop loading dialog
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: ColorUtil.green,
        ),
      );
    } else if (state is KtvWalletSubmitFailureState) {
      // Pop loading dialog
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: ColorUtil.red),
      );
    }
  }

  Widget _builder(BuildContext context, KtvWalletState state) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: MyAppBar(
        title: 'Quản lý ví KTV',
        centerTitle: true,
        isBackNavigation: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _bloc.add(KtvWalletRefreshEvent());
        },
        child: _buildContent(state),
      ),
    );
  }

  Widget _buildContent(KtvWalletState state) {
    if (state is KtvWalletLoadingState && _bloc.currentWallet == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ColorUtil.bangladeshGreen),
        ),
      );
    }

    if (state is KtvWalletFailureState && _bloc.currentWallet == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: ColorUtil.red),
              const SizedBox(height: 16),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: ColorUtil.raisinBlack,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _bloc.add(KtvWalletStartedEvent());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorUtil.bangladeshGreen,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Thử lại',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final wallet = _bloc.currentWallet ?? WalletModel();
    final transactions = _bloc.currentTransactions;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Wallet Balance Card
          _buildWalletCard(wallet),

          // Quick actions
          _buildQuickActions(),

          // Transaction History Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lịch sử giao dịch',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColorUtil.primary,
                  ),
                ),
                if (transactions.isNotEmpty)
                  Text(
                    '${transactions.length} giao dịch',
                    style: const TextStyle(
                      fontSize: 13,
                      color: ColorUtil.graniteGray,
                    ),
                  ),
              ],
            ),
          ),

          // Giao dịch list
          if (transactions.isEmpty)
            _buildEmptyTransactions()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                return _buildTransactionItem(transactions[index]);
              },
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildWalletCard(WalletModel wallet) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorUtil.bangladeshGreen,
            ColorUtil.bangladeshGreen.withValues(alpha: 0.85),
            const Color(0xFF8A4E03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorUtil.bangladeshGreen.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SỐ DƯ VÍ KTV',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Icon(Icons.wallet, color: Colors.white70, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            NumberFormatUtil.parseToVND(wallet.balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white24, height: 1),
          // const SizedBox(height: 16),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     _buildWalletSubStat('Công nợ', wallet.debt, Colors.orangeAccent),
          //     _buildWalletSubStat(
          //       'Tổng ứng',
          //       wallet.totalAdvance,
          //       Colors.lightBlueAccent,
          //     ),
          //     _buildWalletSubStat(
          //       'Tổng nộp',
          //       wallet.totalDeposit,
          //       Colors.greenAccent,
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildWalletSubStat(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          NumberFormatUtil.parseToVND(amount),
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              title: 'Ứng tiền',
              subtitle: 'Yêu cầu ứng trước',
              icon: Icons.unarchive_outlined,
              color: Colors.blue,
              onTap: () => _showRequestFormBottomSheet(isAdvance: true),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionButton(
              title: 'Nộp tiền',
              subtitle: 'Nộp tiền về công ty',
              icon: Icons.archive_outlined,
              color: ColorUtil.green,
              onTap: () => _showRequestFormBottomSheet(isAdvance: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: ColorUtil.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: ColorUtil.graniteGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(
              Icons.history_toggle_off,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có lịch sử giao dịch',
              style: TextStyle(
                fontSize: 15,
                color: ColorUtil.graniteGray,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(WalletTransactionModel tx) {
    final bool isOutflow = tx.action == 0;
    final Color amountColor = isOutflow ? ColorUtil.red : ColorUtil.green;
    final String prefix = isOutflow ? '-' : '+';

    String txTitle = 'Giao dịch ví';
    if (tx.type == 0) {
      txTitle = 'Thu tiền từ đơn hàng';
    } else if (tx.type == 1) {
      txTitle = 'Nộp tiền về công ty';
    } else if (tx.type == 2) {
      txTitle = 'Yêu cầu ứng tiền';
    } else if (tx.type == 3) {
      txTitle = 'Kế toán điều chỉnh';
    }

    final String formattedAmount =
        '$prefix${NumberFormatUtil.parseToVND(tx.amount)}';

    // Status codes mapping: 0: Đang chờ xử lý, 1: Đã xử lý, 2: Đã từ chối
    Color statusBgColor = Colors.grey.shade100;
    Color statusTextColor = ColorUtil.graniteGray;
    String statusName = 'Chờ duyệt';

    if (tx.status == 0) {
      statusBgColor = Colors.orange.shade50;
      statusTextColor = Colors.orange.shade800;
      statusName = 'Chờ duyệt';
    } else if (tx.status == 1) {
      statusBgColor = Colors.green.shade50;
      statusTextColor = Colors.green.shade800;
      statusName = 'Thành công';
    } else if (tx.status == 2) {
      statusBgColor = Colors.red.shade50;
      statusTextColor = Colors.red.shade800;
      statusName = 'Từ chối';
    }

    String displayDate = '';
    if (tx.createdAt != null && tx.createdAt!.isNotEmpty) {
      try {
        final parsedDate = DateTime.parse(tx.createdAt!);
        displayDate = DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
      } catch (_) {
        displayDate = tx.createdAt!;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    txTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ColorUtil.primary,
                    ),
                  ),
                  if (displayDate.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      displayDate,
                      style: const TextStyle(
                        fontSize: 11,
                        color: ColorUtil.spanishGray,
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                formattedAmount,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: amountColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (tx.referenceId != null) ...[
                      Text(
                        tx.referenceType == 0
                            ? 'Đơn hàng: #${tx.referenceId}'
                            : 'Mã tham chiếu: #${tx.referenceId}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: ColorUtil.raisinBlack,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    if (tx.note != null && tx.note!.isNotEmpty) ...[
                      Text(
                        'Ghi chú: ${tx.note}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: ColorUtil.graniteGray,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      statusName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusTextColor,
                      ),
                    ),
                  ),
                  if (tx.status == 0 && (tx.type == 1 || tx.type == 2)) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _confirmDeleteTransaction(context, tx.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 12,
                              color: ColorUtil.red,
                            ),
                            SizedBox(width: 2),
                            Text(
                              'Xóa',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: ColorUtil.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          if (tx.proofImages != null && tx.proofImages!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Hình ảnh minh chứng:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: ColorUtil.graniteGray,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tx.proofImages!.length,
                itemBuilder: (context, imgIndex) {
                  final String rawPath = tx.proofImages![imgIndex];
                  final String imgUrl = ImageUtil.getUrlFromStoragePath(
                    rawPath,
                  );
                  return Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FullScreenWidget(
                        disposeLevel: DisposeLevel.Medium,
                        child: Hero(
                          tag: 'tx_${tx.id}_img_$imgIndex',
                          child: ImageUtil.loadNetWorkImage(
                            url: imgUrl,
                            height: 60,
                            width: 60,
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
      ),
    );
  }

  void _confirmDeleteTransaction(BuildContext context, int? transactionId) {
    if (transactionId == null) return;
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa giao dịch này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Hủy',
                style: TextStyle(color: ColorUtil.graniteGray),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _bloc.add(
                  KtvWalletDeleteTransactionEvent(transactionId: transactionId),
                );
              },
              child: const Text(
                'Xóa',
                style: TextStyle(
                  color: ColorUtil.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRequestFormBottomSheet({required bool isAdvance}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _WalletRequestBottomSheet(
          isAdvance: isAdvance,
          imagePicker: _imagePicker,
          onSubmit:
              (double amount, int? orderId, String note, List<File> files) {
                if (isAdvance) {
                  _bloc.add(
                    KtvWalletAdvanceSubmitEvent(
                      amount: amount,
                      orderId: orderId,
                      note: note,
                      proofImages: files,
                    ),
                  );
                } else {
                  _bloc.add(
                    KtvWalletDepositSubmitEvent(
                      amount: amount,
                      note: note,
                      proofImages: files,
                    ),
                  );
                }
              },
        );
      },
    );
  }
}

class _WalletRequestBottomSheet extends StatefulWidget {
  final bool isAdvance;
  final ImagePicker imagePicker;
  final Function(double amount, int? orderId, String note, List<File> files)
  onSubmit;

  const _WalletRequestBottomSheet({
    required this.isAdvance,
    required this.imagePicker,
    required this.onSubmit,
  });

  @override
  State<_WalletRequestBottomSheet> createState() =>
      _WalletRequestBottomSheetState();
}

class _WalletRequestBottomSheetState extends State<_WalletRequestBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _orderIdController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final List<File> _selectedFiles = [];

  @override
  Widget build(BuildContext context) {
    final title = widget.isAdvance
        ? 'Yêu cầu ứng tiền đơn hàng'
        : 'Yêu cầu nộp tiền về công ty';
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + keyboardHeight),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bottom sheet handler bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorUtil.primary,
                ),
              ),
              const SizedBox(height: 20),

              // Số tiền field
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Số tiền (bắt buộc) *',
                  hintText: 'Nhập số tiền',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  suffixText: 'VNĐ',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập số tiền';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Số tiền phải lớn hơn 0';
                  }
                  return null;
                },
                onChanged: (val) {
                  setState(() {});
                },
              ),
              if (_amountController.text.isNotEmpty) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    'Số tiền hiển thị: ${NumberFormatUtil.parseToVND(double.tryParse(_amountController.text) ?? 0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: ColorUtil.bangladeshGreen,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Mã đơn hàng field (chỉ dành cho Ứng tiền)
              if (widget.isAdvance) ...[
                TextFormField(
                  controller: _orderIdController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Mã đơn hàng (tùy chọn)',
                    hintText: 'Nhập ID đơn hàng ứng tiền',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      final orderId = int.tryParse(value);
                      if (orderId == null || orderId <= 0) {
                        return 'Mã đơn hàng không hợp lệ';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Ghi chú field
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú (tùy chọn)',
                  hintText: 'Nhập lý do hoặc nội dung chi tiết',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Ảnh minh chứng section
              const Text(
                'Hình ảnh minh chứng (tùy chọn)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ColorUtil.primary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  GestureDetector(
                    onTap: _pickImageOptions,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_a_photo_outlined,
                        color: ColorUtil.bangladeshGreen,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 80,
                      child: _selectedFiles.isEmpty
                          ? Center(
                              child: Text(
                                'Chưa có ảnh nào được chọn',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedFiles.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                        right: 8.0,
                                        top: 4.0,
                                      ),
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _selectedFiles[index],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedFiles.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: ColorUtil.red,
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(3),
                                          child: const Icon(
                                            Icons.close,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Nút gửi yêu cầu
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.of(context).pop();
                    final amount = double.parse(_amountController.text);
                    final orderId = _orderIdController.text.trim().isNotEmpty
                        ? int.parse(_orderIdController.text.trim())
                        : null;
                    widget.onSubmit(
                      amount,
                      orderId,
                      _noteController.text.trim(),
                      _selectedFiles,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorUtil.bangladeshGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'GỬI YÊU CẦU',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Chọn nguồn ảnh',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColorUtil.primary,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: ColorUtil.bangladeshGreen,
                ),
                title: const Text('Thư viện ảnh'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: ColorUtil.bangladeshGreen,
                ),
                title: const Text('Máy ảnh'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await widget.imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedFiles.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể chọn ảnh: $e')));
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _orderIdController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
