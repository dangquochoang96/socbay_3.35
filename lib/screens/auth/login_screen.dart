import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/auth/login_event.dart';
import 'package:socbay/blocs/auth/login_screen_bloc.dart';
import 'package:socbay/blocs/auth/login_state.dart';
import 'package:socbay/blocs/root/root_bloc.dart';
import 'package:socbay/blocs/root/root_event.dart';
import 'package:socbay/config/app_localization.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/paths/images.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/utils/logger_util.dart';
import 'package:socbay/widgets/hotline_widget.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:socbay/widgets/my_rich_text.dart';

class SharedPhoneController {
  static final SharedPhoneController instance = SharedPhoneController._();
  SharedPhoneController._();
  final phoneNumberTxtController = TextEditingController();
}

class SharedPassController {
  static final SharedPassController instance = SharedPassController._();
  SharedPassController._();
  final passwordTxtController = TextEditingController();
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController phoneNumberTxtController;
  late TextEditingController passwordTxtController;
  bool isSecurePassword = true;
  late LoginScreenBloc _bloc;
  late final RootBloc _rootBloc;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    _rootBloc = BlocProvider.of(context);
    phoneNumberTxtController =
        SharedPhoneController.instance.phoneNumberTxtController;
    passwordTxtController = SharedPassController.instance.passwordTxtController;
    App.instance.initAccount = null;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginScreenBloc, LoginScreenState>(
      builder: _buildBody,
      listener: _listener,
    );
  }

  void _listener(BuildContext context, LoginScreenState state) {
    if (state is LogInSuccessState) {
      LoggerUtil.info(
        'listener received LogInSuccessState',
        tag: 'LoginScreen',
      );
      _rootBloc.add(LoggedIn());
    }
    if (state is LogInFailureState) {
      LoggerUtil.warning(
        'listener received LogInFailureState message=${state.message}',
        tag: 'LoginScreen',
      );
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          backgroundColor: ColorUtil.white,
          content: Text(
            "Có lỗi trong quá trình đăng nhập",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ColorUtil.bangladeshGreen,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text(
                'OK',
                style: TextStyle(color: ColorUtil.brightYellow),
              ),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
        ),
      );
    }
  }

  Widget _buildBody(BuildContext context, LoginScreenState state) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          isBackNavigation: false,
          backgroundColor: Colors.white,
          systemOverlayStyle: systemUiOverlayStyle.copyWith(
            statusBarColor: Colors.white,
          ),
        ),
        bottomNavigationBar: const HotlineWidget(),
        body: LoadingIndicator(
          isLoading: _bloc.isLoading,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ImageUtil.loadAssetsImage(
                    fileName: Images.iconApp1,
                    width: 150,
                  ),
                ),
                const SizedBox(height: 60),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l('Chào mừng bạn!'),
                        style: const TextStyle(
                          color: ColorUtil.graniteGray,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          l('Đăng nhập để tiếp tục sử dụng Socbay'),
                          style: const TextStyle(
                            color: ColorUtil.spanishGray,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildFormLogin(
                        l('Số điện thoại'),
                        l('Nhập số điện thoại'),
                        phoneNumberTxtController,
                        maxLength: 10,
                      ),
                      const SizedBox(height: 10),
                      _buildFormLogin(
                        l('Mật khẩu'),
                        l('Vui lòng nhập mật khẩu'),
                        passwordTxtController,
                        isPassword: true,
                        isSecure: isSecurePassword,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.forgotPasswordScreen,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16, right: 32),
                          child: Text(
                            l('Quên mật khẩu?'),
                            style: const TextStyle(
                              color: ColorUtil.bangladeshGreen,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: SizedBox(
                          height: 35,
                          width: context.width - 40,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith(
                                (state) => ColorUtil.bangladeshGreen,
                              ),
                            ),
                            onPressed: _onPressLogin,
                            child: Text(
                              l('Đăng nhập').toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: MyRichText(
                          firstText: l('Bạn chưa có tài khoản  '),
                          secondText: l('Đăng ký'),
                          firstTextStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                          secondTextStyle: const TextStyle(
                            color: ColorUtil.bangladeshGreen,
                            fontSize: 13,
                          ),
                          onTapSecond: () {
                            Navigator.pushNamed(context, Routes.register);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormLogin(
    String titleTextField,
    String placeHolder,
    TextEditingController controller, {
    bool isPassword = false,
    bool isSecure = false,
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
          height: 60,
          child: TextField(
            obscureText: isSecure,
            keyboardType: isPassword ? TextInputType.text : TextInputType.phone,
            controller: controller,
            cursorColor: ColorUtil.bangladeshGreen,
            inputFormatters: maxLength != null
                ? [LengthLimitingTextInputFormatter(maxLength)]
                : [],
            style: const TextStyle(color: ColorUtil.raisinBlack),
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
                          isSecurePassword = !isSecurePassword;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ImageUtil.loadAssetsImage(
                          fileName: !isSecure
                              ? "icon_not_secure_password.png"
                              : "icon_secure_password.png",
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

  void _onPressLogin() {
    if (phoneNumberTxtController.text.isEmpty) {
      context.showSnackBar(l('Số điện thoại không được để trống!'));
      return;
    }
    if (phoneNumberTxtController.text.isNotEmpty &&
        phoneNumberTxtController.text.length < 10) {
      context.showSnackBar(l('phone_number_character_warning'));
      return;
    }

    if (passwordTxtController.text.isEmpty) {
      context.showSnackBar(l('password_empty_warning'));
      return;
    }
    _bloc.add(
      LoginEvent(phoneNumberTxtController.text, passwordTxtController.text),
    );
  }
}
