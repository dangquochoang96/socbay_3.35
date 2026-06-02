import 'package:socbay/blocs/staff/new_task_sale/staff_service_screen_sale_bloc.dart';
import 'package:socbay/constants/api_endpoints.dart';

class RentBookingServiceBloc extends StaffServiceSaleScreenBloc {
  RentBookingServiceBloc({required super.apiRepository, required super.args})
    : super(createTaskEndpoint: ApiEndpoints.rentTaskCreate);
}
