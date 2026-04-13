import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socbay/blocs/user_info/update_staff/update_staff_screen_bloc.dart';
import 'package:socbay/blocs/user_info/update_staff/update_staff_screen_event.dart';
import 'package:socbay/blocs/user_info/update_staff/update_staff_screen_state.dart';
import 'package:socbay/data/model/request/update_staff_request_model.dart';
import 'package:socbay/paths/images.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/date_util.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/utils/file_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/hotline_widget.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:socbay/widgets/my_button.dart';

class UpdateStaffScreen extends StatefulWidget {
  const UpdateStaffScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UpdateStaffScreenState();
}

class _UpdateStaffScreenState extends State<UpdateStaffScreen> {
  late UpdateStaffScreenBloc _bloc;
  late TextEditingController addressTxtController;
  late TextEditingController idCardTxtController;

  String idCardImageFront = '';
  String idCardImageBack = '';
  String dateOfBirth = '';
  DateTime? selectedDate;
  late final ImagePicker _picker;

  @override
  void initState() {
    _bloc = BlocProvider.of(context);

    addressTxtController = TextEditingController();
    idCardTxtController = TextEditingController();
    _picker = ImagePicker();

    if (selectedDate != null) {
      setState(() {
        dateOfBirth = selectedDate!.toDateString(format: 'dd/MM/yyyy');
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UpdateStaffScreenBloc, UpdateStaffState>(
        builder: _buildBody, listener: _listener);
  }

  void _listener(BuildContext context, UpdateStaffState state) {
    if (state is UpdateStaffScreenSuccessState) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildBody(BuildContext context, UpdateStaffState state) {
    return Scaffold(
        appBar: MyAppBar(
          isBackNavigation: true,
          leadColor: ColorUtil.bangladeshGreen,
          backgroundColor: Colors.white,
          systemOverlayStyle: systemUiWhiteStyle,
        ),
        bottomNavigationBar: const HotlineWidget(),
        backgroundColor: Colors.white,
        body: LoadingIndicator(
          isLoading: _bloc.isLoading,
          child: ListView(
            padding: const EdgeInsets.symmetric(
                horizontal: paddingHorizontal, vertical: paddingVertical),
            children: [
              Center(
                child: ImageUtil.loadAssetsImage(
                    fileName: Images.iconApp1, width: 150),
              ),
              const SizedBox(height: 30),
              const Text(
                "Đăng ký để trở thành Kỹ Thuật Viên !",
                style: TextStyle(
                  color: ColorUtil.graniteGray,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 20),
              _buildForm("Nhập địa chỉ", "Vui lòng nhập địa chỉ",
                  addressTxtController),
              const SizedBox(height: 20),
              _buildField(
                  placeHolder: "Ngày sinh",
                  value: dateOfBirth,
                  icon: Icons.calendar_today,
                  onTap: _onTapDateOfBirth),
              const SizedBox(height: 20),
              _buildForm("Số căn cước", "Vui lòng nhập số căn cước",
                  idCardTxtController,
                  isNumberType: true),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Hình ảnh thẻ căn cước",
                    style:
                        TextStyle(color: ColorUtil.raisinBlack, fontSize: 15),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildIdCard(title: "Mặt trước", isFront: true),
                      _buildIdCard(title: "Mặt sau", isFront: false)
                    ],
                  )
                ],
              ),
              const SizedBox(height: 25),
              DefaultButton(
                onPressed: validateSignUpStaffAccount,
                text: "ĐĂNG KÝ LÀM KTV",
              ),
              const SizedBox(height: 16),
            ],
          ),
        ));
  }

  Future validateSignUpStaffAccount() async {
    if (addressTxtController.text.isEmpty) {
      context.showSnackBar("Địa chỉ không được để trống!");
      return;
    }
    if (dateOfBirth.isEmpty) {
      context.showSnackBar("Ngày sinh không được để trống!");
      return;
    }
    if (idCardTxtController.text.isEmpty) {
      context.showSnackBar("Số căn cước không được để trống!");
      return;
    }
    if (idCardTxtController.text.isNotEmpty &&
        idCardTxtController.text.length != 12) {
      context.showSnackBar("Số căn cước phải đủ 12 số ký tự!");
      return;
    }
    if (idCardImageFront.isEmpty) {
      context.showSnackBar("Vui lòng upload ảnh mặt trước thẻ căn cước!");
      return;
    }
    if (idCardImageBack.isEmpty) {
      context.showSnackBar("Vui lòng upload ảnh mặt sau thẻ căn cước!");
      return;
    }

    _bloc.add(UpdateStaffScreenEvent(UpdateStaffRequestModel(
        birthday: dateOfBirth,
        address: addressTxtController.text,
        idCard: idCardTxtController.text,
        idCardImageFront: idCardImageFront,
        idCardImageBack: idCardImageBack,
        services: [3])));
    Navigator.pop(context);
  }

  Widget _buildForm(
    String titleTextField,
    String placeHolder,
    TextEditingController controller, {
    bool isNumberType = false,
    bool isSecure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titleTextField,
          style: const TextStyle(color: ColorUtil.raisinBlack, fontSize: 15),
        ),
        Container(
          padding: const EdgeInsets.only(top: 5),
          height: 40,
          child: TextFormField(
              obscureText: isSecure,
              keyboardType:
                  isNumberType ? TextInputType.phone : TextInputType.text,
              controller: controller,
              cursorColor: ColorUtil.bangladeshGreen,
              decoration: InputDecoration(
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

  Widget _buildField({
    required String placeHolder,
    required String value,
    required IconData icon,
    required void Function() onTap,
  }) {
    final isEmpty = value.isEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black54),
            const SizedBox(width: 31),
            Text(
              isEmpty ? placeHolder : value,
              style: TextStyle(
                  color: isEmpty
                      ? ColorUtil.silverChalice
                      : ColorUtil.raisinBlack),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIdCard({required String title, bool isFront = false}) {
    return Center(
      child: GestureDetector(
          onTap: () async {
            File? file = await onGetPhotoFromGallery(
                context: context, funcPermission: () {}, picker: _picker);
            if (file != null) {
              setState(() {
                if (isFront) {
                  idCardImageFront = file.path;
                } else {
                  idCardImageBack = file.path;
                }
              });
            }
          },
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                        File(isFront ? idCardImageFront : idCardImageBack),
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                      return ImageUtil.loadNetWorkImage(
                          url: "", width: 160, height: 160);
                    }, fit: BoxFit.cover, width: 160, height: 160),
                  ),
                  Positioned(
                      bottom: 16,
                      right: 16,
                      child: GestureDetector(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                        onTap: () {},
                      ))
                ],
              ),
              const SizedBox(
                height: 6,
              ),
              Text(
                title,
                style:
                    const TextStyle(color: ColorUtil.raisinBlack, fontSize: 15),
              ),
            ],
          )),
    );
  }

  void _onTapDateOfBirth() {
    _selectDate();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        locale: const Locale("vi", "VN"),
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(1900, 1),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      setState(() {
        dateOfBirth = selectedDate!.toDateString(format: "dd/MM/yyyy");
      });
    }
  }
}
