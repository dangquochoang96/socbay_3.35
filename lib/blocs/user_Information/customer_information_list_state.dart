import 'package:socbay/data/model/user_profile.dart';

abstract class CustomerInformationListState {
  const CustomerInformationListState();
}

class CustomerInformationListInitialState extends CustomerInformationListState {}

class CustomerInformationListLoadedState extends CustomerInformationListState {
  final List<UserProfile> customerInformationList;

  const CustomerInformationListLoadedState(this.customerInformationList);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CustomerInformationListLoadedState &&
              runtimeType == other.runtimeType &&
              customerInformationList == other.customerInformationList;

  @override
  int get hashCode => customerInformationList.hashCode;
}

class CustomerInformationListErrorState extends CustomerInformationListState {
  final String error;

  const CustomerInformationListErrorState(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CustomerInformationListErrorState &&
              runtimeType == other.runtimeType &&
              error == other.error;

  @override
  int get hashCode => error.hashCode;
}