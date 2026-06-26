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
import 'package:socbay/utils/string_extension.dart';
import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/dialog/custom_alert_dialog.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:socbay/widgets/textfield_search.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:socbay/application.dart';
import 'package:socbay/data/data_provider/api_endpoints.dart';
import 'package:socbay/data/model/warehouse_model.dart';
import 'package:socbay/utils/auth_http.dart' as http;
import 'dart:convert';

class StaffNewOrderScreen extends StatefulWidget {
  final bool isRent;
  const StaffNewOrderScreen({super.key, this.isRent = false});

  @override
  State<StatefulWidget> createState() => _StaffNewOrderScreen();
}

class _StaffNewOrderScreen extends State<StaffNewOrderScreen> {
  late dynamic _bloc;
  late BillData billData;
  late Map<String, dynamic> billDataMap;
  int _currentSelectedProductValue = 0;
  final TextEditingController currentSelectedProductAllValue =
      TextEditingController();
  final List<OrderModel> _listProducts = [];
  final List<ProductModel> _listProductsAll = [];
  List<KeyValue> lstKeyValueCores = [];
  List<KeyValue> lstKeyValueMaintainCores = [];
  List<String> _ktvWarehouseCores = [];
  bool _isLoadingWarehouse = false;

  bool _showRentalDetails = false;
  DateTime _selectedEndDate = DateTime.now();

