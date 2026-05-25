import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socbay/blocs/FindStaff/find_staff_bloc.dart';
import 'package:socbay/blocs/FindStaff/find_staff_event.dart';
import 'package:socbay/blocs/FindStaff/find_staff_state.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/request/staff_by_distance_request.dart';
import 'package:socbay/data/model/user_address.dart';
// import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/paths/images.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/utils/logger_util.dart';
// import 'package:socbay/utils/theme_util.dart';
// import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/dialog/custom_alert_dialog.dart';
import 'package:socbay/widgets/indicator_loadmore.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';

const double defaultLat = 21.0278; // HaNoi
const double defaultLng = 105.8342; // HaNoi
class FindStaffScreen extends StatefulWidget{
  const FindStaffScreen({super.key});
  @override
  State<FindStaffScreen> createState() => _SearchStaffScreenState();
}

class _SearchStaffScreenState extends State<FindStaffScreen>{
  late FindStaffBloc _bloc;
  final Completer<GoogleMapController> _controller = Completer();
  late TextEditingController _addressController;
  CameraPosition? _kGooglePlex;
  // CameraPosition? _myLocation;
  UserAddress? _userAddress;
  bool isLoading = false;
  late List<Marker> _markers = <Marker>[];
  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    _bloc.add(FindStaffGetUserAddressEvent());
    _addressController = TextEditingController();
    _initGetGeoLocationPosition();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FindStaffBloc, FindStaffState>(
        builder: _builder, listener: _listener);
  }
  void _listener(BuildContext context, FindStaffState state){
    if(state is FindStartGetUserAddressSuccessState){
      _userAddress = _bloc.listUserAddress.firstWhere((element) => element.isDefaultAddress(), orElse: () => UserAddress());
    }
    if (_bloc.staffsInfo.isNotEmpty) {
      for (int i = 0; i < _bloc.staffsInfo.length; i++) {
        _markers.add(Marker(
          markerId: MarkerId(_bloc.staffsInfo[i].id.toString()),
          position: LatLng(_bloc.staffsInfo[i].lat!.toDouble(),
              _bloc.staffsInfo[i].lng!.toDouble()),
          infoWindow:
          InfoWindow(title: _bloc.staffsInfo[i].address, snippet: '*'),
        ));
      }
    }
  }
  Widget _builder(BuildContext context, FindStaffState state){
    return Scaffold(
      appBar: MyAppBar(
        isBackNavigation: false,
        title: 'Tìm thợ',
        centerTitle: true
      ),
      body: LoadingIndicator(
          isLoading: _bloc.isLoading,
          child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: paddingHorizontal, vertical: paddingVertical),
              child: Column(
                children: [
                  _buildInfoField(onTap: () {
                    _onTapEditInfo();
                  }),
                  const SizedBox(
                    height: 10,
                  ),
                  Stack(
                    children: [
                      ///MAP
                      _buildMap(),
                    ],
                  ),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  // Expanded(
                  //   child: _bloc.staffsInfo.isNotEmpty
                  //       ? _buildListStaff()
                  //       : Container(
                  //           padding: const EdgeInsets.symmetric(
                  //               horizontal: 16.0),
                  //           decoration: BoxDecoration(
                  //               borderRadius: BorderRadius.circular(14),
                  //               border: Border.all(
                  //                   color: ColorUtil.bangladeshGreen)
                  //           ),
                  //         child: Column(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           crossAxisAlignment:
                  //           CrossAxisAlignment.stretch,
                  //           children: [
                  //             const Text(
                  //               "Tạm thời không có thợ nào quanh đây.Chúng tôi sẽ sắp xếp và liên hệ tới bạn sớm nhất",
                  //               style: TextStyle(
                  //                   fontWeight: FontWeight.bold,
                  //                   color: ColorUtil.red),
                  //             ),
                  //             Flexible(
                  //                 child: DefaultButton(
                  //                   onPressed: () {
                  //                     App.instance.eventBus.fire(
                  //                         EventBusFinishSearchStaffEvent());
                  //                     Navigator.popUntil(
                  //                         context, (route) => route.isFirst);
                  //                   },
                  //                   text: "Hoàn thành",
                  //                 )),
                  //           ],
                  //         ),
                  //   ),
                  // )
                ],
              ))),
    );
  }
  // Widget _buildListStaff() {
  //   return ListView.separated(
  //       itemBuilder: _itemBuilder,
  //       separatorBuilder: _buildSeparator,
  //       itemCount: _bloc.staffsInfo.length);
  // }
  // Widget _buildSeparator(BuildContext context, int index) {
  //   return const SizedBox(height: 12);
  // }
  // Widget _itemBuilder(BuildContext context, int index) {
  //   final UserProfile staffInfo = _bloc.staffsInfo[index];
  //   return GestureDetector(
  //     onTap: () {
  //       _goToStaffInfo(staffInfo);
  //     },
  //     child: Container(
  //         decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(14),
  //             border: Border.all(color: ColorUtil.bangladeshGreen)),
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
  //           child: Row(
  //             children: [
  //               ClipRRect(
  //                 borderRadius: BorderRadius.circular(50),
  //                 child: ImageUtil.loadNetWorkImage(
  //                     url: staffInfo.avatar ?? '', height: 50, width: 50),
  //               ),
  //               const SizedBox(width: 16),
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Text(
  //                       "${staffInfo.username}",
  //                       style: const TextStyle(fontWeight: MyFontWeight.bold),
  //                     ),
  //                     Text("${staffInfo.phone}"),
  //                   ],
  //                 ),
  //               ),
  //               const Text(
  //                 "Xem chi tiết >",
  //                 style: TextStyle(
  //                     color: ColorUtil.bangladeshGreen,
  //                     decoration: TextDecoration.underline),
  //               ),
  //             ],
  //           ),
  //         )),
  //   );
  // }
  // Future _goToStaffInfo(UserProfile staffInfo) async {
  //   // await Navigator.pushNamed(context, Routes.staffInfoScreen, arguments: {
  //   //   "id": _bloc.args["id"],
  //   //   "name": _listNameService[_index ?? 0],
  //   //   "idService": _listService[_index ?? 0].id,
  //   //   "staffInfo": staffInfo
  //   // });
  // }
  Widget _buildMap() {
    return _kGooglePlex != null
        ? Stack(
            children: [
              SizedBox(
                height: 200,
                child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: Set.from(_markers),
                  onTap: (LatLng latLng) async {
                    setState(() {
                      isLoading = true;
                      _markers = [];
                      _markers.add(
                          Marker(
                            markerId: MarkerId(latLng.toString()),
                            position: latLng
                          )
                      );
                    });
                    String? addressFromLatLong = await getAddressFromLatLong(
                      latLng.latitude,
                      latLng.longitude,
                    );
                    if (addressFromLatLong == null) {
                      return;
                    } else {
                      setState(() {
                        _addressController.text = "123";
                      });
                    }
                  },

                  initialCameraPosition: _kGooglePlex!,

                ),
              ),
              GestureDetector(
                onTap: _onSearchStaff,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ImageUtil.loadAssetsImage(
                      fileName: Images.iconReset, width: 30, height: 30),
                ),
              )
            ],
    )
        : const IndicatorLoadMore();
  }

  Future _onSearchStaff() async {
    _bloc.add(FindStaffScreenGetStaffEvent(StaffByDistanceRequest(
        lat: _userAddress?.lat ?? defaultLat,
        lng: _userAddress?.lng ?? defaultLng,
        distance: 2000)));
  }
  Future<String?> getAddressFromLatLong(double lat, double lng) async {
    Placemark? placeMark = await getPlaceMarkFromLatLong(lat, lng);
    if (placeMark == null) {
      context.showSnackBarError("Có lỗi xảy ra");
      return null;
    }
    String addressFromLatLong =
        "${placeMark.street}, ${placeMark.subAdministrativeArea} - ${placeMark.administrativeArea} - ${placeMark.country}";
    LoggerUtil.log("LAT_LNG $lat $lng");
    LoggerUtil.log("ADDRESS_TAP $addressFromLatLong");
    return addressFromLatLong;
  }
  Future<Placemark?> getPlaceMarkFromLatLong(double lat, double lng) async {
    List<Placemark> placeMarks = await placemarkFromCoordinates(lat, lng);
    if (placeMarks.isEmpty) {
      context.showSnackBarError("Có lỗi xảy ra");
      return null;
    }
    return placeMarks.first;
  }
  Widget _buildInfoField({required void Function() onTap}) {
    _userAddress = _bloc.listUserAddress.firstWhere((element) => element.isDefaultAddress(), orElse: () => UserAddress());
    return GestureDetector(
        onTap: onTap,
        child: TextFormField(
          controller: _addressController
            ..text =
                "${_userAddress?.name ?? ""}\n${_userAddress?.phone ?? ""}\n${_userAddress?.address ?? ""}",
          enableInteractiveSelection: false,
          enabled: false,
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
              labelText: 'Thông tin công việc\n(chọn để sửa)',
              labelStyle: const TextStyle(color: ColorUtil.bangladeshGreen),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                    color: ColorUtil.bangladeshGreen, width: 0.5),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always),
        ));
  }
  void _onTapEditInfo() async {
    // await Navigator.of(context).pushNamed(Routes.editServiceScreen,
    //     arguments: {"id": _bloc.args['id']}).then((value) async {
    //   if (value == null) {
    //     return;
    //   } else {
    //     Map<String, dynamic>? result = value as Map<String, dynamic>?;
    //     if (result != null) {
    //       setState(() {
    //         _addMarker();
    //         _bloc.add(SearchStaffScreenGetTaskEvent());
    //         _bloc.add(SearchStaffScreenGetStaffEvent(StaffByDistanceRequest(
    //             lat: _bloc.taskModel?.lat ?? defaultLat,
    //             lng: _bloc.taskModel?.lng ?? defaultLng,
    //             distance: 2000)));
    //       });
    //     }
    //   }
    // });
  }
  Future _initGetGeoLocationPosition() async {
    _userAddress = _bloc.listUserAddress.firstWhere((element) => element.isDefaultAddress(), orElse: () => UserAddress());
    if (await requestPermission()) {
      final lat = _userAddress?.lat ?? defaultLat;
      final long = _userAddress?.lat ?? defaultLng;
      setState(() {
        _kGooglePlex = CameraPosition(
          target: LatLng(lat, long),
          zoom: 17,
        );
        // _myLocation = CameraPosition(target: LatLng(lat, long), zoom: 14);
      });
    } else {
      context.showSnackBar("Vui lòng cấp quyền chia sẻ vị trí.");
    }
  }
  Future<bool> requestPermission() async {
    if (await Permission.location.request().isGranted == true) {
      LoggerUtil.log("request true");
      return true;
    } else {
      CustomAlertDialog.show(
        context,
        leftText: "Cài đặt",
        rightText: "Hủy",
        isLeftPositive: true,
        leftAction: () {
          Navigator.pop(context);
          openAppSettings();
        },
        content: 'Vui lòng cấp quyền chia sẻ vị trí.',
      );
      return false;
    }
  }
  // Future<bool> _onWillPop() async {
  //   final shouldPop = await showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: const Text('Bạn có muốn thoát không?'),
  //         content: const Text('Dịch vụ vẫn được lưu trong mục tìm kiếm'),
  //         actions: <Widget>[
  //           Row(
  //             children: [
  //               _buildButton(
  //                   text: 'THOÁT',
  //                   isPositive: true,
  //                   action: () {
  //                     Navigator.pop(context);
  //                     Navigator.pop(context);
  //                   }),
  //               const SizedBox(
  //                 width: 5,
  //               ),
  //               _buildButton(
  //                   text: 'HỦY',
  //                   isPositive: false,
  //                   action: () {
  //                     Navigator.pop(context);
  //                   }),
  //             ],
  //           )
  //         ],
  //       ));
  //   return shouldPop ?? false;
  // }
  // Widget _buildButton({text, isPositive, action}) {
  //   return Expanded(child: _button(isPositive, action, text));
  // }
  // StatelessWidget _button(isPositive, action, text) {
  //   return ButtonWidget(
  //       color: isPositive ? ColorUtil.bangladeshGreen : Colors.grey,
  //       borderRadius: BorderRadius.circular(30),
  //       padding: const EdgeInsets.symmetric(vertical: 10),
  //       onTap: () {
  //         if (action == null) {
  //           Navigator.pop(context);
  //         } else {
  //           action();
  //         }
  //       },
  //       child: Text(
  //         text,
  //         textAlign: TextAlign.center,
  //         style: const TextStyle(fontSize: 16, color: Colors.white),
  //       ));
  // }


}