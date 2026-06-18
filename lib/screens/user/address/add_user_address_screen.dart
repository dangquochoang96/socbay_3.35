import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/user_info/user_address/user_address_screen_bloc.dart';
import 'package:socbay/blocs/user_info/user_address/user_address_screen_event.dart';
import 'package:socbay/blocs/user_info/user_address/user_address_screen_state.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/event_bus/event_bus_event.dart';
import 'package:socbay/data/model/request/user_address_request.dart';
import 'package:socbay/data/model/user_address.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:socbay/widgets/my_button.dart';
import 'package:socbay/widgets/text_field_default.dart';

import '../../../utils/color_util.dart';

class AddUserAddressScreen extends StatefulWidget {
  const AddUserAddressScreen({super.key, this.arguments});
  final Object? arguments;

  @override
  State<AddUserAddressScreen> createState() => _AddUserAddressScreenState();
}

class _AddUserAddressScreenState extends State<AddUserAddressScreen> {
  late TextEditingController _nameTextController;

  late TextEditingController _phoneTextController;

  late TextEditingController _addressTextController;

  late TextEditingController _addressDetailTextController;

  late UserAddressScreenBloc _bloc;
  num? _lng;
  num? _lat;

  UserAddress? userAddress;

  @override
  void initState() {
    super.initState();
    if (widget.arguments != null) {
      userAddress = widget.arguments as UserAddress;
      _lat = userAddress?.lat;
      _lng = userAddress?.lng;
      setState(() {
        userAddress = widget.arguments as UserAddress;
      });
    }
    _bloc = BlocProvider.of(context);
    _nameTextController = TextEditingController(
      text: userAddress != null ? userAddress?.name : _bloc.user?.username,
    );
    _phoneTextController = TextEditingController(
      text: userAddress != null ? userAddress?.phone : _bloc.user?.phone,
    );
    _addressTextController = TextEditingController(
      text: userAddress != null ? userAddress?.address : "",
    );
    _addressDetailTextController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserAddressScreenBloc, UserAddressScreenState>(
      builder: _builder,
      listener: _listener,
    );
  }

  void _listener(BuildContext context, UserAddressScreenState state) {
    if (state is UserAddressScreenCreateAddressSuccessState) {
      if (state.error.isEmpty) {
        App.instance.eventBus.fire(EventBusReloadUserAddressEvent());
        Navigator.pop(context);
        context.showSnackBarSuccess("Tạo địa chỉ thành công");
      } else {
        context.showSnackBarError(state.error);
      }
    }
    if (state is UserAddressScreenUpdateAddressSuccessState) {
      if (state.error.isEmpty) {
        App.instance.eventBus.fire(EventBusReloadUserAddressEvent());
        Navigator.pop(context);
        context.showSnackBarSuccess("Chỉnh sửa địa chỉ thành công");
      } else {
        context.showSnackBarError(state.error);
      }
    }
  }

  Widget _builder(BuildContext context, UserAddressScreenState state) {
    return Scaffold(
      appBar: MyAppBar(
        title: userAddress != null ? "Chỉnh sửa địa chị" : "Thêm địa chỉ",
      ),
      body: LoadingIndicator(
        isLoading: _bloc.isLoading,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: paddingHorizontal,
            vertical: paddingVertical,
          ),
          children: [
            _buildTextField(
              controller: _nameTextController,
              hintText: 'Họ và tên',
            ),
            _buildTextField(
              controller: _phoneTextController,
              hintText: 'Số điện thoại',
              isPhoneNumber: true,
            ),
            _buildTextField(
              controller: _addressTextController,
              hintText: 'Địa chỉ',
              isAddress: true,
            ),
            _buildTextField(
              controller: _addressDetailTextController,
              hintText: 'Tên đường, tòa nhà, số nhà',
            ),
            DefaultButton(
              onPressed: _onSubmitAddress,
              text: userAddress != null ? "Sửa" : "Thêm",
              enabled: isAllowSubmit(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool isAddress = false,
    bool isPhoneNumber = false,
  }) {
    return GestureDetector(
      onTap: isAddress
          ? () async {
              await Navigator.of(context).pushNamed(Routes.mapScreen).then((
                value,
              ) {
                if (value == null) return;
                Map<String, dynamic>? result = value as Map<String, dynamic>?;
                if (result != null) {
                  _addressTextController.text = result['address'];
                  setState(() {
                    _lat = result['lat'];
                    _lng = result['lng'];
                  });
                }
              });
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextFieldDefault(
          enabled: !isAddress,
          controller: controller,
          onChanged: (String text) {
            setState(() {});
          },
          keyboardType: isPhoneNumber
              ? TextInputType.phone
              : TextInputType.text,
          maxLength: isPhoneNumber ? 10 : null,
          hintText: hintText,
          label: Text(hintText),
          suffixIcon: isAddress
              ? IconButton(
                  iconSize: 14,
                  onPressed: () {},
                  icon: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: ColorUtil.bangladeshGreen,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  bool isAllowSubmit() =>
      _nameTextController.text.trim().isNotEmpty &&
      _phoneTextController.text.trim().isNotEmpty &&
      _addressTextController.text.trim().isNotEmpty;

  void _onSubmitAddress() {
    String detailAddress = _addressDetailTextController.text.trim();
    String address = _addressTextController.text.trim();
    if (detailAddress.isNotEmpty) {
      address = "$detailAddress - $address";
    }
    if (userAddress == null) {
      _bloc.add(
        UserAddressScreenCreateUserAddressEvent(
          UserAddressRequest(
            name: _nameTextController.text.trim(),
            phone: _phoneTextController.text.trim(),
            address: address,
            lat: _lat ?? -1,
            lng: _lng ?? -1,
            isDefault: 0,
            cityCode: "AGG",
            stateCode: "dt",
          ),
        ),
      );
    } else {
      _bloc.add(
        UserAddressScreenUpdateAddressEvent(
          UserAddressRequest(
            name: _nameTextController.text.trim(),
            phone: _phoneTextController.text.trim(),
            address: address,
            lat: _lat ?? -1,
            lng: _lng ?? -1,
            isDefault: userAddress?.isDefault ?? 0,
            cityCode: "AGG",
            stateCode: "dt",
            id: userAddress?.id ?? "",
          ),
        ),
      );
    }
  }
}
