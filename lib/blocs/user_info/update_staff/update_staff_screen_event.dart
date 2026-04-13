import 'package:socbay/data/model/request/update_staff_request_model.dart';

abstract class UpdateStaffEvent {
  const UpdateStaffEvent();
}

class UpdateStaffScreenEvent extends UpdateStaffEvent {
  final UpdateStaffRequestModel updateStaffRequestModel;

  const UpdateStaffScreenEvent(this.updateStaffRequestModel);
}
