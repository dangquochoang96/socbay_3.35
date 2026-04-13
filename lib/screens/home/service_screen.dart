import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/history/history_screen_bloc.dart';
import 'package:socbay/blocs/history/history_screen_event.dart';
import 'package:socbay/blocs/home/service/service_screen_bloc.dart';
import 'package:socbay/blocs/home/service/service_screen_event.dart';
import 'package:socbay/blocs/home/service/service_screen_state.dart';
import 'package:socbay/blocs/tab_bar/tab_bar_bloc.dart';
import 'package:socbay/blocs/tab_bar/tab_bar_event.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/home_service_model.dart';
import 'package:socbay/data/model/machine_model.dart';
import 'package:socbay/data/model/order_model.dart';
import 'package:socbay/data/model/request/create_task_request.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/screens/home_tab_bar/tab_bar_screen.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/date_util.dart';
import 'package:socbay/utils/file_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/dialog/custom_alert_dialog.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:image/image.dart' as img;

import 'package:location/location.dart' as location_dart;

import '../staff/technique/technique_screen.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({Key? key}) : super(key: key);

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  late ServiceScreenBloc _bloc;
  late TextEditingController staffFavoriteTxtController;
  late TextEditingController describeRequestTxtController;
  late TextEditingController addressRequestTxtController;
  late TextEditingController addressSPRequestTxtController;
  location_dart.LocationData? locationData;
  List<HomeServiceModel> _listService = [];
  final List<OrderModel> _listProducts = [];
  // List<String?> _listNameService = [];
  final List<String> _listPath = [];
  String? _currentSelectedValue;
  int _currentSelectedProductValue = 0;
  String _dateStart = '';
  String _timeStart = '';
  // UserAddress? _userAddress;
  UserProfile? _favouriteStaff;
  // int? _serviceId;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  late final ImagePicker _picker;
  late TabBarBloc _tabBarBloc;
  late HistoryScreenBloc _historyScreenBloc;

  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    _bloc.add(ServiceScreenUserAddressEvent());
    _tabBarBloc = BlocProvider.of<TabBarBloc>(context);
    _historyScreenBloc = BlocProvider.of<HistoryScreenBloc>(context);
    staffFavoriteTxtController = TextEditingController();
    describeRequestTxtController = TextEditingController();
    addressRequestTxtController = TextEditingController();
    addressSPRequestTxtController = TextEditingController();

    addressRequestTxtController.text = App.instance.userApp?.address ?? "";
    _listService = _bloc.listService;
    _listProducts.add(
        OrderModel(id: 0, product: MachineModel(id: 0, name: "--Chọn máy--")));
    _currentSelectedValue = _listService.isNotEmpty
        ? _listService[int.tryParse(_bloc.args['index']) ?? 0].id.toString()
        : "0";
    _picker = ImagePicker();
    if (selectedDate != null) {
      setState(() {
        _dateStart = selectedDate!.toDateString(format: 'dd/MM/yyyy');
      });
    } else {
      setState(() {
        _dateStart = DateTime.now().toDateString(format: 'dd/MM/yyyy');
      });
    }
    if (selectedTime != null) {
      setState(() {
        _timeStart = selectedTime!.toTimeString();
      });
    } else {
      setState(() {
        // _timeStart = TimeOfDay.now().toTimeString();
        _timeStart = DateFormat('HH:mm').format(DateTime.now());
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    // _tabBarBloc.close();
    _historyScreenBloc.close();
    staffFavoriteTxtController.dispose();
    describeRequestTxtController.dispose();
    addressRequestTxtController.dispose();
    addressSPRequestTxtController.dispose();
    _listService.clear();
    _listProducts.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ServiceScreenBloc, ServiceScreenState>(
        builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, ServiceScreenState state) {
    if (state is ServiceScreenUserAddressSuccessState) {
      for (var element in _bloc.listProducts) {
        if (element.product != null) {
          _listProducts.add(element);
        }
      }
      _listService = _bloc.listService;
      _currentSelectedValue = _listService.isNotEmpty
          ? _listService[int.tryParse(_bloc.args['index']) ?? 0].id.toString()
          : "0";
      _currentSelectedProductValue = int.parse(_bloc.productId);
      _currentSelectedValue = _currentSelectedProductValue > 0 ? "2" : "1";
    }

    if (state is ServiceScreenChangeTypeServiceState) {
      _currentSelectedValue = state.typeService;
    }

    if (state is ServiceScreenCreateTaskSuccessState) {
      CustomAlertDialog.show(
        context,
        content: "Đăng ký dịch vụ thành công",
        leftText: "Ok",
        isLeftPositive: true,
        backListener: () {},
        isShowTitle: false,
        leftAction: () async {
          _tabBarBloc.add(const TabBarPressed(index: 1));
          _historyScreenBloc.add(HistoryScreenTabPressEvent(0));
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TabBarScreen()),
          );
        },
      );
    }

    if (state is ServiceScreenCreateTaskFailedState) {
      context.showSnackBar(state.message);
    }

    if (state is ServiceScreenUploadImageSuccessState) {
      // _listPath.clear();
      for (var element in state.paths) {
        _listPath.add(element);
      }
    }
  }

  Widget _builder(BuildContext context, ServiceScreenState state) {
    return Scaffold(
        appBar: MyAppBar(
          isBackNavigation: true,
          title: 'Đăng ký dịch vụ',
          centerTitle: true,
          onBack: () {
            // Navigator.pushNamed(context, Routes.root);
            Navigator.pop(context);
          },
        ),
        body: LoadingIndicator(
          isLoading: _bloc.isLoading,
          child: SafeArea(
            child: Scaffold(
              body: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: paddingHorizontal, vertical: paddingVertical),
                children: [
                  _buildDropdownField(),
                  const SizedBox(
                    height: 10,
                  ),
                  _buildDropdownFieldPruducts(),
                  const SizedBox(
                    height: 10,
                  ),
                  _buildFormDoubleHorizontal(
                      'Hẹn lịch', Icons.calendar_today, Icons.av_timer_sharp,
                      firstValue: _dateStart,
                      secondValue: _timeStart,
                      onTapFirst: _onTapDateStart,
                      onTapSecond: _onTapTimeStart),
                  const SizedBox(
                    height: 10,
                  ),
                  _buildField('', 'Thợ ưa thích', Icons.person_outlined, null,
                      value: _favouriteStaff?.username ?? "", onTap: () {
                    _onChooseFavoriteStaff();
                  }),
                  const SizedBox(
                    height: 10,
                  ),
                  _buildFormDescribe(
                      'Mô tả yêu cầu',
                      describeRequestTxtController,
                      Icons.description_outlined,
                      null),
                  const SizedBox(
                    height: 10,
                  ),
                  _buildSectionMedia(),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 16),
                    child: Row(
                      children: [
                        _buildButton(
                            text: 'ĐẶT LỊCH',
                            isPositive: true,
                            action: () {
                              _onCreateTask();
                            }),
                        const SizedBox(
                          width: 16,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  Future _onCreateTask() async {
    if (_currentSelectedValue == "") {
      context.showSnackBar("Vui lòng chọn loại dịch vụ!");
      return;
    }
    if (_dateStart.isEmpty || _timeStart.isEmpty) {
      context.showSnackBar("Vui lòng chọn ngày và giờ bắt đầu!");
      return;
    }
    String? serviceName;
    for (var i in _listService) {
      if (i.id == int.parse(_currentSelectedValue ?? "1")) {
        serviceName = i.name;
      }
    }
    var orderDetailId = _listProducts
        .where((element) => element.id == _currentSelectedProductValue)
        .first
        .id;
    _bloc.add(ServiceScreenCreateTaskEvent(
        CreateTaskRequest(
          type: 1,
          name: serviceName,
          des: describeRequestTxtController.text,
          status: _favouriteStaff?.id == null ? 1 : 5,
          priority: 1,
          serviceId: int.parse(_currentSelectedValue ?? "1"),
          //NOTE
          timeStart: '$_dateStart $_timeStart',
          timeEnd: '',
          staffId: _favouriteStaff?.id,
          video: '',
          productId: orderDetailId,
          images: _listPath,
          address: addressSPRequestTxtController.text,
        ),
        false));
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
                'Up ảnh (tối đa 4 ảnh) và video (tối đa 15s) để kỹ thuật xem xét.',
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
                  url: "$protocol${AppConfig.instance.values.apiUrl}" + path,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputDecorator(
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
            prefixIcon: const Icon(Icons.account_box_outlined),
          ),
          isEmpty: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _currentSelectedProductValue.toString(),
                  isDense: true,
                  isExpanded: true,
                  onChanged: (String? newValue) {
                    setState(() {
                      _currentSelectedProductValue = int.parse(newValue ?? "0");
                      var add = _listProducts
                              .where((item) =>
                                  item.id.toString() ==
                                  _currentSelectedProductValue.toString())
                              .first
                              .address ??
                          '';
                      addressSPRequestTxtController.text = add;
                      // print(jsonEncode(_listProducts.where((element) => element.id.toString() == newValue).first.address));
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
            ],
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          readOnly: false,
          controller: addressSPRequestTxtController,
          maxLines: 2,
          cursorColor: ColorUtil.bangladeshGreen,
          decoration: InputDecoration(
            prefixIcon: SizedBox(
              width: 20,
              height: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                    child: Icon(Icons.account_box_outlined),
                  ),
                ],
              ),
            ),
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
            hintText: 'Vị trí lắp đặt',
            hintStyle:
                const TextStyle(color: ColorUtil.silverChalice, fontSize: 13),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 3, horizontal: 1),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
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
          isEmpty: _currentSelectedValue == '',
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _currentSelectedValue,
              isDense: true,
              onChanged: (String? newValue) {
                _bloc.add(ServiceScreenChangeTypeServiceEvent(newValue!));
              },
              items: _listService.map((HomeServiceModel sv) {
                return DropdownMenuItem<String>(
                  value: sv.id.toString(),
                  child: Text(sv.name ?? ""),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormDoubleHorizontal(
    String titleTextField,
    IconData iconPrefixFirst,
    IconData iconPrefixSecond, {
    required String firstValue,
    required String secondValue,
    required void Function() onTapFirst,
    required void Function() onTapSecond,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titleTextField,
          style: const TextStyle(color: ColorUtil.raisinBlack, fontSize: 15),
        ),
        const SizedBox(
          height: 5,
        ),
        Row(children: [
          Expanded(
              flex: 2,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                        color: ColorUtil.bangladeshGreen, width: 0.5)),
                child: GestureDetector(
                    onTap: onTapFirst,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Icon(
                            iconPrefixFirst,
                            color: ColorUtil.spanishGray,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                            child: Text(
                                firstValue.isEmpty ? 'dd/MM/yyyy' : firstValue,
                                style: TextStyle(
                                    color: firstValue.isEmpty
                                        ? ColorUtil.silverChalice
                                        : ColorUtil.raisinBlack)))
                      ],
                    )),
              )),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border:
                      Border.all(color: ColorUtil.bangladeshGreen, width: 0.5)),
              child: GestureDetector(
                onTap: onTapSecond,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Icon(
                        iconPrefixSecond,
                        color: ColorUtil.spanishGray,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Flexible(
                        child: Text(secondValue.isEmpty ? 'hh:mm' : secondValue,
                            style: TextStyle(
                                color: secondValue.isEmpty
                                    ? ColorUtil.silverChalice
                                    : ColorUtil.raisinBlack)))
                  ],
                ),
              ),
            ),
          )
        ])
      ],
    );
  }

  Widget _buildField(
    String titleTextField,
    String hint,
    IconData iconPrefix,
    IconData? iconSuffix, {
    required String value,
    required void Function() onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
            visible: titleTextField == '' ? false : true,
            child: Text(
              titleTextField,
              style:
                  const TextStyle(color: ColorUtil.raisinBlack, fontSize: 15),
            )),
        const SizedBox(
          height: 5,
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
              height: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border:
                      Border.all(color: ColorUtil.bangladeshGreen, width: 0.5)),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Icon(
                      iconPrefix,
                      color: ColorUtil.spanishGray,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(value.isEmpty ? hint : value,
                        style: TextStyle(
                            color: value.isEmpty
                                ? ColorUtil.silverChalice
                                : ColorUtil.raisinBlack),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      iconSuffix,
                      color: ColorUtil.spanishGray,
                    ),
                  ),
                ],
              )),
        ),
      ],
    );
  }

  Widget _buildFormDescribe(
    String placeHolder,
    TextEditingController controller,
    IconData iconPrefix,
    IconData? iconSuffix, {
    // bool isNumberType = false,
    bool isReadOnly = false,
    bool haveSuffixIcon = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 5),
          child: TextFormField(
              readOnly: isReadOnly,
              keyboardType: TextInputType.multiline,
                  // isNumberType ? TextInputType.phone : TextInputType.text,
              controller: controller,
              maxLines: 5,
              cursorColor: ColorUtil.bangladeshGreen,
              decoration: InputDecoration(
                prefixIcon: SizedBox(
                  width: 20,
                  height: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 5.0),
                        child: Icon(iconPrefix),
                      ),
                    ],
                  ),
                ),
                suffixIcon: haveSuffixIcon ? Icon(iconSuffix) : null,
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
                hintText: placeHolder,
                hintStyle: const TextStyle(
                    color: ColorUtil.silverChalice, fontSize: 13),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                suffixIconConstraints:
                    const BoxConstraints(minHeight: 20, minWidth: 20),
              )),
        ),
      ],
    );
  }

  Widget _buildButton({text, isPositive, action}) {
    return Expanded(
        child: isPositive
            ? _button(isPositive, action, text)
            : ElevatedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(vertical: 10)),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(ColorUtil.white),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(
                        color: ColorUtil.bangladeshGreen,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                child: Text(
                  text,
                  style: const TextStyle(color: ColorUtil.bangladeshGreen),
                ),
                onPressed: () {
                  if (action == null) {
                    Navigator.pop(context);
                  } else {
                    action();
                  }
                },
              ));
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
        ));
  }

  void _onChooseFavoriteStaff() {
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => TechniqueScreen(
        initialTabIndex: 1,
        favoriteStaff: _favouriteStaff,
      ),
    ))
        .then((value) {
      Map<String, dynamic>? result = {};
      result = value as Map<String, dynamic>?;
      if (result != null) {
        setState(() {
          _favouriteStaff = result!['favouriteStaff'];
        });
      }
    });
  }

  void _onChooseImages() async {
    Navigator.of(context).pop();
    List<File>? files = await onGetMultiPhoto(
        context: context, funcPermission: () {}, picker: _picker);
    if (files != null && files.isNotEmpty) {
      for (var file in files) {
        img.Image? originalImage = img.decodeImage(await file.readAsBytes());
        img.Image files = img.copyResize(originalImage!, width: 500);
        await File(file.path).writeAsBytes(img.encodePng(files));
      }
      if (_listPath.length + files.length <= 4) {
        _bloc.add(ServiceScreenUploadImageEvent(files));
      } else {
        context.showSnackBar('Chỉ được chọn tối đa 4 ảnh!');
        return;
      }
    }
  }

  Future getImage(
    ImageSource img,
  ) async {
    if (await Permission.camera.request().isGranted) {
      if (_listPath.length >= 4) {
        context.showSnackBar('Chỉ được chọn tối đa 4 ảnh!');
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
          if (_listPath.length + files.length > 4) {
            context.showSnackBar('Chỉ được chọn tối đa 4 ảnh!');
          } else {
            _bloc.add(ServiceScreenUploadImageEvent(files));
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

  void _onTapDateStart() {
    _selectDate();
  }

  void _onTapTimeStart() {
    _selectTime();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        locale: const Locale("vi", "VN"),
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2050));
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      setState(() {
        _dateStart = selectedDate!.toDateString(format: "dd/MM/yyyy");
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      selectedTime = picked;
      setState(() {
        final hour = picked.hour.toString().padLeft(2, "0");
        final minute = picked.minute.toString().padLeft(2, "0");
        _timeStart = "$hour:$minute";
      });
    }
  }
}
