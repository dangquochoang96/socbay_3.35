import 'package:socbay/data/model/request/staff_by_distance_request.dart';

abstract class FindStaffEvent{}
class FindStaffStartEvent extends FindStaffEvent{}
class FindStaffGetUserAddressEvent extends FindStaffEvent{}
class FindStaffScreenGetStaffEvent extends FindStaffEvent{
  final StaffByDistanceRequest staffByDistanceRequest;

  FindStaffScreenGetStaffEvent(this.staffByDistanceRequest);
}