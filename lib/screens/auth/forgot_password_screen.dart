import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/auth/forgot_password/forgot_password_screen_bloc.dart';
import 'package:socbay/blocs/auth/forgot_password/forgot_password_screen_event.dart';
import 'package:socbay/blocs/auth/forgot_password/forgot_password_screen_state.dart';
import 'package:socbay/blocs/auth/verify_otp/verify_otp_screen_bloc.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/paths/images.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/utils/theme_util.dart';
import 'package:socbay/widgets/hotline_widget.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:socbay/widgets/my_button.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late TextEditingController _textController;
  late ForgotPasswordScreenBloc _bloc;
  bool isHaveData = false;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    _textController = SharedPhoneController.instance.phoneNumberTxtController;
    // _textController = TextEditingController();
    _textController = SharedPhoneController.instance.phoneNumberTxtController
      ..addListener(() {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              isHaveData = _textController.text.isNotEmpty;
            });
          }
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordScreenBloc, ForgotPasswordScreenState>(
        builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, ForgotPasswordScreenState state) {
    if (state is CheckUserExistState) {
      if (state.code == "1") {
        Navigator.pushNamed(context, Routes.verifyOTP, arguments: {
          "phone": _textController.text.trim(),
          "type": VerifyOtpType.forgotPassword
        }).then((_) {
          _savePhoneNumber(_textController.text.trim());
        });
      } else {
        context.showSnackBar("Số điện thoại không chính xác!");
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _savePhoneNumber(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_phone_number', phoneNumber);
    print('Saved phone number: $phoneNumber');
  }

  Widget _builder(BuildContext context, ForgotPasswordScreenState state) {
    return SafeArea(
        child: Scaffold(
            bottomNavigationBar: const HotlineWidget(),
            appBar: MyAppBar(
              isBackNavigation: true,
              leadColor: ColorUtil.bangladeshGreen,
              backgroundColor: Colors.white,
              systemOverlayStyle: systemUiWhiteStyle,
            ),
            body: LoadingIndicator(
              isLoading: isLoading,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Column(
                    children: [
                      ImageUtil.loadAssetsImage(
                          fileName: Images.iconApp1, width: 150),
                      const SizedBox(height: 100),
                      const Text(
                        "Quên mật khẩu?",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black54,
                            fontWeight: MyFontWeight.bold),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          "Hãy nhập tài khoản của bạn để tạo lại mật khẩu",
                          style: TextStyle(color: Colors.black38),
                        ),
                      ),
                      _buildForm(),
                      const SizedBox(height: 16),
                      DefaultButton(
                        width: double.infinity,
                        onPressed: _onPressSend,
                        text: "Gửi",
                      )
                    ],
                  ),
                ],
              ),
            )));
  }

  Widget _buildForm() {
    return TextField(
      controller: _textController,
      cursorColor: ColorUtil.bangladeshGreen,
      keyboardType: TextInputType.phone,
      maxLength: 10,
      decoration: InputDecoration(
          counterText: "",
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: const TextStyle(
              color: ColorUtil.bangladeshGreen,
              fontSize: 18,
              fontWeight: MyFontWeight.bold),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide:
                const BorderSide(color: ColorUtil.bangladeshGreen, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide:
                const BorderSide(color: ColorUtil.bangladeshGreen, width: 0.5),
          ),
          hintText: "Nhập số điện thoại",
          hintStyle:
              const TextStyle(color: ColorUtil.silverChalice, fontSize: 13),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          suffixIconConstraints:
              const BoxConstraints(minHeight: 10, minWidth: 10),
          suffixIcon: isHaveData
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _textController.text = "";
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ImageUtil.loadAssetsImage(
                        fileName: Images.iconClose, width: 16, height: 16),
                  ),
                )
              : null),
    );
  }

  void _onPressSend() {
    if (_textController.text.trim().isEmpty) {
      context.showSnackBarError("Số điện thoại không được để trống!");
      return;
    }
    if (_textController.text.trim().length < 10) {
      context.showSnackBarError("Số điện thoại phải đủ 10 số ký tự!");
      return;
    }
    setState(() {
      isLoading = true;
    });
    _bloc.add(CheckUserExistEvent(_textController.text.trim()));
  }
}
