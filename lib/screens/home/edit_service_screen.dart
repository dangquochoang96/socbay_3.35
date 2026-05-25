import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/home/edit_service/edit_service_bloc.dart';
import 'package:socbay/blocs/home/edit_service/edit_service_event.dart';
import 'package:socbay/blocs/home/edit_service/edit_service_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/home_service_model.dart';
import 'package:socbay/data/model/request/update_task_request.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/screens/staff/technique/technique_screen.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/date_util.dart';
import 'package:socbay/utils/file_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/dialog/custom_alert_dialog.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';

import 'dart:io';

import 'package:socbay/widgets/my_button.dart';

class EditServiceScreen extends StatefulWidget {
  final Map<String, dynamic> args;

  const EditServiceScreen({super.key, required this.args});

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  late EditServiceBloc _bloc;
  late TextEditingController phoneNumberTxtController;
  late TextEditingController describeRequestTxtController;
  late TextEditingController addressRequestTxtController;
  late List<String> _listPath = [];
  String? desDraft;
  String? _currentSelectedValue;
  String? _dateStart;
  String? _timeStart;
  var resultLocation = {};
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  UserProfile? _favouriteStaff;
  late final ImagePicker _picker;
  // ignore: prefer_typing_uninitialized_variables
  var _parsedDate;
  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    _bloc.add(EditServiceStartedEvent());
    _picker = ImagePicker();
    phoneNumberTxtController = TextEditingController();
    describeRequestTxtController = TextEditingController();
    addressRequestTxtController = TextEditingController();
    addressRequestTxtController.text = App.instance.userApp?.address ?? "";
    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    describeRequestTxtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditServiceBloc, EditServiceState>(
        builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, EditServiceState state) {
    if (state is EditServiceInitialState) {
      _currentSelectedValue = _bloc.taskModel?.type;
      if (_bloc.taskModel?.timeStar != null) {
        _parsedDate = DateTime.parse(_bloc.taskModel!.timeStar!);
        _dateStart = "${_parsedDate.day}/${_parsedDate.month}/${_parsedDate.year}";
        _timeStart = "${_parsedDate.hour.toString().padLeft(2, "0")}:${_parsedDate.minute.toString().padLeft(2, "0")}";
      }
      _favouriteStaff = _bloc.taskModel?.staff;
      _listPath = _bloc.taskModel?.images ?? [];
      desDraft = _bloc.taskModel?.des ?? "";
    }

    if (state is EditServiceUploadImageSuccessState) {
      //_listPath.clear();
      for (var element in state.paths) {
        _listPath.add(element);
      }
    }

    if (state is EditServiceSuccessState) {
      Navigator.pop(context, {'id': _bloc.taskModel?.id});
    }

    if (state is EditServiceFailedState) {
      context.showSnackBar('Sửa thông tin thất bại');
    }
  }

  Widget _builder(BuildContext context, EditServiceState state) {
    return Scaffold(
        appBar: MyAppBar(
          isBackNavigation: true,
          title: 'Sửa thông tin',
          centerTitle: true,
        ),
        body: LoadingIndicator(
          isLoading: _bloc.isLoading,
          child: SafeArea(
            child: Scaffold(
              body: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: paddingHorizontal, vertical: paddingVertical),
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                            text: "SĐT Khách hàng: ",
                            style: TextStyle(
                                color: ColorUtil.raisinBlack, fontSize: 15)),
                        TextSpan(
                            text: _bloc.taskModel?.customer?.phone ?? "",
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                                fontWeight: FontWeight.w600))
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                            text: "Tên máy: ",
                            style: TextStyle(
                                color: ColorUtil.raisinBlack, fontSize: 15)),
                        TextSpan(
                            text: _bloc.taskModel?.productInfo?.machineModel
                                    ?.name ??
                                "",
                            style: const TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 7, 7, 7),
                                fontWeight: FontWeight.w600))
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  _buildDropdownField(),
                  const SizedBox(
                    height: 8,
                  ),
                  _buildFormDoubleHorizontal(
                      'Hẹn lịch', Icons.calendar_today, Icons.av_timer_sharp,
                      firstValue: _dateStart ?? "",
                      secondValue: _timeStart ?? "",
                      onTapFirst: _onTapDateStart,
                      onTapSecond: _onTapTimeStart),
                  const SizedBox(
                    height: 8,
                  ),
                  _buildField('', 'Thợ ưa thích', Icons.person_outlined, null,
                      value: _favouriteStaff?.username ?? "", onTap: () {
                    setState(() {
                      desDraft = describeRequestTxtController.text;
                    });
                    _onChooseFavouriteStaff();
                  }),
                  const SizedBox(
                    height: 8,
                  ),
                  _buildFormDescribe(
                      'Mô tả yêu cầu',
                      describeRequestTxtController..text = desDraft ?? "",
                      Icons.description_outlined,
                      null),
                  const SizedBox(
                    height: 8,
                  ),
                  _buildSectionMedia(),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 16.0),
                        child: DefaultButton(
                          onPressed: _onEditDone,
                          text: "LƯU",
                        ),
                      )),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }

  void _onEditDone() {
    String? serviceName;
    for (var i in _bloc.services) {
      if (i.id == int.parse(_currentSelectedValue ?? "1")) {
        serviceName = i.name;
      }
    }
    _bloc.add(EditServiceUpdateTaskEvent(UpdateTaskRequest(
        type: int.parse(_currentSelectedValue ?? "1"),
        name: serviceName,
        des: describeRequestTxtController.text,
        status: _favouriteStaff?.id == null ? 1 : 5,
        priority: int.parse(_bloc.taskModel?.priority ?? "1"),
        serviceId: int.parse(_currentSelectedValue ?? "1"),
        timeStart: '$_dateStart $_timeStart',
        timeEnd: "",
        staffId: _favouriteStaff?.id,
        saleId: 1,
        customerId: App.instance.userApp?.id,
        orderId: 1,
        images: _listPath)));
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
          isEmpty: _currentSelectedValue == null,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _currentSelectedValue,
              isDense: true,
              onChanged: (String? newValue) {
                setState(() {
                  _currentSelectedValue = newValue;
                });
              },
              items: _bloc.services.map((HomeServiceModel sv) {
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

  void _onChooseFavouriteStaff() {
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
        initialDate: _parsedDate ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      setState(() {
        _dateStart = selectedDate!.toDateString(format: "dd/MM/yyyy");
        desDraft = describeRequestTxtController.text;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_parsedDate),
    );
    if (picked != null && picked != selectedTime) {
      selectedTime = picked;
      setState(() {
        final hour = picked.hour.toString().padLeft(2, "0");
        final minute = picked.minute.toString().padLeft(2, "0");
        _timeStart = "$hour:$minute";
        desDraft = describeRequestTxtController.text;
      });
    }
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
                    padding: const EdgeInsets.all(8.0),
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
                      desDraft = describeRequestTxtController.text;
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
                  // Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  void _onChooseImages() async {
    Navigator.of(context).pop();

    List<File>? files = await onGetMultiPhoto(
        context: context, funcPermission: () {}, picker: _picker);
    if (files != null && files.isNotEmpty) {
      if (_listPath.length + files.length <= 4) {
        _bloc.add(EditServiceUploadImageEvent(files));
      } else {
        context.showSnackBar('Chỉ được chọn tối đa 4 ảnh!');
        return;
      }
    }
    setState(() {
      desDraft = describeRequestTxtController.text;
    });
    // Navigator.of(context).pop();
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
            _bloc.add(EditServiceUploadImageEvent(files));
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
}
