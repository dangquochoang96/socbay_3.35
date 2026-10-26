abstract class DetailBookingState {}

class DetailBookingInitialState extends DetailBookingState {}

class DetailBookingLoadingState extends DetailBookingState {}

class DetailBookingErrorState extends DetailBookingState {
  final String? message;
  DetailBookingErrorState({this.message});
}
