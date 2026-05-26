import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/auth/new_password/new_password_screen_bloc.dart';
import 'package:socbay/blocs/auth/new_password/new_password_screen_event.dart';
import 'package:socbay/blocs/auth/new_password/new_password_screen_state.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/request/new_password_request.dart';
import 'package:socbay/paths/images.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/hotline_widget.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:socbay/widgets/my_button.dart';

const _passwordType = "password";
const _rePasswordType = "re-password";

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  late NewPasswordScreenBloc _bloc;
  late TextEditingController _passwordController;
  late TextEditingController _rePasswordController;
  bool isSecurePassword = true;
  bool isSecureRePassword = true;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    _passwordController = TextEditingController();
    _rePasswordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NewPasswordScreenBloc, NewPasswordScreenState>(
      builder: _builder,
      listener: _listener,
    );
  }

  void _listener(BuildContext context, NewPasswordScreenState state) {
    if (state is NewPasswordScreenSubmitDoneState) {
      if (state.error?.isNotEmpty == true) {
        context.showSnackBarError(state.error ?? "Có lỗi xảy ra");
      } else {
        context.showSnackBarSuccess("Đổi mật khẩu thành công");
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    }
  }

  Widget _builder(BuildContext context, NewPasswordScreenState state) {
    return Scaffold(
      bottomNavigationBar: const HotlineWidget(),
      appBar: MyAppBar(
        isBackNavigation: true,
        leadColor: ColorUtil.bangladeshGreen,
        backgroundColor: Colors.white,
        systemOverlayStyle: systemUiWhiteStyle,
      ),
      body: LoadingIndicator(
        isLoading: _bloc.isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Center(
                child: ImageUtil.loadAssetsImage(
                  fileName: Images.iconApp1,
                  width: 150,
                ),
              ),
              const SizedBox(height: 100),

              const SizedBox(height: 5),
              _buildForm(
                "Mật khẩu mới",
                "Nhập mật khẩu mới",
                _passwordController,
                type: _passwordType,
              ),
              const SizedBox(height: 15),
              _buildForm(
                "Nhập lại mật khẩu mới",
                "Nhập lại mật khẩu mới",
                _rePasswordController,
                type: _rePasswordType,
              ),
              const SizedBox(height: 32),
              DefaultButton(
                onPressed: _onPress,
                text: "Lưu",
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(
    String titleTextField,
    String placeHolder,
    TextEditingController controller, {
    required String type,
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
          height: 50,
          child: TextFormField(
            onChanged: (text) {
              setState(() {});
            },
            obscureText: type == _rePasswordType
                ? isSecureRePassword
                : type == _passwordType
                ? isSecurePassword
                : true,
            keyboardType: TextInputType.text,
            controller: controller,
            cursorColor: ColorUtil.bangladeshGreen,
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
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    switch (type) {
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
                        ? isSecureRePassword
                              ? Images.iconSecurePassword
                              : Images.iconNotSecurePassword
                        : isSecurePassword
                        ? Images.iconSecurePassword
                        : Images.iconNotSecurePassword,
                    width: 15,
                    height: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onPress() {
    if (_passwordController.text.trim().isEmpty ||
        _rePasswordController.text.trim().isEmpty) {
      context.showSnackBarError("Mật khẩu không được để trống!");
      return;
    }
    if (_passwordController.text.trim() != _rePasswordController.text.trim()) {
      context.showSnackBarError("Mật khẩu không trùng khớp");
      return;
    }
    _bloc.add(
      NewPasswordScreenSubmitEvent(
        NewPasswordRequest(
          phone: _bloc.args['phone'],
          newPassword: _passwordController.text.trim(),
          newPasswordConfirm: _rePasswordController.text.trim(),
          otp: _bloc.args['otp'],
        ),
      ),
    );
  }
}