  final TextEditingController _rentalDurationController =
      TextEditingController();
  final TextEditingController _depositController = TextEditingController();
  final TextEditingController _monthlyPaymentController =
      TextEditingController();
  final TextEditingController _vatController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

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
    _bloc = BlocProvider.of<StaffNewOrderBloc>(context);
    _bloc.add(StaffNewOrderInitEvent());
    String dateDefault = DateTime.now()
        .add(Duration(days: widget.isRent ? 91 : 183))
        .toDateString(format: "dd/MM/yyyy");
    lstKeyValueCores
      ..add(KeyValue(TextEditingController(), TextEditingController()))
      ..add(KeyValue(TextEditingController(), TextEditingController()))
      ..add(KeyValue(TextEditingController(), TextEditingController()));
    lstKeyValueMaintainCores
      ..add(
        KeyValue(
          TextEditingController(),
          TextEditingController(text: dateDefault),
        ),
      )
      ..add(
        KeyValue(
          TextEditingController(),
          TextEditingController(text: dateDefault),
        ),
      )
      ..add(
        KeyValue(
          TextEditingController(),
          TextEditingController(text: dateDefault),
        ),
      );
    _picker = ImagePicker();
    _fetchKtvWarehouse();
    currentSelectedProductAllValue.addListener(() {
      if (_listProductsAll
          .where(
            (element) => element.name == currentSelectedProductAllValue.text,
          )
          .isNotEmpty) {
        setState(() {
          _currentSelectedProductValue = 0;
          _showRentalDetails = true;
        });
      } else {
        setState(() {
          _showRentalDetails = false;
        });
      }
    });
    _rentalDurationController.addListener(() {
      _calculateEndDate();
    });
    super.initState();
  }

  void _fetchKtvWarehouse() async {
    final user = App.instance.userApp;
    if (user == null) return;
    setState(() {
      _isLoadingWarehouse = true;
    });
    try {
      final url = AppConfig.instance.apiUri(
        ApiEndpoints.listWarehouseByUser(user.id.toString()),
      );
      final response = await http.get(url);
      if (response.statusCode == HttpStatus.ok) {
        final jsonRes = json.decode(response.body);
        if (jsonRes['code'] == 1 &&
            jsonRes['data'] != null &&
            jsonRes['data']['data_wasehouse'] != null) {
          final List<dynamic> whData = jsonRes['data']['data_wasehouse'];
          final whList = warehouseListFromJson(whData);

          final List<String> items = [];
          for (var wh in whList) {
            final name = wh.product?.name;
            final qtyExist =
                double.tryParse(wh.quantityExist ?? '0')?.toInt() ?? 0;
            if (name != null && name.isNotEmpty && qtyExist > 0) {
              items.add(name);
            }
          }

          setState(() {
            _ktvWarehouseCores = items;
            _isLoadingWarehouse = false;
          });
        } else {
          setState(() {
            _isLoadingWarehouse = false;
          });
        }
      } else {
        setState(() {
          _isLoadingWarehouse = false;
        });
      }
    } catch (_) {
      setState(() {
        _isLoadingWarehouse = false;
      });
    }
  }

  void _calculateEndDate() {
    if (_rentalDurationController.text.isNotEmpty) {
      try {
        int rentalDuration = int.parse(_rentalDurationController.text);
        setState(() {
          _selectedEndDate = DateTime.now().add(
            Duration(days: rentalDuration * 30),
          );
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập số ngày hợp lệ.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _bloc.close();
    lstKeyValueCores.clear();
    lstKeyValueMaintainCores.clear();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaffNewOrderBloc, StaffNewOrderState>(
      builder: _builder,
      listener: _listener,
    );
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
      _listProducts.add(
        OrderModel(
          id: 0,
          product: MachineModel(id: 0, name: "--Chọn sản phẩm--"),
        ),
      );

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message)));
    }
  }

  Widget _builder(BuildContext context, StaffNewOrderState state) {
    return Listener(
      onPointerDown: (PointerDownEvent event) =>
          FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F6F8),
          appBar: MyAppBar(title: "Tạo hóa đơn", isBackNavigation: true),
          body: LoadingIndicator(
            isLoading: _isLoading,
            child: ListView(
              addRepaintBoundaries: false,
              padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
              children: [
                _buildCard(
                  children: [
                    _buildSectionTitle(
                      'Thông tin khách hàng',
                      Icons.person_outline,
                    ),
                    _buildInfoRow(
                      'Khách hàng',
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _bloc.taskModel?.customer?.username ?? '',
                              style: const TextStyle(
                                color: ColorUtil.raisinBlack,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            _bloc.taskModel?.customer?.phone ?? '',
                            style: const TextStyle(
                              color: ColorUtil.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Color(0xFFF1F5F9), height: 24),
                    _buildInputRow(
                      'Địa chỉ khách',
                      _buildTextFieldWrapper(
                        TextField(
                          controller: addressCustomerController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Nhập địa chỉ khách hàng...',
                          ),
                        ),
                      ),
                    ),
                    _buildInputRow(
                      'Vị trí lắp đặt',
                      _buildTextFieldWrapper(
                        TextField(
                          controller: addressCustomerControllerSP,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Nhập vị trí lắp đặt...',
                          ),
                        ),
                      ),
                    ),
                    _buildInputRow(
                      'Ghi chú',
                      _buildTextFieldWrapper(
                        TextField(
                          controller: _noteController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Nhập ghi chú...',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                _buildCard(
                  children: [
                    _buildSectionTitle(
                      'Thông tin sản phẩm',
                      Icons.inventory_2_outlined,
                    ),
                    _buildInputRow(
                      'THAY LÕI/SỬA CHỮA CHỌN SẢN PHẨM ĐÃ CÓ',
                      _buildDropdownFieldPruducts(),
                    ),
                    _buildInputRow(
                      'LẮP ĐẶT MÁY MỚI THÌ CHỌN SẢN PHẨM MÁY LỌC NƯỚC',
                      _selectNewProduct(),
                    ),
                  ],
                ),
                if (widget.isRent && _showRentalDetails)
                  _buildCard(
                    children: [
                      _buildSectionTitle(
                        'Chi tiết thuê',
                        Icons.calendar_month_outlined,
                      ),
                      _buildInputRow(
                        'Thời gian thuê (Tháng)',
                        _buildTextFieldWrapper(
                          TextField(
                            controller: _rentalDurationController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Nhập số tháng thuê...',
                            ),
                          ),
                        ),
                      ),
                      _buildInputRow(
                        'Tiền cọc',
                        _buildTextFieldWrapper(
                          TextField(
                            controller: _depositController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Nhập tiền cọc (VNĐ)...',
                            ),
                            onChanged: (text) {
                              if (text.isNotEmpty) {
                                String formattedText = text
                                    .replaceAll('.', '')
                                    .replaceAll('đ', '')
                                    .nonBreaking
                                    .trim()
                                    .toVND();
                                _depositController.value = TextEditingValue(
                                  text: formattedText,
                                  selection: TextSelection.collapsed(
                                    offset: formattedText.length > 2
                                        ? formattedText.length - 2
                                        : formattedText.length,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      _buildInputRow(
                        'Số tiền trả mỗi tháng',
                        _buildTextFieldWrapper(
                          TextField(
                            controller: _monthlyPaymentController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Nhập số tiền trả mỗi tháng (VNĐ)...',
                            ),
                            onChanged: (text) {
                              if (text.isNotEmpty) {
                                String formattedText = text
                                    .replaceAll('.', '')
                                    .replaceAll('đ', '')
                                    .nonBreaking
                                    .trim()
                                    .toVND();
                                _monthlyPaymentController.value =
                                    TextEditingValue(
                                      text: formattedText,
                                      selection: TextSelection.collapsed(
                                        offset: formattedText.length > 2
                                            ? formattedText.length - 2
                                            : formattedText.length,
                                      ),
                                    );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                _itemFilterCoreTable(),
                _itemFilterCoreMaintainTable(),
                _buildCard(
                  children: [
                    _buildSectionTitle('Thanh toán', Icons.payment_outlined),
                    _buildInfoRow(
                      'Tổng tiền',
                      Text(
                        _bloc.total.toString().toVND(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    _buildInputRow(
                      'Chiết khấu',
                      _buildTextFieldWrapper(
                        TextField(
                          controller: chietKhauController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Nhập số tiền chiết khấu (VNĐ)...',
                          ),
                          onChanged: (text) {
                            if (text.isNotEmpty) {
                              var moneyText = text
                                  .replaceAll(".", "")
                                  .replaceAll("đ", "")
                                  .nonBreaking
                                  .trim();
                              int money = int.tryParse(moneyText) ?? 0;
                              if (money > _bloc.total) {
                                context.showSnackBar(
                                  "Chiết khấu không được vượt quá tổng tiền!",
                                );
                                setState(() {
                                  String formattedText = _bloc.total
                                      .toString()
                                      .toVND();
                                  chietKhauController.value = TextEditingValue(
                                    text: formattedText,
                                    selection: TextSelection.collapsed(
                                      offset: formattedText.length > 2
                                          ? formattedText.length - 2
                                          : formattedText.length,
                                    ),
                                  );
                                  _recalculateTotal();
                                });
                              } else {
                                setState(() {
                                  String formattedText = moneyText.toVND();
                                  chietKhauController.value = TextEditingValue(
                                    text: formattedText,
                                    selection: TextSelection.collapsed(
                                      offset: formattedText.length > 2
                                          ? formattedText.length - 2
                                          : formattedText.length,
                                    ),
                                  );
                                  _recalculateTotal();
                                });
                              }
                            } else {
                              setState(() {
                                _recalculateTotal();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    _buildInputRow(
                      'Trừ tích điểm',
                      _buildTextFieldWrapper(
                        TextField(
                          controller: subSavePointController,
                          style: const TextStyle(color: ColorUtil.red),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Nhập điểm cần trừ...',
                          ),
                          onChanged: (text) {
                            if (text.isNotEmpty) {
                              int subPoints = int.tryParse(text) ?? 0;
                              var chietkhau = chietKhauController.text;
                              int discount =
                                  int.tryParse(
                                    chietkhau
                                        .replaceAll(".", "")
                                        .replaceAll("đ", "")
                                        .nonBreaking
                                        .trim(),
                                  ) ??
                                  0;
                              int maxAllowedPointsValue =
                                  _bloc.total - discount;
                              if (maxAllowedPointsValue < 0) {
                                maxAllowedPointsValue = 0;
                              }
                              int maxAllowedPoints =
                                  maxAllowedPointsValue ~/ 1000;

                              if (subPoints > _bloc.subSavePoint) {
                                context.showSnackBar("Không đủ điểm!");
                                setState(() {
                                  subSavePointController.text = _bloc
                                      .subSavePoint
                                      .toString();
                                  _recalculateTotal();
                                });
                              } else if (subPoints > maxAllowedPoints) {
                                context.showSnackBar(
                                  "Số điểm trừ không được vượt quá số tiền thanh toán!",
                                );
                                setState(() {
                                  subSavePointController.text = maxAllowedPoints
                                      .toString();
                                  _recalculateTotal();
                                });
                              } else {
                                setState(() {
                                  _recalculateTotal();
                                });
                              }
                            } else {
                              setState(() {
                                _recalculateTotal();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    _buildInputRow(
                      'Thuế VAT (%)',
                      _buildTextFieldWrapper(
                        TextField(
                          controller: _vatController,
                          style: const TextStyle(color: ColorUtil.red),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Nhập % VAT...',
                          ),
                          onChanged: (text) {
                            setState(() {
                              _recalculateTotal();
                            });
                          },
                        ),
                      ),
                    ),
                    const Divider(color: Color(0xFFF1F5F9), height: 32),
                    _buildInfoRow(
                      'Tổng thanh toán',
                      Text(
                        _bloc.totalPay.toString().toVND(),
                        style: const TextStyle(
                          color: ColorUtil.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    _buildInfoRow(
                      'Tích điểm',
                      Text(
                        _bloc.savePoint.toString(),
                        style: const TextStyle(
                          color: ColorUtil.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Hình thức thanh toán:',
                      style: TextStyle(
                        color: ColorUtil.raisinBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RadioGroup<int>(
                      groupValue: _bloc.paymentType,
                      onChanged: (int? value) {
                        if (value == null) return;

                        setState(() {
                          _bloc.paymentType = value;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _paymentItem('Tiền mặt', 1),
                          _paymentItem('Chuyển khoản', 2),
                          _paymentItem('Ví', 3),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                _buildSectionMedia(),
                ButtonWidget(
                  onTap: () {
                    var getProductNew = _listProductsAll.where(
                      (element) =>
                          element.name == currentSelectedProductAllValue.text,
                    );
                    if (_currentSelectedProductValue == 0 &&
                        getProductNew.isEmpty) {
                      context.showSnackBar('Vui lòng chọn sản phẩm');
                      return;
                    }
                    List<OrderFilterCoreModel> lst1 = [];
                    List<OrderFilterCoreModel> lst2 = [];
                    for (var item in lstKeyValueCores) {
                      if (item.key.text.isNotEmpty) {
                        String priceText = item.value.text.trim();
                        String priceValue = priceText.isEmpty
                            ? "0"
                            : priceText
                                  .replaceAll(".", "")
                                  .replaceAll("đ", "")
                                  .nonBreaking
                                  .trim();
                        lst1.add(
                          OrderFilterCoreModel(
                            name: item.key.text,
                            price: priceValue,
                          ),
                        );
                      }
                    }
                    for (var item in lstKeyValueMaintainCores) {
                      if (item.key.text.isNotEmpty) {
                        lst2.add(
                          OrderFilterCoreModel(
                            name: item.key.text,
                            replaceDatePromise: item.value.text,
                          ),
                        );
                      }
                    }
                    if (lst1.isEmpty) {
                      context.showSnackBar('Chưa nhập chi tiết lần thay lõi');
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
                      discount:
                          int.tryParse(
                            chietKhauController.text
                                .replaceAll(".", "")
                                .replaceAll("đ", "")
                                .nonBreaking
                                .trim(),
                          ) ??
                          0,
                      vat: int.tryParse(_vatController.text) ?? 0,
                      totalPay: _bloc.totalPay,
                      savePoint: _bloc.savePoint,
                      subSavePoint: (_bloc.total == 0 && _bloc.totalPay == 0)
                          ? 0
                          : (int.tryParse(subSavePointController.text) ?? 0),
                      paymentType: _bloc.paymentType,
                      images: _listPath,
                      staff: _bloc.taskModel?.staff?.username,
                      ghichu: _noteController.text,
                    );

                    Navigator.pushNamed(
                      context,
                      Routes.billScreen,
                      arguments: billData,
                    ).then(
                      (value) => {
                        if (value != null && value is List<File>)
                          {
                            setState(() {
                              _bloc.add(StaffNewOrderUploadImageEvent(value));
                            }),
                          }
                        else
                          {context.showSnackBar('Chưa lưu ảnh hóa đơn')},
                      },
                    );
                  },
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  borderRadius: BorderRadius.circular(30),
                  margin: const EdgeInsets.only(
                    left: 60.0,
                    right: 60,
                    bottom: 10,
                    top: 10,
                  ),
                  color: ColorUtil.green,
                  child: const Text(
                    "Hóa đơn điện tử",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                ButtonWidget(
                  onTap: () {
                    var getProductNew = _listProductsAll.where(
                      (element) =>
                          element.name == currentSelectedProductAllValue.text,
                    );
                    if (_currentSelectedProductValue == 0 &&
                        getProductNew.isEmpty) {
                      context.showSnackBar('Vui lòng chọn sản phẩm');
                      return;
                    }
                    _bloc.total =
                        int.tryParse(
                          _bloc.total
                              .toString()
                              .replaceAll(".", "")
                              .replaceAll("đ", "")
                              .nonBreaking
                              .trim(),
                        ) ??
                        0;
                    _bloc.chietKhau =
                        int.tryParse(
                          chietKhauController.text
                              .replaceAll(".", "")
                              .replaceAll("đ", "")
                              .nonBreaking
                              .trim(),
                        ) ??
                        0;
                    _bloc.subSavePoint =
                        int.tryParse(
                          subSavePointController.text
                              .replaceAll(".", "")
                              .replaceAll("đ", "")
                              .nonBreaking
                              .trim(),
                        ) ??
                        0;
                    _bloc.totalPay =
                        int.tryParse(
                          _bloc.totalPay
                              .toString()
                              .replaceAll(".", "")
                              .replaceAll("đ", "")
                              .nonBreaking
                              .trim(),
                        ) ??
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
                        String priceText = item.value.text.trim();
                        String priceValue = priceText.isEmpty
                            ? "0"
                            : priceText
                                  .replaceAll(".", "")
                                  .replaceAll("đ", "")
                                  .nonBreaking
                                  .trim();
                        lst1.add(
                          OrderFilterCoreModel(
                            name: item.key.text,
                            price: priceValue,
                          ),
                        );
                      }
                    }
                    for (var item in lstKeyValueMaintainCores) {
                      if (item.key.text.isNotEmpty) {
                        lst2.add(
                          OrderFilterCoreModel(
                            name: item.key.text,
                            replaceDatePromise: item.value.text,
                          ),
                        );
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

                    _bloc.add(
                      StaffCreateOrderEvent(
                        _currentSelectedProductValue,
                        getProductNew.isNotEmpty ? getProductNew.first.id : 0,
                        lst1,
                        lst2,
                        _bloc.total,
                        (int.tryParse(
                              chietKhauController.text
                                  .replaceAll(".", "")
                                  .replaceAll("đ", "")
                                  .nonBreaking
                                  .trim(),
                            ) ??
                            0),
                        (_bloc.total == 0 && _bloc.totalPay == 0)
                            ? 0
                            : (int.tryParse(subSavePointController.text) ?? 0),
                        _bloc.totalPay,
                        _bloc.savePoint,
                        _bloc.paymentType,
                        _vatController.text.isEmpty ? '0' : _vatController.text,
                        _listPath,
                        addressCustomerController.text,
                        addressCustomerControllerSP.text,
                        widget.isRent ? _rentalDurationController.text : '0',
                        widget.isRent
                            ? _depositController.text
                                  .replaceAll(".", "")
                                  .replaceAll("đ", "")
                                  .nonBreaking
                                  .trim()
                            : '0',
                        widget.isRent
                            ? _monthlyPaymentController.text
                                  .replaceAll(".", "")
                                  .replaceAll("đ", "")
                                  .nonBreaking
                                  .trim()
                            : '0',
                        widget.isRent ? _selectedEndDate : DateTime.now(),
                        _noteController.text,
                      ),
                    );
                  },
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  borderRadius: BorderRadius.circular(30),
                  margin: const EdgeInsets.only(
                    left: 60.0,
                    right: 60,
                    bottom: 60,
                    top: 10,
                  ),
                  color: ColorUtil.bangladeshGreen,
                  child: const Text(
                    "HOÀN THÀNH",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionMedia() {
    return _buildCard(
      children: [
        _buildSectionTitle('Đính kèm', Icons.attach_file_outlined),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.cloud_upload_outlined,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Tải ảnh/video lên để kỹ thuật xem xét (tối đa 15 ảnh, video < 15s).',
                      style: TextStyle(
                        color: ColorUtil.spanishGray,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
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
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultItemMedia() {
    return GestureDetector(
      onTap: _showModalBottomSheetMedia,
      child: Container(
        height: 120,
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: Colors.grey,
              size: 32,
            ),
            SizedBox(height: 8),
            Text('Thêm', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
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
                height: 200,
              ),
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
              ),
            ),
          ],
        ),
        const SizedBox(width: 5.0),
      ],
    );
  }

  Widget _buildDropdownFieldPruducts() {
    return FormField<String>(
      builder: (FormFieldState<String> state) {
        return InputDecorator(
          decoration: InputDecoration(
            errorStyle: const TextStyle(
              color: Colors.redAccent,
              fontSize: 16.0,
            ),
            hintText: 'Please select expense',
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: ColorUtil.bangladeshGreen,
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: ColorUtil.bangladeshGreen,
                width: 0.5,
              ),
            ),
            prefixIcon: const Icon(Icons.account_box_outlined),
          ),
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
                      var add =
                          _listProducts
                              .where(
                                (item) =>
                                    item.id.toString() ==
                                    _currentSelectedProductValue.toString(),
                              )
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
    return _buildCard(padding: EdgeInsets.zero, children: [_tableAction()]);
  }

  Widget _itemFilterCoreMaintainTable() {
    return _buildCard(
      padding: EdgeInsets.zero,
      children: [_tableActionMaintain()],
    );
  }

  Widget _tableAction() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: ColorUtil.bangladeshGreen,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Vật tư thay thế",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    lstKeyValueCores.add(
                      KeyValue(
                        TextEditingController(),
                        TextEditingController(),
                      ),
                    );
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
        Container(
          color: const Color(0xFFFFF3CD),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  "Tên lõi",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ColorUtil.raisinBlack,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text.rich(
                  TextSpan(
                    text: "Thành tiền (VNĐ) ",
                    children: [
                      TextSpan(
                        text: "*",
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ColorUtil.raisinBlack,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (lstKeyValueCores.isNotEmpty)
          ...List.generate(
            lstKeyValueCores.length,
            (i) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _isLoadingWarehouse
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : TextFormField(
                            controller: lstKeyValueCores[i].key,
                            readOnly: !lstKeyValueCores[i].isManualInput,
                            onTap: lstKeyValueCores[i].isManualInput
                                ? null
                                : () {
                                    _showCoreSearchSelector(context, i);
                                  },
                            decoration: InputDecoration(
                              hintText: lstKeyValueCores[i].isManualInput
                                  ? 'Nhập trường hợp khác'
                                  : (_ktvWarehouseCores.isEmpty
                                        ? 'Kho trống!'
                                        : 'Chọn lõi/máy...'),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              suffixIcon:
                                  lstKeyValueCores[i].key.text.isNotEmpty
                                  ? IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.clear, size: 16),
                                      onPressed: () {
                                        setState(() {
                                          lstKeyValueCores[i].key.clear();
                                          lstKeyValueCores[i].value.clear();
                                          lstKeyValueCores[i].isManualInput =
                                              false;
                                          _recalculateTotal();
                                        });
                                      },
                                    )
                                  : const Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.grey,
                                    ),
                            ),
                            style: const TextStyle(fontSize: 13),
                          ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: lstKeyValueCores[i].value,
                      textAlign: TextAlign.right,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: '0',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      onChanged: (text) {
                        if (lstKeyValueCores[i].key.text == '') {
                          lstKeyValueCores[i].value.text = '';
                          context.showSnackBar("Vui lòng chọn sản phẩm!");
                          return;
                        } else {
                          setState(() {
                            String formattedText = (text.isEmpty ? "0" : text)
                                .replaceAll(".", "")
                                .replaceAll("đ", "")
                                .nonBreaking
                                .trim()
                                .toVND();
                            lstKeyValueCores[i].value.value = TextEditingValue(
                              text: formattedText,
                              selection: TextSelection.collapsed(
                                offset: formattedText.length > 2
                                    ? formattedText.length - 2
                                    : formattedText.length,
                              ),
                            );
                            _recalculateTotal();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        lstKeyValueCores.removeAt(i);
                        _recalculateTotal();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _tableActionMaintain() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: ColorUtil.bangladeshGreen,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Hẹn lịch bảo dưỡng",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    lstKeyValueMaintainCores.add(
                      KeyValue(
                        TextEditingController(),
                        TextEditingController(
                          text: DateTime.now()
                              .add(const Duration(days: 183))
                              .toDateString(format: "dd/MM/yyyy"),
                        ),
                      ),
                    );
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
        Container(
          color: const Color(0xFFFFF3CD),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  "Tên lõi",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ColorUtil.raisinBlack,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  "Ngày thay tiếp theo",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ColorUtil.raisinBlack,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (lstKeyValueMaintainCores.isNotEmpty)
          ...List.generate(
            lstKeyValueMaintainCores.length,
            (i) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFieldSearch(
                      label: '',
                      decoration: InputDecoration(
                        hintText: 'Tên lõi...',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      controller: lstKeyValueMaintainCores[i].key,
                      itemsInView: 10,
                      minStringLength: 0,
                      initialList: ListOrderCoreModel.coreList,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () => _selectDate(i),
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: lstKeyValueMaintainCores[i].value,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: 'dd/MM/yyyy',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                          readOnly: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (lstKeyValueMaintainCores[i].key.text == '') {
      context.showSnackBar("Vui lòng chọn sản phẩm!");
      return;
    }

    if (picked != null) {
      setState(
        () => lstKeyValueMaintainCores[i].value.text = picked.toDateString(
          format: "dd/MM/yyyy",
        ),
      );
    }
  }

  void _recalculateTotal() {
    _bloc.total = 0;
    for (var item in lstKeyValueCores) {
      _bloc.total +=
          int.tryParse(
            item.value.text
                .replaceAll(".", "")
                .replaceAll("đ", "")
                .nonBreaking
                .trim(),
          ) ??
          0;
    }

    var chietkhau = chietKhauController.text;
    int discount =
        int.tryParse(
          chietkhau.replaceAll(".", "").replaceAll("đ", "").nonBreaking.trim(),
        ) ??
        0;

    if (discount > _bloc.total) {
      discount = _bloc.total;
      chietKhauController.value = TextEditingValue(
        text: discount.toString().toVND(),
        selection: TextSelection.collapsed(
          offset: discount.toString().toVND().length > 2
              ? discount.toString().toVND().length - 2
              : discount.toString().toVND().length,
        ),
      );
    }

    int subPoints = int.tryParse(subSavePointController.text) ?? 0;
    int maxAllowedPointsValue = _bloc.total - discount;
    if (maxAllowedPointsValue < 0) {
      maxAllowedPointsValue = 0;
    }
    int maxAllowedPoints = maxAllowedPointsValue ~/ 1000;

    int maxPointsLimit = _bloc.subSavePoint;
    if (maxPointsLimit > maxAllowedPoints) {
      maxPointsLimit = maxAllowedPoints;
    }

    if (subPoints > maxPointsLimit) {
      subPoints = maxPointsLimit;
      if (subSavePointController.text != subPoints.toString()) {
        subSavePointController.text = subPoints.toString();
      }
    }

    int subSavePointVal = subPoints * 1000;
    int baseAmount = _bloc.total - discount - subSavePointVal;
    if (baseAmount < 0) {
      baseAmount = 0;
    }

    double vatPercent = double.tryParse(_vatController.text) ?? 0;
    _bloc.vatPercentage = vatPercent;
    _bloc.vatAmount = (baseAmount * vatPercent / 100).round();

    _bloc.totalPay = baseAmount + _bloc.vatAmount;
    _bloc.savePoint = (_bloc.totalPay * 3 / 100000).ceil();
  }

  void _showCoreSearchSelector(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        String searchQuery = "";
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final List<String> filteredList = [];
            const String manualOption = "Lắp đặt, VSBD, Khác";
            if (searchQuery.isEmpty ||
                manualOption.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                )) {
              filteredList.add(manualOption);
            }
            filteredList.addAll(
              _ktvWarehouseCores.where(
                (core) =>
                    core.toLowerCase().contains(searchQuery.toLowerCase()),
              ),
            );

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Chọn lõi / máy',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm lõi...',
                          prefixIcon: const Icon(Icons.search),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            searchQuery = val;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: filteredList.isEmpty
                          ? const Center(
                              child: Text(
                                'Không tìm thấy lõi phù hợp',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredList.length,
                              itemBuilder: (context, i) {
                                final item = filteredList[i];
                                return ListTile(
                                  title: Text(
                                    item,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if (item == manualOption) {
                                        lstKeyValueCores[index].isManualInput =
                                            true;
                                        lstKeyValueCores[index].key.text = "";
                                      } else {
                                        lstKeyValueCores[index].isManualInput =
                                            false;
                                        lstKeyValueCores[index].key.text = item;
                                      }
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
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

  void _showModalBottomSheetMedia() {
    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
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
              ),
            ],
          ),
        );
      },
    );
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

  Future getImage(ImageSource img) async {
    if (await Permission.camera.request().isGranted) {
      if (_listPath.length >= 15) {
        context.showSnackBar('Chỉ được chọn tối đa 15 ảnh!');
        return;
      } else {
        final picker = ImagePicker();
        File? galleryFile;
        final pickedFile = await picker.pickImage(
          source: img,
          imageQuality: 30,
        );
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
          ScaffoldMessenger.of(context).showSnackBar(
            // is this context <<<
            const SnackBar(content: Text('Nothing is selected')),
          );
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

  Future<List<File>?> onGetMultiPhoto({
    required BuildContext context,
    required ImagePicker picker,
    required Function funcPermission,
  }) async {
    bool isGranted = true;
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      isGranted = await Permission.photos.request().isGranted;
    }
    if (isGranted) {
      try {
        final pickedFiles = await picker.pickMultiImage(imageQuality: 30);

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
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
          return option.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        }).toList();
      },
      fieldViewBuilder:
          (
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
                errorStyle: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16.0,
                ),
                hintText: 'Thêm sản phẩm mới',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: ColorUtil.bangladeshGreen,
                    width: 0.5,
                  ),
                ),
                prefixIcon: const Icon(Icons.account_box_outlined),
              ),
            );
          },
      optionsViewBuilder:
          (
            BuildContext context,
            AutocompleteOnSelected<String> onSelected,
            Iterable<String> options,
          ) {
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
                          var add =
                              _listProducts
                                  .where(
                                    (item) =>
                                        item.id.toString() ==
                                        _currentSelectedProductValue.toString(),
                                  )
                                  .first
                                  .address ??
                              '';
                          addressCustomerControllerSP.text = add;
                        },
                        child: ListTile(title: Text(option)),
                      );
                    },
                  ),
                ),
              ),
            );
          },
    );
  }

  Widget _buildCard({
    required List<Widget> children,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorUtil.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: ColorUtil.green, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorUtil.raisinBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, Widget valueWidget) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                color: ColorUtil.spanishGray,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(flex: 3, child: valueWidget),
        ],
      ),
    );
  }

  Widget _buildInputRow(String title, Widget inputWidget) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: ColorUtil.raisinBlack,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          inputWidget,
        ],
      ),
    );
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

  Widget _paymentItem(String title, int value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _bloc.paymentType = value;
        });
      },
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 4),
          Radio<int>(value: value),
        ],
      ),
    );
  }
}

class KeyValue {
  late TextEditingController key;
  late TextEditingController value;
  bool isManualInput;

  //late TextEditingController selectedDate;
  KeyValue(this.key, this.value, {this.isManualInput = false});
}
