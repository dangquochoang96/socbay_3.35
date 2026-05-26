import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socbay/blocs/staff/new_task/staff_service_screen_bloc.dart';
import 'package:socbay/blocs/staff/new_task/staff_service_screen_event.dart';
import 'package:socbay/blocs/staff/new_task/staff_service_screen_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/request/user_address_request.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/paths/images.dart';
import 'package:socbay/routes.dart';
// import 'package:socbay/screens/auth/verify_otp_screen.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/date_util.dart';
import 'package:socbay/utils/file_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/hotline_widget.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:socbay/widgets/my_button.dart';
import 'package:socbay/widgets/my_rich_text.dart';

import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  List<String> selectedServices = [];
  late bool isFront;
  final List<String> _listPath = [];
  bool isLoading = false;
  bool isCheckAgreePolicy = false;
  bool isCheckTickConfirmTechnicians = false;
  late TextEditingController phoneNumberTxtController;
  late TextEditingController userNameTxtController;
  late TextEditingController passwordTxtController;
  late TextEditingController passwordRepeatTxtController;
  late TextEditingController introduceCodeTxtController;
  //new controller
  late TextEditingController addressTxtController;
  late TextEditingController idCardTxtController;
  String idCardImageFront = '';
  String idCardImageBack = '';
  String dateOfBirth = '';
  DateTime? selectedDate;
  late final ImagePicker _picker;

  bool isSecurePassword = true;
  bool isSecureConfirmPassword = true;
  late StaffServiceScreenBloc _bloc;
  late ApiRepository apiRepository;

  static var servicesList = <DropdownItem<String>>[
    DropdownItem<String>(label: 'Thay lõi lọc nước', value: '3'),
    DropdownItem<String>(label: 'Sửa máy lọc nước', value: '6'),
    DropdownItem<String>(label: 'Vệ sinh máy lọc nước', value: '7'),
    DropdownItem<String>(label: 'Bảo dưỡng máy lọc nước', value: '13'),
  ];

  @override
  void initState() {
    // phoneNumberTxtController = TextEditingController();
    phoneNumberTxtController =
        SharedPhoneController.instance.phoneNumberTxtController;
    userNameTxtController = TextEditingController();
    passwordTxtController = SharedPassController.instance.passwordTxtController;
    passwordRepeatTxtController = TextEditingController();
    introduceCodeTxtController = TextEditingController();
    // Initialize
    addressTxtController = TextEditingController();
    idCardTxtController = TextEditingController();
    _picker = ImagePicker();
    if (selectedDate != null) {
      setState(() {
        dateOfBirth = selectedDate!.toDateString(format: 'yyyy/MM/dd');
      });
    }
    apiRepository = RepositoryProvider.of(context);
    _bloc = BlocProvider.of(context);
    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaffServiceScreenBloc, StaffServiceScreenState>(
      builder: _builder,
      listener: _listener,
    );
  }

  void _listener(BuildContext context, StaffServiceScreenState state) {
    if (state is UserAddressScreenCreateAddressSuccessState) {
      context.showSnackBarSuccess('Thêm khách hàng thành công!');
      Navigator.pushNamed(context, Routes.root);
    }
    if (state is UserAddressScreenCreateAddressFailState) {
      if (state.error == 'User exit') {
        context.showSnackBarError('Số điện thoại này đã được đăng ký!');
      } else {
        context.showSnackBarError(state.error);
      }
    }
    if (state is StaffServiceScreenUploadImageSuccessState) {
      for (var element in state.paths) {
        _listPath.add(element);
      }
    } else if (state is StaffServiceScreenUploadImageFailedState) {
      print('Failed to upload images: ${state.message}');
    }
  }

  void _uploadImages(BuildContext context, File file) {
    List<File> files = [file];
    _bloc.add(StaffServiceScreenUploadImageEvent(files));
  }

  Widget _builder(BuildContext context, StaffServiceScreenState state) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          isBackNavigation: true,
          leadColor: ColorUtil.bangladeshGreen,
          backgroundColor: Colors.white,
          systemOverlayStyle: systemUiWhiteStyle,
        ),
        bottomNavigationBar: const HotlineWidget(),
        backgroundColor: Colors.white,
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            Center(
              child: ImageUtil.loadAssetsImage(
                fileName: Images.iconApp1,
                width: 150,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Chào mừng bạn !",
              style: TextStyle(
                color: ColorUtil.graniteGray,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Đăng ký để tiếp tục sử dụng Socbay",
              style: TextStyle(
                color: ColorUtil.spanishGray,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 20),
            _buildFormLogin(
              "Họ và tên *",
              "Nhập họ tên",
              userNameTxtController,
              isNumberType: false,
            ),
            const SizedBox(height: 20),
            _buildFormLogin(
              "Số điện thoại *",
              "Nhập số điện thoại",
              phoneNumberTxtController,
              isNumberType: true,
              maxLength: 10,
            ),
            const SizedBox(height: 20),
            _buildFormLogin(
              "Mật khẩu *",
              "Vui lòng nhập mật khẩu",
              passwordTxtController,
              isPassword: true,
              isSecure: isSecurePassword,
            ),
            const SizedBox(height: 20),
            _buildFormLogin(
              "Nhập lại mật khẩu *",
              "Vui lòng nhập lại mật khẩu",
              passwordRepeatTxtController,
              isPassword: true,
              isSecure: isSecureConfirmPassword,
              isPasswordConfirm: true,
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 10),
            _buildSelectedOption(
              "Đăng ký làm Kỹ Thuật Viên tại ",
              isCheck: isCheckTickConfirmTechnicians,
              toggleCheckboxState: (bool? value) {
                setState(() {
                  isCheckTickConfirmTechnicians = value ?? false;
                });
              },
            ),
            const SizedBox(height: 20),
            if (isCheckTickConfirmTechnicians) ...[
              _buildFormLogin(
                "Nhập địa chỉ",
                "Vui lòng nhập địa chỉ",
                addressTxtController,
              ),
              const SizedBox(height: 20),
              _buildField(
                placeHolder: "Ngày sinh",
                value: dateOfBirth,
                icon: Icons.calendar_today,
                onTap: _onTapDateOfBirth,
              ),
              const SizedBox(height: 20),
              const Text('Dịch vụ cung cấp'),
              const SizedBox(height: 4),
              MultiDropdown(
                onSelectionChange: (options) {
                  setState(() {
                    selectedServices = options;
                  });
                  debugPrint(options.toString());
                },
                items: servicesList,
                singleSelect: false,
                chipDecoration: const ChipDecoration(wrap: true),
                dropdownDecoration: const DropdownDecoration(maxHeight: 400),
              ),
              const SizedBox(height: 20),
              _buildFormLogin(
                "Số CCCD (12 số)",
                "Vui lòng nhập số căn cước",
                idCardTxtController,
                isNumberType: true,
                maxLength: 12,
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Hình ảnh thẻ căn cước",
                    style: TextStyle(
                      color: ColorUtil.raisinBlack,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // _buildSectionMedia()
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildIdCard(title: "Mặt trước", isFront: true),
                      _buildIdCard(title: "Mặt sau", isFront: false),
                    ],
                  ),
                ],
              ),
            ],
            const SizedBox(height: 25),
            DefaultButton(onPressed: validateSignUpAccount, text: "ĐĂNG KÝ"),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _onTapDateOfBirth() {
    _selectDate();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale("vi", "VN"),
      initialDate: selectedDate ?? DateTime(2000, 1),
      firstDate: DateTime(1900, 1),
      lastDate: DateTime(2010, 1),
    );
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      setState(() {
        dateOfBirth = selectedDate!.toDateString(format: "dd/MM/yyyy");
      });
    }
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
                    : ColorUtil.raisinBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdCard({required String title, bool isFront = true}) {
    return Center(
      child: GestureDetector(
        onTap: () async {
          File? file = await onGetPhotoFromGallery(
            context: context,
            funcPermission: () {},
            picker: _picker,
          );
          if (file != null) {
            setState(() {
              if (isFront) {
                idCardImageFront = file.path;
              } else {
                idCardImageBack = file.path;
              }
            });
            _uploadImages(context, file);
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
                    errorBuilder:
                        (
                          BuildContext context,
                          Object exception,
                          StackTrace? stackTrace,
                        ) {
                          return ImageUtil.loadNetWorkImage(
                            url:
                                "$protocol${AppConfig.instance.values.apiUrl}${isFront ? idCardImageFront : idCardImageBack}",
                            width: 160,
                            height: 160,
                          );
                        },
                    fit: BoxFit.cover,
                    width: 160,
                    height: 160,
                  ),
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
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: ColorUtil.raisinBlack,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future validateSignUpAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phoneNumber', phoneNumberTxtController.text.trim());
    await prefs.setString('password', passwordTxtController.text.trim());

    if (userNameTxtController.text.trim().isEmpty) {
      context.showSnackBar("Họ và tên không được để trống!");
      return;
    }
    if (phoneNumberTxtController.text.trim().isEmpty) {
      context.showSnackBar("Số điện thoại không được để trống!");
      return;
    }
    if (phoneNumberTxtController.text.trim().length < 10) {
      context.showSnackBar("Số điện thoại phải đủ 10 số ký tự!");
      return;
    }
    if (passwordTxtController.text.isEmpty) {
      context.showSnackBar("Mật khẩu không được để trống!");
      return;
    }
    if (passwordRepeatTxtController.text != passwordTxtController.text) {
      context.showSnackBar("Mật khẩu không trùng khớp!");
      return;
    }

    if (isCheckTickConfirmTechnicians) {
      if (addressTxtController.text.isEmpty) {
        context.showSnackBar("Địa chỉ không được để trống!");
        return;
      }
      if (dateOfBirth.isEmpty) {
        context.showSnackBar("Ngày sinh không được để trống!");
        return;
      }
      if (idCardTxtController.text.isEmpty) {
        context.showSnackBar("Số CCCD không được để trống!");
        return;
      }
      if (_listPath.length < 2) {
        context.showSnackBar("Vui lòng chọn đủ 2 mặt của CCCD!");
        return;
      }
    }

    List<int> servicesListValue = selectedServices
        .map((item) => int.tryParse(item) ?? 0)
        .toList();

    _bloc.add(
      UserAddressScreenCreateUserAddressEvent(
        UserAddressRequest(
          name: userNameTxtController.text.trim(),
          phone: phoneNumberTxtController.text.trim(),
          pass: passwordTxtController.text.trim(),
          birthday: dateOfBirth,
          address: addressTxtController.text.trim(),
          cityCode: "AGG",
          stateCode: "dt",
          typeStaff: isCheckTickConfirmTechnicians ? '1' : '0',
          type: isCheckTickConfirmTechnicians ? '2' : '1',
          cmt: idCardTxtController.text.trim(),
          idCardImageFront: isCheckTickConfirmTechnicians ? _listPath[0] : null,
          idCardImageBack: isCheckTickConfirmTechnicians ? _listPath[1] : null,
          services: servicesListValue,
        ),
      ),
    );
  }

  Widget _buildSelectedOption(
    String text, {
    bool isCheck = false,
    required Function(bool?) toggleCheckboxState,
  }) {
    return GestureDetector(
      onTap: () {
        toggleCheckboxState(!isCheck);
      },
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: Checkbox(
              value: isCheck,
              activeColor: ColorUtil.bangladeshGreen,
              onChanged: toggleCheckboxState,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: MyRichText(
              firstText: text,
              mainAxisAlignment: MainAxisAlignment.start,
              secondText: "Socbay",
              firstTextStyle: const TextStyle(fontSize: 18, color: Colors.grey),
              secondTextStyle: const TextStyle(
                fontSize: 18,
                color: ColorUtil.bangladeshGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormLogin(
    String titleTextField,
    String placeHolder,
    TextEditingController controller, {
    bool isPassword = false,
    bool isNumberType = false,
    bool isSecure = false,
    bool isPasswordConfirm = false,
    int? maxLength,
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
            keyboardType: isNumberType
                ? TextInputType.phone
                : TextInputType.text,
            controller: controller,
            cursorColor: ColorUtil.bangladeshGreen,
            inputFormatters: maxLength != null
                ? [LengthLimitingTextInputFormatter(maxLength)]
                : [],
            decoration: InputDecoration(
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
              hintText: placeHolder,
              hintStyle: const TextStyle(
                color: ColorUtil.silverChalice,
                fontSize: 13,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 15,
              ),
              suffixIconConstraints: const BoxConstraints(
                minHeight: 20,
                minWidth: 20,
              ),
              suffixIcon: isPassword
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isPasswordConfirm) {
                            isSecureConfirmPassword = !isSecureConfirmPassword;
                          } else {
                            isSecurePassword = !isSecurePassword;
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ImageUtil.loadAssetsImage(
                          fileName: isPasswordConfirm
                              ? (isSecureConfirmPassword
                                    ? Images.iconSecurePassword
                                    : Images.iconNotSecurePassword)
                              : (isSecurePassword
                                    ? Images.iconSecurePassword
                                    : Images.iconNotSecurePassword),
                          width: 15,
                          height: 15,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
