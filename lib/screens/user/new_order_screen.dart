import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_format_money_vietnam/flutter_format_money_vietnam.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socbay/blocs/user_info/user_new_order/user_new_order_event.dart';
import 'package:socbay/blocs/user_info/user_new_order/user_new_order_state.dart';
import 'package:socbay/blocs/user_info/user_new_order/user_new_order_bloc.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/model/list_order_core_model.dart';
import 'package:socbay/data/model/order_filter_core_model.dart';
import 'package:socbay/data/model/product_model.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/date_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/utils/string_extension.dart';
import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/dialog/custom_alert_dialog.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:socbay/widgets/textfield_search.dart';

class UserNewOrderScreen extends StatefulWidget {
  const UserNewOrderScreen({super.key});
  @override
  State<StatefulWidget> createState() => _UserNewOrderScreenState();
}

class _UserNewOrderScreenState extends State<UserNewOrderScreen> {
  late UserNewOrderBloc _bloc;
  int _currentSelectedProductValue = 0;
  DateTime? _nextDay;
  final TextEditingController currentSelectedProductAllValue =
      TextEditingController();
  final List<ProductModel> _listProductsAll = [];
  List<KeyValue> lstKeyValueCores = [];
  List<KeyValue> lstKeyValueMaintainCores = [];

  TextEditingController discountController = TextEditingController();
  TextEditingController subSavePointController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  bool isListProductsSelected = true;
  final List<String> _listPath = [];
  late final ImagePicker _picker;
  bool _isLoading = false;
  final GlobalKey _autocompleteKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    _bloc.add(UserNewOrderGetListProductsAllEvent());
    String dateDefault = DateTime.now()
        .add(const Duration(days: 183))
        .toDateString(format: "dd/MM/yyyy");
    lstKeyValueCores
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
    return BlocConsumer<UserNewOrderBloc, UserNewOrderState>(
        builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, UserNewOrderState state) {
    if (state is UserNewOrderInitialState) {
      setState(() {
        subSavePointController.text = _bloc.subSavePoint.toString();
        _currentSelectedProductValue =
            int.tryParse(_bloc.orderDetail?.productId ?? "") ?? 0;
        _isLoading = _bloc.isLoading;
      });
    }
    if (state is UserNewOrderGetListProductsAllSuccessState) {
      _listProductsAll.clear();
      for (var element in _bloc.listProductsAll) {
        _listProductsAll.add(element);
      }
      setState(() {
        _isLoading = _bloc.isLoading;
      });
    }
    if (state is UserCreateOrderCoresFailState) {
      context.showSnackBarSuccess("Đã có lỗi xảy ra");
      setState(() {
        _isLoading = _bloc.isLoading;
      });
    }
    if (state is UserCreateOrderCoresSuccessState) {
      setState(() {
        _isLoading = _bloc.isLoading;
      });
      Navigator.pushNamed(context, Routes.root);
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
    }
  }

