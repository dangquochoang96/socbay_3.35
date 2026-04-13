abstract class AccountInfoState {
  const AccountInfoState();
}

class AccountInfoInitialState extends AccountInfoState {}
class AccountInfoGetDetailState extends AccountInfoState {
}
class AccountInfoUpdateDoneState extends AccountInfoState {
  final bool isSuccess;
  final String? error;

  const AccountInfoUpdateDoneState({required this.isSuccess, this.error});
}
class UploadImageSuccessState extends AccountInfoState {
  final String path;

  const UploadImageSuccessState(this.path);
}

class UploadImageFailedState extends AccountInfoState {
  final String message;

  const UploadImageFailedState(this.message);
}