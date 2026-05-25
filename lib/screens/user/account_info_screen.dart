import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socbay/blocs/user_info/account_info/account_info_bloc.dart';
import 'package:socbay/blocs/user_info/account_info/account_info_event.dart';
import 'package:socbay/blocs/user_info/account_info/account_info_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/request/user_info_request.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/date_util.dart';
import 'package:socbay/utils/file_util.dart';
import 'package:socbay/widgets/hotline_widget.dart';
import 'package:socbay/widgets/my_app_bar.dart';

import '../../utils/image_util.dart';
import '../../widgets/my_button.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  late AccountInfoBloc _bloc;
  late TextEditingController phoneNumberTxtController;
  late TextEditingController addressTxtController;
  late TextEditingController emailTxtController;
  late TextEditingController idNumberTxtController;

  late final ImagePicker _picker;
  String birthday = '';
  DateTime? selectedDate;
  String? avatarFile;

  @override
  void initState() {
    _picker = ImagePicker();
    _bloc = BlocProvider.of(context);
    _bloc.add(const AccountInfoInitEvent());
    idNumberTxtController = TextEditingController(text: _bloc.user?.cmt);
    addressTxtController = TextEditingController(text: _bloc.user?.address);
    emailTxtController = TextEditingController(text: _bloc.user?.email);
    phoneNumberTxtController = TextEditingController(text: _bloc.user?.phone);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountInfoBloc, AccountInfoState>(
        builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, AccountInfoState state) {
    if (state is AccountInfoUpdateDoneState) {
      if (state.isSuccess) {
        Navigator.pop(context);
        context.showSnackBarSuccess('Cập nhật thông tin thành công');
      } else {
        context.showSnackBarError(state.error ?? 'Xảy ra lỗi');
      }
    }
    if (state is UploadImageFailedState) {
      context.showSnackBar("Upload ảnh lỗi");
    }
    if (state is UploadImageSuccessState) {
      avatarFile = state.path;
    }
    
    if (state is AccountInfoGetDetailState) {
      if (_bloc.user?.birthday?.isNotEmpty == true &&
          _bloc.user!.birthday != "0000-00-00 00:00:00") {
        selectedDate =
            DateTime.parse(_bloc.user!.birthday!.replaceAll("/", "-"));
      }

      setState(() {
        if (selectedDate != null) {
          birthday = selectedDate!.toDateString(format: 'dd/MM/yyyy');
        }

        addressTxtController = TextEditingController(text: _bloc.user?.address);
        emailTxtController = TextEditingController(text: _bloc.user?.email);
        avatarFile = _bloc.user?.avatar;
        phoneNumberTxtController =
            TextEditingController(text: _bloc.user?.phone);
        idNumberTxtController = TextEditingController(text: _bloc.user?.cmt);
      });
    }
  }

  Widget _builder(BuildContext context, AccountInfoState state) {
    return Scaffold(
      appBar: MyAppBar(
        isBackNavigation: true,
        title: "Thông tin của bạn",
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
            horizontal: paddingHorizontal, vertical: paddingVertical),
        children: [
          ///AVATAR
          _buildAvatar(),

          ///FORM
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                  child: Text("${_bloc.user?.username}",
                      style: const TextStyle(fontSize: 16)))),
          _buildDivider(),
          _buildTextField(
            placeHolder: "Số điện thoại",
            controller: phoneNumberTxtController,
            icon: Icons.phone,
            inputType: TextInputType.phone,
            maxLength: 10,
          ),
          _buildField(
              placeHolder: "Ngày sinh",
              value: birthday,
              icon: Icons.calendar_today,
              onTap: _selectDateOfBirth),
          _buildTextField(
            placeHolder: "Địa chỉ",
            controller: addressTxtController,
            icon: Icons.location_on,
          ),
          _buildTextField(
            placeHolder: "Email",
            controller: emailTxtController,
            icon: Icons.email_outlined,
          ),
          _buildTextField(
            placeHolder: "CCCD",
            controller: idNumberTxtController,
            icon: Icons.medical_information_sharp,
          ),

          ///BUTTON
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: DefaultButton(
                onPressed: _onEditInfo,
                text: "Lưu",
              )),
              const SizedBox(width: 16),
              Expanded(
                child: DefaultOutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    text: 'Hủy'),
              )
            ],
          ),
          const HotlineWidget(),
        ],
      ),
    );
  }

  Divider _buildDivider() =>
      Divider(color: Colors.grey.shade100, thickness: 1, height: 0);

  Widget _buildAvatar() {
    return Center(
      child: GestureDetector(
        onTap: _onEditAvatar,
        child: Stack(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(140),
                child: avatarFile != null
                    ? Image.network(
                        "$protocol${AppConfig.instance.values.apiUrl}${avatarFile!}",
                        height: 160,
                        width: 160,
                        fit: BoxFit.cover)
                    : ImageUtil.loadNetWorkImage(
                        url: _bloc.user?.avatar ?? "",
                        width: 160,
                        height: 160)),
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
      ),
    );
  }

  Widget _buildTextField({
    required String placeHolder,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    required IconData icon,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 16),
          Flexible(
            child: TextField(
              keyboardType: inputType,
              controller: controller,
              cursorColor: ColorUtil.bangladeshGreen,
              maxLength: maxLength,
              style: const TextStyle(color: ColorUtil.raisinBlack),
              decoration: InputDecoration(
                counterText: '',
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: ColorUtil.transparent),
                ),
                disabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: ColorUtil.transparent),
                ),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: ColorUtil.transparent),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: ColorUtil.transparent),
                ),
                hintText: placeHolder,
                hintStyle: const TextStyle(
                    color: ColorUtil.silverChalice, fontSize: 13),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              ),
            ),
          )
        ],
      ),
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
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 16),
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

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        locale: const Locale("vi","VN"),
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(1900, 1),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      setState(() {
        birthday = selectedDate!.toDateString(format: "dd/MM/yyyy");
      });
    }
  }
  void _onEditAvatar() async {
    File? file = await onGetPhotoFromGallery(
        context: context, funcPermission: () {}, picker: _picker);
    if (file != null) {
      setState(() {
        _bloc.add(UploadImageEvent(file));
      });
    }
  }

  void _onEditInfo() {
    if (phoneNumberTxtController.text.isEmpty) {
      context.showSnackBarError("Số điện thoại không được để trống!");
      return;
    }
    if (phoneNumberTxtController.text.isNotEmpty &&
        phoneNumberTxtController.text.length < 10) {
      context.showSnackBarError("Số điện thoại phải đủ 10 số ký tự!");
      return;
    }
    var data = UserInfoRequest(
        phone: phoneNumberTxtController.text,
        birthday: birthday,
        address: addressTxtController.text,
        email: emailTxtController.text,
        avatar: avatarFile,
        cmt: idNumberTxtController.text);
    _bloc.add(AccountInfoUpdateUserEvent(data));
  }
}
