import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/auth/verify_otp/verify_otp_screen_bloc.dart';
import 'package:socbay/blocs/auth/verify_otp/verify_otp_screen_event.dart';
import 'package:socbay/blocs/auth/verify_otp/verify_otp_screen_state.dart';
import 'package:socbay/blocs/root/root_bloc.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/utils/theme_util.dart';
import 'package:socbay/widgets/dialog/custom_alert_dialog.dart';
import 'package:socbay/widgets/hotline_widget.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:socbay/widgets/my_button.dart';


import '../../blocs/root/root_event.dart';
import '../../constants/constants.dart';
import '../../paths/images.dart';
import '../../routes.dart';
import '../../utils/color_util.dart';

class VerifyOTPScreen extends StatefulWidget {
  final bool isForgotPassword;
  final Map<String, dynamic> userData;

  const VerifyOTPScreen({
    Key? key,
    this.isForgotPassword = false,
    required this.userData,
  }) : super(key: key);

  @override
  State<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  late TextEditingController _otpFieldController;
  bool isHaveData = false;
  int _countdownSecond = 60;
  Timer? _timer;
  late VerifyOtpScreenBloc _bloc;
  late RootBloc _rootBloc;

  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    _rootBloc = BlocProvider.of(context);
    _bloc.add(VerifyOtpScreenStartedEvent());
    _otpFieldController = TextEditingController()
      ..addListener(() {
        setState(() {
          isHaveData = _otpFieldController.text.isNotEmpty;
        });
      });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bloc.close();
    super.dispose();
  }

  void verifyCode() {
    if (_countdownSecond == 0) {
      context.showSnackBar("Hết thời gian xác nhận mã!");
      return;
    }

    if (_otpFieldController.text.isEmpty ||
        _otpFieldController.text.length < 6 ||
        _otpFieldController.text != _bloc.otp) {
      context.showSnackBar("Mã OTP không chính xác!");
      return;
    }
    if (_bloc.args["type"] == VerifyOtpType.forgotPassword) {
      Navigator.pushNamed(context, Routes.newPasswordScreen, arguments: {
        "phone": _bloc.args["phone"],
        "otp": _bloc.otp,
      });
    } else {
      _bloc.add(VerifyOtpScreenRegisterEvent(otp: _otpFieldController.text));
    }
  }

  void startCountdownRevert() {
    _timer?.cancel();
    setState(() {
      _countdownSecond = 60;
    });
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (_countdownSecond == 0) {
          timer.cancel();
        } else {
          setState(() {
            _countdownSecond = _countdownSecond - 1;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VerifyOtpScreenBloc, VerifyOtpScreenState>(
        builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, VerifyOtpScreenState state) {
    if (state is VerifyOtpScreenRegisterSuccessState) {
      if (state.error?.isNotEmpty == true) {
        context.showSnackBar(state.error ?? "Có lỗi xảy ra");
      } else {
        CustomAlertDialog.show(
          context,
          content: "Đăng ký thành công",
          leftText: "Ok",
          isLeftPositive: true,
          backListener: () {},
          isShowTitle: false,
          leftAction: () {
            _bloc.add(VerifyOtpScreenLoginEvent(
                phone: _bloc.args['phone'], password: _bloc.args['password']));
          },
        );
      }
    }
    if (state is VerifyOtpScreenSetOtpState) {
      startCountdownRevert();
    }
    if (state is VerifyOtpScreenLoginSuccessState) {
      Navigator.popUntil(context, (route) => route.isFirst);
      _rootBloc.add(AppStarted());
    }
    if (state is VerifyOtpScreenLogInFailureState) {
      context.showSnackBar(state.message);
    }
  }

  Widget _builder(BuildContext context, VerifyOtpScreenState state) {
    return SafeArea(
        child: Scaffold(
      appBar: MyAppBar(
        isBackNavigation: true,
        leadColor: ColorUtil.bangladeshGreen,
        backgroundColor: Colors.white,
        systemOverlayStyle: systemUiWhiteStyle,
      ),
      bottomNavigationBar: const HotlineWidget(),
      body: LoadingIndicator(
        isLoading: _bloc.isLoading,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            Column(
              children: [
                ImageUtil.loadAssetsImage(
                    fileName: Images.iconApp1, width: 150),
                const SizedBox(
                  height: 100,
                ),
                Row(
                  children: [
                    Expanded(child: _buildFormVerify(context)),
                    const SizedBox(width: 10),
                    DefaultButton(
                      onPressed: verifyCode,
                      text: "Xác nhận",
                      width: 111,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "Nhập mã OTP được gửi về máy của bạn để xác nhận",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: MyFontWeight.bold,
                      color: ColorUtil.spanishGray),
                ),
                const SizedBox(height: 15),
                Text(
                  "Thời gian còn lại: ${_countdownSecond}s",
                  style: const TextStyle(
                      fontSize: 15, color: ColorUtil.spanishGray),
                ),
                const SizedBox(height: 50),
                DefaultButton(
                  height: 40,
                  width: 200,
                  color: _countdownSecond <= 0
                      ? ColorUtil.bangladeshGreen
                      : ColorUtil.graniteGray,
                  onPressed: _countdownSecond <= 0
                      ? () {
                          _bloc.add(VerifyOtpScreenStartedEvent());
                          startCountdownRevert();
                        }
                      : null,
                  text: "Gửi lại mã OTP",
                  borderRadius: BorderRadius.circular(50),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildFormVerify(BuildContext context) {
    return TextField(
      controller: _otpFieldController,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      maxLength: 6,
      cursorColor: ColorUtil.bangladeshGreen,
      decoration: InputDecoration(
          counterText: "",
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelText: "Nhập mã OTP",
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
          contentPadding:
              const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          suffixIconConstraints:
              const BoxConstraints(minHeight: 10, minWidth: 10),
          suffixIcon: isHaveData
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _otpFieldController.text = "";
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
}
