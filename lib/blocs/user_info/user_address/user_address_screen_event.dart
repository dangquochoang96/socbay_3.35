import 'package:socbay/data/model/request/user_address_request.dart';
import 'package:socbay/data/model/user_address.dart';

abstract class UserAddressScreenEvent {
  const UserAddressScreenEvent();
}

class UserAddressScreenGetAddressEvent extends UserAddressScreenEvent {}

class UserAddressScreenCreateUserAddressEvent extends UserAddressScreenEvent {
  final UserAddressRequest userAddressRequest;

  const UserAddressScreenCreateUserAddressEvent(this.userAddressRequest);
}

class UserAddressScreenSetDefaultEvent extends UserAddressScreenEvent {
  final UserAddress userAddress;

  const UserAddressScreenSetDefaultEvent(this.userAddress);
}

class UserAddressScreenUpdateAddressEvent extends UserAddressScreenEvent {
  final UserAddressRequest userAddressRequest;

  const UserAddressScreenUpdateAddressEvent(this.userAddressRequest);
}

class UserAddressScreenDeleteAddressEvent extends UserAddressScreenEvent {
  final UserAddress userAddress;

  const UserAddressScreenDeleteAddressEvent(this.userAddress);
}
