abstract class UserAddressScreenState {
  const UserAddressScreenState();
}

class UserAddressScreenInitialState extends UserAddressScreenState {}

class UserAddressScreenCreateAddressSuccessState
    extends UserAddressScreenState {
  final String error;

  const UserAddressScreenCreateAddressSuccessState({this.error = ""});
}
class UserAddressScreenUpdateAddressSuccessState
    extends UserAddressScreenState {
  final String error;

  const UserAddressScreenUpdateAddressSuccessState({this.error = ""});
}
