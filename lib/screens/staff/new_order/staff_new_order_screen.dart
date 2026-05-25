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
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/model/bill_data.dart';
import 'package:socbay/data/model/list_order_core_model.dart';
import 'package:socbay/data/model/machine_model.dart';
import 'package:socbay/data/model/order_filter_core_model.dart';
import 'package:socbay/data/model/order_model.dart';
import 'package:socbay/data/model/product_model.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/date_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/utils/logger_util.dart';
import 'package:socbay/utils/string_extension.dart';
import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/dialog/custom_alert_dialog.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:socbay/widgets/textfield_search.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class StaffNewOrderScreen extends StatefulWidget {
  const StaffNewOrderScreen({super.key});

  @override
  State<StatefulWidget> createState() => _StaffNewOrderScreen();
}

class _StaffNewOrderScreen extends State<StaffNewOrderScreen> {
  late StaffNewOrderBloc _bloc;
  late BillData billData;
  late Map<String, dynamic> billDataMap;
  int _currentSelectedProductValue = 0;
  final TextEditingController currentSelectedProductAllValue =
      TextEditingController();
  final List<OrderModel> _listProducts = [];
  final List<ProductModel> _listProductsAll = [];
  List<KeyValue> lstKeyValueCores = [];
  List<KeyValue> lstKeyValueMaintainCores = [];

