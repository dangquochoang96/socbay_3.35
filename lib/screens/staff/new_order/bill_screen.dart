import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/staff/new_order/staff_new_order_bloc.dart';
import 'package:socbay/blocs/staff/new_order/staff_new_order_event.dart';
import 'package:socbay/blocs/staff/new_order/staff_new_order_state.dart';
import 'package:socbay/data/model/bill_data.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

class BillScreen extends StatefulWidget {
  final BillData billData;
  const BillScreen({
    Key? key,
    required this.billData,
  }) : super(key: key);

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  late StaffNewOrderBloc _bloc;
  final GlobalKey _globalKey = GlobalKey();

  final SignatureController _controller = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.red,
    exportBackgroundColor: Colors.blue,
  );

  @override
  void initState() {
    _bloc = BlocProvider.of<StaffNewOrderBloc>(context);
    _bloc.add(StaffNewOrderInitEvent());
    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaffNewOrderBloc, StaffNewOrderState>(
        builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, StaffNewOrderState state) {
    if (state is ServiceScreenUploadImageSuccessState) {
      for (var element in state.paths) {
        widget.billData.images?.add(element);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ảnh đã được lưu thành công!')),
      );
    } else if (state is ServiceScreenUploadImageFailedState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  }

  Future<void> _captureAndSaveScreenshot() async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage();
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData!.buffer.asUint8List();
      final directory = await getApplicationDocumentsDirectory();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final tempImagePath = p.join(directory.path, '$fileName.png');
      final tempImageFile = File(tempImagePath);
      await tempImageFile.writeAsBytes(pngBytes);
      List<File> files = [tempImageFile];
      Navigator.pop(context, files);
    } catch (e) {
      print('Error saving screenshot: $e');
      Navigator.pop(context);
    }
  }

  String formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'vi').format(amount);
  }

  String formatStringCurrency(String? amount) {
    int value = (amount == null || amount.isEmpty) ? 0 : int.parse(amount);
    return NumberFormat.currency(locale: 'vi').format(value);
  }

  Widget _builder(BuildContext context, StaffNewOrderState state) {
    final billData = widget.billData;
    return Scaffold(
      appBar: MyAppBar(title: "Đơn hàng", isBackNavigation: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: RepaintBoundary(
          key: _globalKey,
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'HÓA ĐƠN BÁN HÀNG - KIÊM PHIẾU BẢO HÀNH',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
                  ),
                ),
                const SizedBox(height: 20.0),
                Text('Tên khách hàng: ${billData.name}',
                    style: const TextStyle(fontSize: 18)),
                Text('Địa chỉ: ${billData.address}',
                    style: const TextStyle(fontSize: 18)),
                Text('SDT: ${billData.phone}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20.0),
                Table(
                  border: TableBorder.all(),
                  children: [
                    const TableRow(
                      children: [
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                                child: Text('Tên lõi',
                                    style: TextStyle(fontSize: 18))),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                                child: Text('Thành tiền',
                                    style: TextStyle(fontSize: 18))),
                          ),
                        ),
                      ],
                    ),
                    for (int i = 0; i < billData.lstNew.length; i++)
                      TableRow(
                        children: [
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                  child: Text('${billData.lstNew[i].name}',
                                      style: const TextStyle(fontSize: 18))),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                  child: Text(
                                      formatStringCurrency(
                                          billData.lstNew[i].price),
                                      style: const TextStyle(fontSize: 18))),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 20.0),
                Table(
                  columnWidths: const {
                    0: FixedColumnWidth(200),
                    1: FixedColumnWidth(150),
                  },
                  children: [
                    TableRow(
                      children: [
                        const Text('Tổng cộng đơn hàng:',
                            style: TextStyle(fontSize: 18)),
                        Text(formatCurrency(billData.total),
                            style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Text('Chiết khấu:',
                            style: TextStyle(fontSize: 18)),
                        Text(formatCurrency(billData.discount),
                            style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Text('Trừ tích điểm:',
                            style: TextStyle(fontSize: 18)),
                        Text('${billData.subSavePoint}',
                            style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Text('Thuế VAT:',
                            style: TextStyle(fontSize: 18)),
                        Text('${billData.vat}%',
                            style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Text('Tổng tiền thanh toán:',
                            style: TextStyle(fontSize: 18)),
                        Text(formatCurrency(billData.totalPay),
                            style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Text('Tích điểm (100 điểm = 100K):',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                                fontSize: 18)),
                        Text('${billData.savePoint}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                                fontSize: 18)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                const Text('Cảm ơn Quý khách đã lựa chọn sản phẩm - dịch vụ.',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20.0),
                const Text('Hình thức thanh toán của quý khách là:',
                    style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text('Tiền mặt',
                              style: TextStyle(fontSize: 18)),
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Radio(
                                value: 1,
                                groupValue: billData.paymentType,
                                onChanged: (value) {}),
                          ),
                        ],
                      ),
                      flex: 1,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text('Chuyển khoản',
                              style: TextStyle(fontSize: 18)),
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Radio(
                                value: 2,
                                groupValue: billData.paymentType,
                                onChanged: (value) {}),
                          ),
                        ],
                      ),
                      flex: 1,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text('Ví', style: TextStyle(fontSize: 18)),
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Radio(
                                value: 3,
                                groupValue: billData.paymentType,
                                onChanged: (value) {}),
                          ),
                        ],
                      ),
                      flex: 1,
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                const Text('KHÁCH HÀNG (Tên và chữ ký):',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18)),
                IconButton(
                  key: const Key('clear'),
                  icon: const Icon(Icons.clear),
                  color: Colors.blue,
                  onPressed: () {
                    setState(() => _controller.clear());
                  },
                  tooltip: 'Clear',
                ),
                Text('${billData.name}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red)),
                const SizedBox(height: 10.0),
                Signature(
                    controller: _controller,
                    width: 400,
                    height: 150,
                    backgroundColor: Colors.lightBlueAccent),
                const SizedBox(height: 20.0),
                Text('KỸ THUẬT VIÊN: ${billData.staff}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20.0),
                const Center(
                    child: Text('LỊCH THAY LÕI TIẾP THEO',
                        style: TextStyle(fontSize: 18))),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: Table(
                        border: TableBorder.all(),
                        children: [
                          const TableRow(
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(
                                      child: Text('Lỗi Lọc',
                                          style: TextStyle(fontSize: 18))),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(
                                      child: Text('Ngày thay tiếp theo',
                                          style: TextStyle(fontSize: 18))),
                                ),
                              ),
                            ],
                          ),
                          for (int i = 0; i < billData.lstMaintain.length; i++)
                            TableRow(
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                        child: Text(
                                            '${billData.lstMaintain[i].name}',
                                            style:
                                                const TextStyle(fontSize: 18))),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                        child: Text(
                                            '${billData.lstMaintain[i].replaceDatePromise}',
                                            style:
                                                const TextStyle(fontSize: 18))),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _captureAndSaveScreenshot,
                  child: const Text('Lưu Ảnh Hóa Đơn',
                      style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
