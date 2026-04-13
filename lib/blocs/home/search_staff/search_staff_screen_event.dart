import 'package:socbay/data/model/request/staff_by_distance_request.dart';

abstract class SearchStaffScreenEvent {
  const SearchStaffScreenEvent();
}

class SearchStaffScreenGetStaffEvent extends SearchStaffScreenEvent {
  final StaffByDistanceRequest staffByDistanceRequest;

  SearchStaffScreenGetStaffEvent(this.staffByDistanceRequest);
}

class SearchStaffScreenGetTaskEvent extends SearchStaffScreenEvent {}