  TextEditingController chietKhauController = TextEditingController();
  TextEditingController subSavePointController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  bool isListProductsSelected = true;
  TextEditingController addressCustomerController = TextEditingController();
  TextEditingController addressCustomerControllerSP = TextEditingController();
  final List<String> _listPath = [];
  late final ImagePicker _picker;
  bool _isLoading = false;
  final GlobalKey _autocompleteKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    _bloc.add(StaffNewOrderInitEvent());
    String dateDefault = DateTime.now()
        .add(const Duration(days: 183))
        .toDateString(format: "dd/MM/yyyy");
    lstKeyValueCores
      ..add(KeyValue(TextEditingController(), TextEditingController()))
      ..add(KeyValue(TextEditingController(), TextEditingController()))
      ..add(KeyValue(TextEditingController(), TextEditingController()));
    lstKeyValueMaintainCores
      ..add(KeyValue(
          TextEditingController(), TextEditingController(text: dateDefault)))
      ..add(KeyValue(
          TextEditingController(), TextEditingController(text: dateDefault)))
      ..add(KeyValue(
          TextEditingController(), TextEditingController(text: dateDefault)));
    _picker = ImagePicker();
    currentSelectedProductAllValue.addListener(() {
      if (_listProductsAll
          .where(
              (element) => element.name == currentSelectedProductAllValue.text)
          .isNotEmpty) {
        setState(() {
          _currentSelectedProductValue = 0;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    lstKeyValueCores.clear();
    lstKeyValueMaintainCores.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaffNewOrderBloc, StaffNewOrderState>(
        builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, StaffNewOrderState state) {
    if (state is StaffNewOrderInitialState) {
      setState(() {
        subSavePointController.text = _bloc.subSavePoint.toString();
        _currentSelectedProductValue =
            int.tryParse(_bloc.taskModel?.productId ?? "") ?? 0;
        _isLoading = _bloc.isLoading;
        addressCustomerController.text =
            _bloc.taskModel?.customer?.address ?? '';
        addressCustomerControllerSP.text =
            _bloc.taskModel?.productInfo?.address ?? '';
      });
    }
    if (state is StaffNewOrderGetListProductsSuccessState) {
      _listProducts.clear();
      _listProducts.add(OrderModel(
          id: 0, product: MachineModel(id: 0, name: "--Chọn sản phẩm--")));
      
      // Filter products based on orderDetail type
      int orderDetailType = _bloc.orderDetail?.type != null 
          ? int.tryParse(_bloc.orderDetail!.type!) ?? 0 
          : 0;
      
      for (var element in _bloc.listProducts) {
        if (element.product != null) {
          bool shouldAdd = false;
          if (orderDetailType == 1) {
            shouldAdd = element.orderTypeLabel == 'Bán';
          } else if (orderDetailType == 3) {
            shouldAdd = element.orderTypeLabel == 'Thuê';
          } else {
            shouldAdd = true;
          }
          
          if (shouldAdd) {
            _listProducts.add(element);
          }
        }
      }
      setState(() {
        _isLoading = _bloc.isLoading;
      });
    }
    if (state is StaffNewOrderGetListProductsAllSuccessState) {
      _listProductsAll.clear();
      for (var element in _bloc.listProductsAll) {
        _listProductsAll.add(element);
      }
      setState(() {
        _isLoading = _bloc.isLoading;
      });
    }
    if (state is StaffCreateOrderCoresFailState) {
      context.showSnackBarSuccess("Đã xảy ra lỗi");
      setState(() {
        _isLoading = _bloc.isLoading;
      });
    }
    if (state is StaffCreateOrderCoresSuccessState) {
      setState(() {
        _isLoading = _bloc.isLoading;
      });
      Navigator.pushReplacementNamed(context, Routes.orderManagerScreen);
    }
    if (state is ServiceScreenUploadImageFailedState) {
      context.showSnackBar("Upload ảnh lỗi!");
      setState(() {
        _isLoading = _bloc.isLoading;
      });
    }
    if (state is ServiceScreenUploadImageSuccessState) {
      for (var element in state.paths) {
        _listPath.add(element);
      }
      setState(() {
        _isLoading = _bloc.isLoading;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ảnh đã được lưu thành công!')),
      );
    } else if (state is ServiceScreenUploadImageFailedState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  }

  Widget _builder(BuildContext context, StaffNewOrderState state) {
    return Listener(
      onPointerDown: (PointerDownEvent event) =>
          FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
          child: Scaffold(
        appBar: MyAppBar(
          title: "Tạo hóa đơn",
          isBackNavigation: true,
        ),
        body: LoadingIndicator(
            isLoading: _isLoading,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 16.0, left: 16.0, right: 10.0, bottom: 0.0),
              child: ListView(
                addRepaintBoundaries: false,
                // controller: _controller,
                children: [
                  Center(
                      child: Table(
                    columnWidths: const {0: FlexColumnWidth(0.5)},
                    children: [
                      TableRow(
                        children: [
                          const TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.only(top: 16.0, right: 8.0),
                              child: Text(
                                'Tên khách hàng:',
                                style: TextStyle(
                                  color: ColorUtil.raisinBlack,
                                  fontWeight: FontWeight.bold,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 16.0, left: 8.0),
                              child: Row(
                                children: [
                                  Text(
                                    _bloc.taskModel?.customer?.username ?? '',
                                    style: const TextStyle(
                                      color: ColorUtil.raisinBlack,
                                      height: 1.5,
                                    ),
                                  ),
                                  Text(
                                    ' (${_bloc.taskModel?.customer?.phone ?? ''})',
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 4, 100, 52),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.only(top: 16.0, right: 8.0),
                              child: Text(
                                "Địa chỉ khách",
                                style: TextStyle(
                                  color: ColorUtil.raisinBlack,
                                  fontWeight: FontWeight.bold,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 16.0, left: 8.0),
                              child: TextField(
                                controller: addressCustomerController,
                                textAlign: TextAlign.left,
                                keyboardType: TextInputType.text,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.only(top: 16.0, right: 8.0),
                              child: Text(
                                "Vị trí lắp đặt",
                                style: TextStyle(
                                  color: ColorUtil.raisinBlack,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 16.0, left: 8.0),
                              child: TextField(
                                controller: addressCustomerControllerSP,
                                textAlign: TextAlign.left,
                                keyboardType: TextInputType.text,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
                  Center(
                      child: Table(
                    columnWidths: const {0: FlexColumnWidth(1)},
                    children: [
                      _buildTableRow(
                          title: 'Sản phẩm đã có:',
                          content: '',
                          isHighlight: false)
                    ],
                  )),
                  _buildDropdownFieldPruducts(),
                  Center(
                      child: Table(
                    columnWidths: const {1: FlexColumnWidth(0.1)},
                    children: [
                      _buildTableRow(
                          title: 'Thêm sản phẩm mới nếu chưa có:',
                          content: '',
                          isHighlight: false),
                    ],
                  )),
                  _selectNewProduct(),
                  _itemFilterCoreTable(),
                  _itemFilterCoreMaintainTable(),
                  Table(
                    columnWidths: const {0: FlexColumnWidth(1.0)},
                    children: [
                      TableRow(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color.fromRGBO(4, 107, 80, 1)),
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10)),
                              color: ColorUtil.bangladeshGreen),
                          children: [
                            TableCell(
                                child: Align(
                              alignment: Alignment.bottomCenter,
                              child: TextButton(
                                onPressed: () => {},
                                child: const Padding(
                                  padding: EdgeInsets.only(
                                      top: 8.0, bottom: 6.0, right: 16.0),
                                  child: Text("Thanh toán",
                                      style: TextStyle(color: ColorUtil.white)),
                                ),
                              ),
                            )),
                            const TableCell(
                              child: SizedBox(),
                            )
                          ]),
                      _buildTableRow(
                          title: 'Tổng tiền:',
                          content: _bloc.total.toVND(),
                          isHighlight: false),
                      TableRow(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: const Text(
                              "Chiết khấu",
                              style: TextStyle(
                                  color: ColorUtil.raisinBlack,
                                  fontWeight: FontWeight.bold,
                                  height: 1.5),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: TextField(
                              controller: chietKhauController,
                              textAlign: TextAlign.left,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              maxLines: null,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'VNĐ',
                                isDense: true,
                                contentPadding: EdgeInsets.only(top: 6.0),
                              ),
                              onChanged: (text) {
                                if (chietKhauController.text != '') {
                                  var money = text
                                      .replaceAll(".", "")
                                      .replaceAll("đ", "")
                                      .nonBreaking
                                      .trim();
                                  setState(() {
                                    _bloc.totalPay = _bloc.total -
                                        (int.tryParse(money) ?? 0) -
                                        (int.tryParse(subSavePointController
                                                    .text) ??
                                                0) *
                                            1000;
                                    _bloc.savePoint =
                                        (_bloc.totalPay * 3 / 100000).ceil();
                                    chietKhauController.value =
                                        TextEditingValue(
                                      text: money.toVND(),
                                      selection: TextSelection.collapsed(
                                          offset: money.toVND().length - 2),
                                    );
                                  });
                                }
                              },
                            ),
                          )
                        ],
                      ),
                      TableRow(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: const Text(
                              "Trừ tích điểm",
                              style: TextStyle(
                                  color: ColorUtil.raisinBlack,
                                  fontWeight: FontWeight.bold,
                                  height: 1.5),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: TextField(
                              style: const TextStyle(color: ColorUtil.red),
                              controller: subSavePointController,
                              textAlign: TextAlign.left,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              maxLines: null,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(top: 6.0),
                              ),
                              onChanged: (text) {
                                if (subSavePointController.text != '') {
                                  if (int.parse(text) > _bloc.subSavePoint) {
                                    context
                                        .showSnackBarSuccess("Không đủ điểm!");
                                    setState(() {
                                      {
                                        subSavePointController.text =
                                            _bloc.subSavePoint.toString();
                                        var chietKhau =
                                            chietKhauController.text;
                                        var totalPay = _bloc.total -
                                            (int.tryParse(chietKhau
                                                    .replaceAll(".", "")
                                                    .replaceAll("đ", "")
                                                    .nonBreaking
                                                    .trim()) ??
                                                0) -
                                            1000 * (_bloc.subSavePoint);
                                        _bloc.totalPay =
                                            totalPay > 0 ? totalPay : 0;
                                        _bloc.savePoint =
                                            (_bloc.totalPay * 3 / 100000)
                                                .ceil();
                                      }
                                    });
                                    return;
                                  } else {
                                    // subSavePointController.text = text;
                                    setState(() {
                                      var chietKhau = chietKhauController.text;
                                      var totalPay = _bloc.total -
                                          (int.tryParse(chietKhau
                                                  .replaceAll(".", "")
                                                  .replaceAll("đ", "")
                                                  .nonBreaking
                                                  .trim()) ??
                                              0) -
                                          1000 * (int.tryParse(text) ?? 0);
                                      _bloc.totalPay =
                                          totalPay > 0 ? totalPay : 0;
                                      _bloc.savePoint =
                                          (_bloc.totalPay * 3 / 100000).ceil();
                                    });
                                  }
                                } else {
                                  setState(() {
                                    var chietKhau = chietKhauController.text;
                                    var totalPay = _bloc.total -
                                        (int.tryParse(chietKhau
                                                .replaceAll(".", "")
                                                .replaceAll("đ", "")
                                                .nonBreaking
                                                .trim()) ??
                                            0);
                                    _bloc.totalPay =
                                        totalPay > 0 ? totalPay : 0;
                                    _bloc.savePoint =
                                        (_bloc.totalPay * 3 / 100000).ceil();
                                  });
                                }
                              },
                            ),
                          )
                        ],
                      ),
                      _buildTableRow(
                          title: 'Tổng thanh toán:',
                          content: _bloc.totalPay.toVND(),
                          isHighlight: false),
                      _buildTableRow(
                          title: 'Tích điểm:',
                          content: _bloc.savePoint.toString(),
                          isHighlight: false),
                      _buildTableRow(
                          title: 'Hình thức thanh toán:',
                          content: '',
                          isHighlight: false),
                    ],
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            const Text('Tiền mặt'),
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Radio(
                                  value: 1,
                                  groupValue: _bloc.paymentType,
                                  onChanged: (index) {
                                    setState(() {
                                      _bloc.paymentType = 1;
                                    });
                                  }),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            const Text('Chuyển khoản'),
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Radio(
                                  value: 2,
                                  groupValue: _bloc.paymentType,
                                  onChanged: (index) {
                                    setState(() {
                                      _bloc.paymentType = 2;
                                    });
                                  }),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            const Text('Ví'),
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Radio(
                                  value: 3,
                                  groupValue: _bloc.paymentType,
                                  onChanged: (index) {
                                    setState(() {
                                      _bloc.paymentType = 3;
                                    });
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  _buildSectionMedia(),
                  ButtonWidget(
                      onTap: () {
                        var getProductNew = _listProductsAll.where((element) =>
                            element.name ==
                            currentSelectedProductAllValue.text);
                        if (_currentSelectedProductValue == 0 &&
                            getProductNew.isEmpty) {
                          context.showSnackBar('Vui lòng chọn sản phẩm');
                          return;
                        }
                        List<OrderFilterCoreModel> lst1 = [];
                        List<OrderFilterCoreModel> lst2 = [];
                        for (var item in lstKeyValueCores) {
                          if (item.key.text.isNotEmpty) {
                            lst1.add(OrderFilterCoreModel(
                                name: item.key.text,
                                price: item.value.text
                                    .replaceAll(".", "")
                                    .replaceAll("đ", "")
                                    .nonBreaking
                                    .trim()));
                          }
                        }
                        for (var item in lstKeyValueMaintainCores) {
                          if (item.key.text.isNotEmpty) {
                            lst2.add(OrderFilterCoreModel(
                                name: item.key.text,
                                replaceDatePromise: item.value.text));
                          }
                        }
                        if (lst1.isEmpty) {
                          context
                              .showSnackBar('Chưa nhập chi tiết lần thay lõi');
                          return;
                        }

                        billData = BillData(
                            usernameId: _bloc.taskModel?.customer?.id,
                            saleId: _bloc.taskModel?.saleId,
                            name: _bloc.taskModel?.customer?.username ?? '',
                            address: addressCustomerController.text,
                            addressSP: addressCustomerControllerSP.text,
                            phone: _bloc.taskModel?.customer?.phone ?? '',
                            productId: _currentSelectedProductValue,
                            newProductId: getProductNew.isNotEmpty
                                ? getProductNew.first.id
                                : 0,
                            lstNew: lst1,
                            lstMaintain: lst2,
                            total: _bloc.total,
                            discount: int.tryParse(chietKhauController.text
                                    .replaceAll(".", "")
                                    .replaceAll("đ", "")
                                    .nonBreaking
                                    .trim()) ??
                                0,
                            vat: 0,
                            totalPay: _bloc.totalPay,
                            savePoint: _bloc.savePoint,
                            subSavePoint: (_bloc.total == 0 &&
                                    _bloc.totalPay == 0)
                                ? 0
                                : (int.tryParse(subSavePointController.text) ??
                                    0),
                            paymentType: _bloc.paymentType,
                            images: _listPath,
                            staff: _bloc.taskModel?.staff?.username);

                        Navigator.pushNamed(
                          context,
                          Routes.billScreen,
                          arguments: billData,
                        ).then((value) => {
                              if (value != null && value is List<File>)
                                {
                                  setState(() {
                                        _bloc.add(
                                          StaffNewOrderUploadImageEvent(value),
                                        );
                                      })
                                }
                              else
                                {context.showSnackBar('Chưa lưu ảnh hóa đơn')},
                            });
                      },
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      borderRadius: BorderRadius.circular(30),
                      margin: const EdgeInsets.only(
                          left: 60.0, right: 60, bottom: 10, top: 10),
                      color: ColorUtil.green,
                      child: const Text(
                        "Hóa đơn điện tử",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      )),
                  ButtonWidget(
                    onTap: () {
                      var getProductNew = _listProductsAll.where((element) =>
                          element.name == currentSelectedProductAllValue.text);
                      if (_currentSelectedProductValue == 0 &&
                          getProductNew.isEmpty) {
                        context.showSnackBar('Vui lòng chọn sản phẩm');
                        return;
                      }
                      _bloc.total = int.tryParse(_bloc.total
                              .toString()
                              .replaceAll(".", "")
                              .replaceAll("đ", "")
                              .nonBreaking
                              .trim()) ??
                          0;
                      _bloc.chietKhau = int.tryParse(chietKhauController.text
                              .replaceAll(".", "")
                              .replaceAll("đ", "")
                              .nonBreaking
                              .trim()) ??
                          0;
                      _bloc.subSavePoint = int.tryParse(subSavePointController
                              .text
                              .replaceAll(".", "")
                              .replaceAll("đ", "")
                              .nonBreaking
                              .trim()) ??
                          0;
                      _bloc.totalPay = int.tryParse(_bloc.totalPay
                              .toString()
                              .replaceAll(".", "")
                              .replaceAll("đ", "")
                              .nonBreaking
                              .trim()) ??
                          0;
                      _bloc.savePoint = _bloc.savePoint;
                      if (_bloc.totalPay < 0) {
                        context.showSnackBar('Tổng thanh toán không được âm');
                        return;
                      }
                      List<OrderFilterCoreModel> lst1 = [];
                      List<OrderFilterCoreModel> lst2 = [];
                      for (var item in lstKeyValueCores) {
                        if (item.key.text.isNotEmpty) {
                          lst1.add(OrderFilterCoreModel(
                              name: item.key.text,
                              price: item.value.text
                                  .replaceAll(".", "")
                                  .replaceAll("đ", "")
                                  .nonBreaking
                                  .trim()));
                        }
                      }
                      for (var item in lstKeyValueMaintainCores) {
                        if (item.key.text.isNotEmpty) {
                          lst2.add(OrderFilterCoreModel(
                              name: item.key.text,
                              replaceDatePromise: item.value.text));
                        }
                      }

                      if (lst1.isEmpty) {
                        context.showSnackBar('Chưa nhập chi tiết lần thay lõi');
                        return;
                      }

                      if (_listPath.isEmpty) {
                        context.showSnackBar('Vui lòng lưu ảnh!');
                        return;
                      }

                      _bloc.add(StaffCreateOrderEvent(
                          _currentSelectedProductValue,
                          getProductNew.isNotEmpty ? getProductNew.first.id : 0,
                          lst1,
                          lst2,
                          _bloc.total,
                          (int.tryParse(chietKhauController.text
                                  .replaceAll(".", "")
                                  .replaceAll("đ", "")
                                  .nonBreaking
                                  .trim()) ??
                              0),
                          (_bloc.total == 0 && _bloc.totalPay == 0)
                              ? 0
                              : (int.tryParse(subSavePointController.text) ??
                                  0),
                          _bloc.totalPay,
                          _bloc.savePoint,
                          _bloc.paymentType,
                          '0',
                          _listPath,
                          addressCustomerController.text,
                          addressCustomerControllerSP.text,
                          '0',
                          '0',
                          '0',
                          DateTime.now()));
                    },
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    borderRadius: BorderRadius.circular(30),
                    margin: const EdgeInsets.only(
                        left: 60.0, right: 60, bottom: 60, top: 10),
                    color: ColorUtil.bangladeshGreen,
                    child: const Text(
                      "HOÀN THÀNH",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  )
                ],
              ),
            )),
      )),
    );
  }

  Widget _buildSectionMedia() {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: ColorUtil.bangladeshGreen, width: 0.5),
          borderRadius: BorderRadius.circular(8.0)),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
      child: Column(
        children: [
          Row(
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.upload_file,
                  color: ColorUtil.spanishGray,
                ),
              ),
              Flexible(
                  child: Text(
                'Up ảnh (tối đa 15 ảnh) và video (tối đa 15s) để kỹ thuật xem xét.',
                style: TextStyle(color: ColorUtil.spanishGray),
              ))
            ],
          ),
          SizedBox(
              height: 200,
              width: double.infinity,
              child: ListView.builder(
                itemCount: _listPath.length + 1,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return index < _listPath.length
                      ? _buildItemMedia(_listPath[index])
                      : _buildDefaultItemMedia();
                },
              )),
        ],
      ),
    );
  }

  Widget _buildDefaultItemMedia() {
    return GestureDetector(
      onTap: _showModalBottomSheetMedia,
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: ColorUtil.bangladeshGreen, width: 0.5),
        ),
        child: const Icon(Icons.add_circle_outline),
      ),
    );
  }

  Widget _buildItemMedia(String path) {
    return Row(
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: ImageUtil.loadNetWorkImage(
                  url: "$protocol${AppConfig.instance.values.apiUrl}$path",
                  width: 120,
                  height: 200),
            ),
            Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _listPath.remove(path);
                      _bloc.paths.remove(path);
                    });
                  },
                ))
          ],
        ),
        const SizedBox(
          width: 5.0,
        ),
      ],
    );
  }

  Widget _buildDropdownFieldPruducts() {
    return FormField<String>(
      builder: (FormFieldState<String> state) {
        return InputDecorator(
          decoration: InputDecoration(
              errorStyle:
                  const TextStyle(color: Colors.redAccent, fontSize: 16.0),
              hintText: 'Please select expense',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                    color: ColorUtil.bangladeshGreen, width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                    color: ColorUtil.bangladeshGreen, width: 0.5),
              ),
              prefixIcon: const Icon(Icons.account_box_outlined)),
          isEmpty: false,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _currentSelectedProductValue.toString(),
              isDense: true,
              isExpanded: true,
              onChanged: (String? newValue) {
                setState(() {
                  _currentSelectedProductValue = int.parse(newValue ?? "0");
                  if (_currentSelectedProductValue != 0) {
                    setState(() {
                      currentSelectedProductAllValue.text = "";
                      var add = _listProducts
                              .where((item) =>
                                  item.id.toString() ==
                                  _currentSelectedProductValue.toString())
                              .first
                              .address ??
                          '';
                      addressCustomerControllerSP.text = add;
                    });
                  }
                });
              },
              items: _listProducts.map((OrderModel sv) {
                return DropdownMenuItem<String>(
                  value: sv.id.toString(),
                  child: Text(sv.product?.name ?? ""),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _itemFilterCoreTable() {
    return Container(
      margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(4, 107, 80, 1)),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Expanded(child: _tableAction())],
      ),
    );
  }

  Widget _itemFilterCoreMaintainTable() {
    return Container(
      margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(4, 107, 80, 1)),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Expanded(child: _tableActionMaintain())],
      ),
    );
  }

  Widget _tableAction() {
    return Table(
      columnWidths: const {1: FlexColumnWidth(0.8)},
      border: TableBorder.symmetric(
        inside:
            const BorderSide(width: 1, color: Color.fromRGBO(4, 107, 80, 1)),
        //outside: const BorderSide(width: 1),
      ),
      children: [
        TableRow(
            decoration: BoxDecoration(
                border: Border.all(color: const Color.fromRGBO(4, 107, 80, 1)),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                color: ColorUtil.bangladeshGreen),
            children: [
              TableCell(
                  child: Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                  onPressed: () => {},
                  child: const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text("Chi tiết lần thay lõi",
                        style: TextStyle(color: ColorUtil.white)),
                  ),
                ),
              )),
              TableCell(
                  child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                    onPressed: () {
                      setState(() {
                        lstKeyValueCores.add(KeyValue(
                            TextEditingController(), TextEditingController()));
                      });
                      for (var element in lstKeyValueCores) {
                        LoggerUtil.log(
                            "${element.key.text}-${element.value.text}");
                      }
                    },
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    )),
              ))
            ]),
        const TableRow(
            decoration: BoxDecoration(
                // border: Border.all(color: ColorUtil.brightYellow),
                color: ColorUtil.brightYellow),
            children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.0, top: 3.0, bottom: 3.0),
                    child: Text("Tên lõi",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.0, top: 3.0, bottom: 3.0),
                    child: Text("Thành tiền",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              )
            ]),
        //https://stackoverflow.com/questions/47032262/flutter-dropdownbutton-overflow
        if (lstKeyValueCores.isNotEmpty)
          for (var i = 0; i < lstKeyValueCores.length; i++)
            TableRow(children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
                  child: TextFieldSearch(
                    label: '',
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'item',
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    controller: lstKeyValueCores[i].key,
                    itemsInView: 10,
                    minStringLength: 0,
                    initialList: ListOrderCoreModel.coreList,
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
                  child: TextField(
                    controller: lstKeyValueCores[i].value,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'VNĐ',
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (text) {
                      if (lstKeyValueCores[i].key.text == '') {
                        lstKeyValueCores[i].value.text = '';
                        context.showSnackBar("Vui lòng chọn sản phẩm!");
                        return;
                      } else {
                        setState(() {
                          lstKeyValueCores[i].value.value = TextEditingValue(
                            text: (text.isEmpty ? "0" : text)
                                .replaceAll(".", "")
                                .replaceAll("đ", "")
                                .nonBreaking
                                .trim()
                                .toVND(),
                            selection:
                                TextSelection.collapsed(offset: text.length),
                          );
                          _bloc.total = 0;
                          for (var item in lstKeyValueCores) {
                            _bloc.total += int.tryParse(item.value.text
                                    .replaceAll(".", "")
                                    .replaceAll("đ", "")
                                    .nonBreaking
                                    .trim()) ??
                                0;
                          }
                          var chietkhau = chietKhauController.text;
                          if (_bloc.total > _bloc.subSavePoint * 1000) {
                            subSavePointController.text =
                                _bloc.subSavePoint.toString();
                          }
                          _bloc.totalPay = _bloc.total -
                              (int.tryParse(chietkhau
                                      .replaceAll(".", "")
                                      .replaceAll("đ", "")
                                      .nonBreaking
                                      .trim()) ??
                                  0) -
                              (int.tryParse(subSavePointController.text) ?? 0) *
                                  1000;
                          if (_bloc.totalPay < 0) {
                            _bloc.totalPay = 0;
                            _bloc.savePoint = 0;
                            subSavePointController.text = "0";
                            return;
                          }
                          if (_bloc.totalPay > _bloc.subSavePoint * 1000) {
                            subSavePointController.text =
                                _bloc.subSavePoint.toString();
                          }
                          _bloc.savePoint =
                              (_bloc.totalPay * 3 / 100000).ceil();
                        });
                      }
                    },
                  ),
                ),
              )
            ])
      ],
    );
  }

  Widget _tableActionMaintain() {
    return Table(
      columnWidths: const {1: FlexColumnWidth(0.8)},
      border: TableBorder.symmetric(
        inside:
            const BorderSide(width: 1, color: Color.fromRGBO(4, 107, 80, 1)),
      ),
      children: [
        TableRow(
            decoration: BoxDecoration(
                border: Border.all(color: const Color.fromRGBO(4, 107, 80, 1)),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                color: ColorUtil.bangladeshGreen),
            children: [
              TableCell(
                  child: Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                  onPressed: () => {},
                  child: const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text("Hẹn lịch",
                        style: TextStyle(color: ColorUtil.white)),
                  ),
                ),
              )),
              TableCell(
                  child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                    onPressed: () {
                      setState(() {
                        lstKeyValueMaintainCores.add(KeyValue(
                            TextEditingController(),
                            TextEditingController(
                                text: DateTime.now()
                                    .add(const Duration(days: 183))
                                    .toDateString(format: "dd/MM/yyyy"))));
                      });
                      for (var element in lstKeyValueMaintainCores) {
                        LoggerUtil.log(
                            "${element.key.text}-${element.value.text}");
                      }
                    },
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    )),
              ))
            ]),
        const TableRow(
            decoration: BoxDecoration(
                // border: Border.all(color: ColorUtil.brightYellow),
                color: ColorUtil.brightYellow),
            children: [
              TableCell(
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.0, top: 3.0, bottom: 3.0),
                    child: Text("Tên lõi",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ),
              TableCell(
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.0, top: 3.0, bottom: 3.0),
                    child: Text("Ngày thay tiếp theo",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              )
            ]),
        if (lstKeyValueMaintainCores.isNotEmpty)
          for (var i = 0; i < lstKeyValueMaintainCores.length; i++)
            TableRow(children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
                  child: TextFieldSearch(
                    label: '',
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'item',
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    controller: lstKeyValueMaintainCores[i].key,
                    itemsInView: 10,
                    minStringLength: 0,
                    initialList: ListOrderCoreModel.coreList,
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 12.0, top: 6.0, bottom: 6.0),
                  child: InkWell(
                    onTap: () {
                      _selectDate(i); // Call Function that has showDatePicker()
                    },
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: lstKeyValueMaintainCores[i].value,
                        decoration: const InputDecoration(
                          hintText: 'dd/MM/yyyy',
                          border: InputBorder.none,
                        ),
                        readOnly: true, // Đặt trạng thái cho phép chỉ đọc
                        onTap: () {
                          _selectDate(i); // Gọi hàm để chọn ngày
                        },
                      ),
                    ),
                  ),
                ),
              )
            ])
      ],
    );
  }

  TableRow _buildTableRow({
    required String title,
    required String? content,
    required bool isHighlight,
  }) {
    return TableRow(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            title,
            style: const TextStyle(
                color: ColorUtil.raisinBlack,
                fontWeight: FontWeight.bold,
                height: 1.5),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            "$content",
            style: TextStyle(
                color: isHighlight ? ColorUtil.bangladeshGreen : Colors.black,
                height: 1.5),
          ),
        ),
      ],
    );
  }

  Future _selectDate(int i) async {
    DateTime? picked = await showDatePicker(
        context: context,
        locale: const Locale("vi", "VN"),
        initialDate: DateTime.now().add(const Duration(days: 183)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (lstKeyValueMaintainCores[i].key.text == '') {
      context.showSnackBar("Vui lòng chọn sản phẩm!");
      return;
    }

    if (picked != null) {
      setState(() => lstKeyValueMaintainCores[i].value.text =
          picked.toDateString(format: "dd/MM/yyyy"));
    }
  }

  void _showModalBottomSheetMedia() {
    showModalBottomSheet(
        useSafeArea: true,
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Image'),
                onTap: _onChooseImages,
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void _onChooseImages() async {
    Navigator.of(context).pop();

    List<File>? files = await onGetMultiPhoto(
      context: context,
      funcPermission: () {},
      picker: _picker,
    );

    if (files != null && files.isNotEmpty) {
      List<File> compressedFiles = [];

      for (var file in files) {
        final targetPath = '${file.path}_compressed.jpg';

        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          file.absolute.path,
          targetPath,
          quality: 85,
          format: CompressFormat.jpeg,
          keepExif: true,
        );

        if (compressedFile != null) {
          compressedFiles.add(File(compressedFile.path));
        } else {
          compressedFiles.add(file); // fallback nếu lỗi nén
        }
      }

      if (_listPath.length + compressedFiles.length <= 15) {
        setState(() {
          _isLoading = true;
        });
        _bloc.add(StaffNewOrderUploadImageEvent(compressedFiles));
      } else {
        context.showSnackBar('Chỉ được chọn tối đa 15 ảnh!');
        return;
      }
    }
  }

  Future getImage(
    ImageSource img,
  ) async {
    if (await Permission.camera.request().isGranted) {
      if (_listPath.length >= 15) {
        context.showSnackBar('Chỉ được chọn tối đa 15 ảnh!');
        return;
      } else {
        final picker = ImagePicker();
        File? galleryFile;
        final pickedFile =
            await picker.pickImage(source: img, imageQuality: 30);
        List<File>? files = [];
        if (pickedFile != null) {
          galleryFile = File(pickedFile.path);
          files.add(galleryFile);
          if (_listPath.length + files.length <= 15) {
            setState(() {
              _isLoading = true;
            });
            _bloc.add(StaffNewOrderUploadImageEvent(files));
          } else {
            context.showSnackBar('Chỉ được chọn tối đa 15 ảnh!');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(// is this context <<<
              const SnackBar(content: Text('Nothing is selected')));
        }
      }
    } else {
      CustomAlertDialog.show(
        context,
        leftText: "Cài đặt",
        rightText: "Hủy",
        isLeftPositive: true,
        leftAction: () {
          Navigator.pop(context);
          openAppSettings();
        },
        content: 'Vui lòng cấp quyền truy cập camera.',
      );
    }
  }

  Future<List<File>?> onGetMultiPhoto(
      {required BuildContext context,
      required ImagePicker picker,
      required Function funcPermission}) async {
    if (await Permission.photos.request().isGranted) {
      try {
        final pickedFiles = await picker.pickMultiImage(
          imageQuality: 30,
        );

        if (pickedFiles.isNotEmpty) {
          final List<File> listFile = [];
          for (var item in pickedFiles) {
            File imageFile = File(item.path);
            listFile.add(imageFile);
          }
          return listFile;
        } else {
          // showSnackBarError(context: context, message: 'File error');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } else {
      funcPermission();
    }
    return null;
  }

  Widget _selectNewProduct() {
    List<String> options = _listProductsAll.map((ProductModel sv) {
      return sv.name!;
    }).toList();
    return RawAutocomplete<String>(
      key: _autocompleteKey,
      focusNode: _focusNode,
      textEditingController: currentSelectedProductAllValue,
      optionsBuilder: (TextEditingValue textEditingValue) {
        return options.where((String option) {
          return option
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        }).toList();
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          onFieldSubmitted: (String value) {
            onFieldSubmitted();
          },
          decoration: InputDecoration(
              errorStyle:
                  const TextStyle(color: Colors.redAccent, fontSize: 16.0),
              hintText: 'Thêm sản phẩm mới',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                    color: ColorUtil.bangladeshGreen, width: 0.5),
              ),
              prefixIcon: const Icon(Icons.account_box_outlined)),
        );
      },
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: SizedBox(
              height: 200.0,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      onSelected(option);
                      var add = _listProducts
                              .where((item) =>
                                  item.id.toString() ==
                                  _currentSelectedProductValue.toString())
                              .first
                              .address ??
                          '';
                      addressCustomerControllerSP.text = add;
                    },
                    child: ListTile(
                      title: Text(option),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class KeyValue {
  late TextEditingController key;
  late TextEditingController value;

  //late TextEditingController selectedDate;
  KeyValue(this.key, this.value);
}
