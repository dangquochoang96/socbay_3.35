import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/user_info/change_password/change_password_screen_bloc.dart';
import 'package:socbay/blocs/user_info/change_password/change_password_screen_event.dart';
import 'package:socbay/blocs/user_info/change_password/change_password_screen_state.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/request/change_password_request.dart';
import 'package:socbay/paths/images.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/utils/logger_util.dart';
import 'package:socbay/widgets/hotline_widget.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:socbay/widgets/my_button.dart';

const _oldPasswordType = 'old-password';
const _passwordType = 'password';
const _rePasswordType = 're-password';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool isSecureOldPassword = true;
  bool isSecurePassword = true;
  bool isSecureRePassword = true;
  late TextEditingController oldPasswordTxtController;
  late TextEditingController passwordTxtController;
  late TextEditingController rePasswordTxtController;

  late ChangePasswordScreenBloc _bloc;

  @override
  void initState() {
    super.initState();
    oldPasswordTxtController = TextEditingController();
    passwordTxtController = TextEditingController();
    rePasswordTxtController = TextEditingController();

    _bloc = BlocProvider.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChangePasswordScreenBloc, ChangePasswordScreenState>(
        builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, ChangePasswordScreenState state) {
    if(state is ChangePasswordScreenDoneState){
      if(state.error!=null){
        context.showSnackBarError("Thông tin mật khẩu không chính xác, vui lòng nhập lại");
      }else{
        context.showSnackBarSuccess("Đổi mật khẩu thành công");
        Navigator.pop(context);
      }
    }
  }

  Widget _builder(BuildContext context, ChangePasswordScreenState state) {
    return LoadingIndicator(
      isLoading: _bloc.isLoading,
      child: Scaffold(
        bottomNavigationBar: const HotlineWidget(),
        appBar: MyAppBar(
          title: "Đổi mật khẩu",
          isBackNavigation: true,
          centerTitle: true,
        ),
        body: Center(
          child: ListView(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: paddingHorizontal),
            children: [
              _buildForm(
                "Mật khẩu cũ",
                "Vui lòng nhập mật khẩu cũ",
                oldPasswordTxtController,
                type: _oldPasswordType,
              ),
              const SizedBox(height: 16),
              _buildForm(
                "Mật khẩu mới",
                "Vui lòng nhập mật khẩu mới",
                passwordTxtController,
                type: _passwordType,
              ),
              const SizedBox(height: 16),
              _buildForm(
                "Nhập lại mật khẩu mới",
                "Vui lòng nhập lại mật khẩu mới",
                rePasswordTxtController,
                type: _rePasswordType,
              ),
              const SizedBox(height: 32),
              DefaultButton(
                color:
                    isEmpty() ? ColorUtil.graniteGray : ColorUtil.bangladeshGreen,
                text: "Lưu",
                onPressed: _onSavePassword,
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(String titleTextField, String placeHolder,
      TextEditingController controller,
      {required String type}) {
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
            onChanged: (text) {
              setState(() {});
            },
            obscureText: type == _rePasswordType
                ? isSecureRePassword
                : type == _passwordType
                    ? isSecurePassword
                    : isSecureOldPassword,
            keyboardType: TextInputType.text,
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
              hintStyle:
                  const TextStyle(color: ColorUtil.silverChalice, fontSize: 13),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              suffixIconConstraints:
                  const BoxConstraints(minHeight: 20, minWidth: 20),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    switch (type) {
                      case _oldPasswordType:
                        isSecureOldPassword = !isSecureOldPassword;
                        break;
                      case _passwordType:
                        isSecurePassword = !isSecurePassword;
                        break;
                      case _rePasswordType:
                        isSecureRePassword = !isSecureRePassword;
                        break;
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ImageUtil.loadAssetsImage(
                    fileName: type == _rePasswordType
                        ? (isSecureRePassword
                            ? Images.iconSecurePassword
                            : Images.iconNotSecurePassword)
                        : type == _passwordType
                            ? (isSecurePassword
                                ? Images.iconSecurePassword
                                : Images.iconNotSecurePassword)
                            : (isSecureOldPassword
                                ? Images.iconSecurePassword
                                : Images.iconNotSecurePassword),
                    width: 15,
                    height: 15,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  void _onSavePassword() {
    LoggerUtil.log("message ${App.instance.userApp?.password}");
    if (isRePasswordWrong()) {
      context.showSnackBarError("Thông tin mật khẩu không chính xác,vui lòng nhập lại");
    } else {
      _bloc.add(ChangePasswordScreenSubmitChangeEvent(ChangePasswordRequest(
          oldPassword:  oldPasswordTxtController.text.trim(),
          password:  passwordTxtController.text.trim(),
          rePassword:  rePasswordTxtController.text.trim())));
    }
  }

  bool isEmpty() =>
      oldPasswordTxtController.text.trim().isEmpty ||
      passwordTxtController.text.trim().isEmpty ||
      rePasswordTxtController.text.trim().isEmpty;

  bool isRePasswordWrong() =>
      passwordTxtController.text.trim() != rePasswordTxtController.text.trim();
}