  Widget _builder(BuildContext context, UserNewOrderState state) {
    return Listener(
      child: SafeArea(
          child: Scaffold(
        appBar: MyAppBar(
          title: "Đặt lịch thay lõi",
          isBackNavigation: true,
          centerTitle: true,
        ),
        body: LoadingIndicator(
          isLoading: _isLoading,
          child: Padding(
            padding: const EdgeInsets.only(
                top: 16.0, left: 16.0, right: 10.0, bottom: 0.0),
            child: ListView(
              children: [
                const SizedBox(
                  height: 16.0,
                ),
                _selectNewProduct(),
                _itemFilterCoreTable(),
                _itemFilterCoreMaintainTable(),
                const SizedBox(
                  height: 16.0,
                ),
                _buildSectionMedia(),
                ButtonWidget(
                    onTap: () {
                      final getProductNew = _listProductsAll.where((element) =>
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
                      _bloc.chietKhau = int.tryParse(discountController.text
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
                              name: "Lắp đặt mới",
                              replaceDate: item.key.text,
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
                      _bloc.add(UserCreateOrderEvent(
                          _currentSelectedProductValue,
                          getProductNew.isNotEmpty ? getProductNew.first.id : 0,
                          lst1,
                          lst2,
                          _bloc.total,
                          (int.tryParse(discountController.text
                                  .replaceAll(".", "")
                                  .replaceAll("đ", "")
                                  .nonBreaking
                                  .trim()) ??
                              0),
                          (_bloc.total == 0 && _bloc.totalPay == 0)
                              ? 0
                              : (int.tryParse(subSavePointController.text) ??
                                  0),
                          //(int.tryParse(subSavePointController.text) ?? 0),
                          _bloc.totalPay,
                          _bloc.savePoint,
                          _bloc.paymentType,
                          _listPath));
                    },
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    borderRadius: BorderRadius.circular(30),
                    margin: const EdgeInsets.only(
                        left: 60, right: 60, bottom: 30, top: 20),
                    color: ColorUtil.bangladeshGreen,
                    child: const Text(
                      "THÊM",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ))
              ],
            ),
          ),
        ),
      )),
    );
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
          style: const TextStyle(fontSize: 25.0),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Thêm sản phẩm',
          ),
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
                    child: Text("Ngày thay lõi",
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
                    child: Text("Ngày lắp đặt",
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
                    child: Text("Giá tiền",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              )
            ]),
        if (lstKeyValueCores.isNotEmpty)
          for (var i = 0; i < lstKeyValueCores.length; i++)
            TableRow(children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 12.0, top: 6.0, bottom: 6.0),
                  child: InkWell(
                    onTap: () {
                      _installDate(
                          i); // Call Function that has showDatePicker()
                    },
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: lstKeyValueCores[i].key,
                        decoration: const InputDecoration(
                          hintText: 'dd/MM/yyyy',
                          border: InputBorder.none,
                        ),
                        readOnly: true,
                        onTap: () {
                          _installDate(i);
                        },
                      ),
                    ),
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
                        context.showSnackBar("Vui lòng chọn ngày lắp đặt!");
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
                          var chietkhau = discountController.text;
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
                          _bloc.savePoint = 0;
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
                    child: Text("Đặt lịch thay lõi",
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
                                text: _nextDay?.toDateString(format: "dd/MM/yyyy"))));
                      });
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
                      _nextDate(i); // Call Function that has showDatePicker()
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
                          _nextDate(i); // Gọi hàm để chọn ngày
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
              ),
            ],
          );
        });
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
            _bloc.add(UserNewOrderUploadImageEvent(files));
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

  void _onChooseImages() async {
    Navigator.of(context).pop();
    List<File>? files = await onGetMultiPhoto(
        context: context, funcPermission: () {}, picker: _picker);
    if (files != null && files.isNotEmpty) {
      if (_listPath.length + files.length <= 15) {
        setState(() {
          _isLoading = true;
        });
        _bloc.add(UserNewOrderUploadImageEvent(files));
      } else {
        context.showSnackBar('Chỉ được chọn tối đa 15 ảnh!');
        return;
      }
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

  Future _installDate(int i) async {
    DateTime? picked = await showDatePicker(
        context: context,
        locale: const Locale("vi", "VN"),
        initialDate: DateTime.now(),
        firstDate: DateTime.utc(1965, 1, 1),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (picked != null) {
      setState(() {
        lstKeyValueCores[i].key.text =
            picked.toDateString(format: "dd/MM/yyyy");
        _nextDay = picked.add(const Duration(days: 183));
      });
    }
  }

  Future _nextDate(int i) async {
    DateTime today = DateTime.now();

    DateTime? picked = await showDatePicker(
        context: context,
        locale: const Locale("vi", "VN"),
        initialDate: _nextDay ?? DateTime.now().add(const Duration(days: 183)),
        firstDate: today,
        lastDate: today.add(const Duration(days: 365)));
    if (lstKeyValueMaintainCores[i].key.text == '') {
      context.showSnackBar("Vui lòng chọn sản phẩm!");
      return;
    }
    if (picked != null) {
      setState(() => lstKeyValueMaintainCores[i].value.text =
          picked.toDateString(format: "dd/MM/yyyy"));
    }
  }
}

class KeyValue {
  late TextEditingController key;
  late TextEditingController value;
  KeyValue(this.key, this.value);
}
