import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/logger_util.dart';
import 'package:socbay/widgets/dialog/custom_alert_dialog.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:location/location.dart' as location_dart;
import 'package:socbay/widgets/my_button.dart';
import 'package:uuid/uuid.dart';

import '../utils/theme_util.dart';

const double defaultLat = 21.0278; // HaNoi
const double defaultLng = 105.8342; // HaNoi

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  late TextEditingController _addressTextController;
  location_dart.LocationData? _locationData;
  CameraPosition? _kGooglePlex;
  CameraPosition? _myLocation;
  CameraPosition? _addressLocation;
  String address = "";
  bool isLoading = true;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  double? markLat;
  double? markLng;

  @override
  void initState() {
    super.initState();
    _initGetGeoLocationPosition();
    _addressTextController = TextEditingController();
  }

  Future _initGetGeoLocationPosition() async {
    if (await requestPermission()) {
      location_dart.Location location = location_dart.Location();
      _locationData = await location.getLocation();
      final lat = _locationData?.latitude ?? defaultLat;
      final long = _locationData?.longitude ?? defaultLng;
      setState(() {
        _kGooglePlex = CameraPosition(
          target: LatLng(lat, long),
          zoom: 17,
        );
        _myLocation = CameraPosition(target: LatLng(lat, long), zoom: 14);
      });

      await _onSetLatLong(lat, long);
    } else {
      context.showSnackBar("Vui lòng cấp quyền chia sẻ vị trí.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: MyAppBar(
        isBackNavigation: true,
        title: "Chọn địa chỉ",
        centerTitle: true,
      ),
      body: LoadingIndicator(
        isLoading: isLoading,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _addressBox(),
            Expanded(child: _buildMap()),
          ],
        ),
      ),
      floatingActionButton: _myLocation == null
          ? null
          : FloatingActionButton(
              onPressed: _moveToCurrentLocation,
              child: const Icon(Icons.location_searching_sharp),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _addressBox() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: paddingHorizontal,
        vertical: paddingVertical,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _addressTextController,
              keyboardType: TextInputType.text,
              cursorColor: ColorUtil.bangladeshGreen,
              onSubmitted: (String text) {
                setState(() {
                  address = text;
                });
                _onSearch();
              },
              onChanged: (String text) {
                setState(() {});
              },
              decoration: InputDecoration(
                  counterText: "",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelStyle: const TextStyle(
                      color: ColorUtil.bangladeshGreen,
                      fontSize: 18,
                      fontWeight: MyFontWeight.bold),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                        color: ColorUtil.bangladeshGreen, width: 0.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                        color: ColorUtil.bangladeshGreen, width: 0.5),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _onSearch,
                  )),
            ),
          ),
          const SizedBox(width: 8),
          DefaultButton(
            color: address.isEmpty ? Colors.grey : ColorUtil.bangladeshGreen,
            text: "Chọn",
            onPressed: address.isEmpty
                ? null
                : () {
                    Navigator.pop(context, {
                      "lat": markLat,
                      "lng": markLng,
                      "address": address,
                    });
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return _kGooglePlex != null
        ? GoogleMap(
            minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            onTap: (LatLng latLng) async {
              _onSetLatLong(latLng.latitude, latLng.longitude);
            },
            markers: Set<Marker>.of(markers.values),
            initialCameraPosition: _kGooglePlex!,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          )
        : const SizedBox();
  }

  Future<void> _moveToCurrentLocation() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_myLocation!));
  }

  Future<bool> requestPermission() async {
    if (await Permission.location.request().isGranted == true) {
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

  Future<String?> getAddressFromLatLong(double lat, double lng) async {
    Placemark? placeMark = await getPlaceMarkFromLatLong(lat, lng);
    if (placeMark == null) {
      context.showSnackBarError("Có lỗi xảy ra");
      return null;
    }
    String addressFromLatLong =
        "${placeMark.street}, ${placeMark.subAdministrativeArea} - ${placeMark.administrativeArea} - ${placeMark.country}";
    LoggerUtil.log(
        "addressFromLatLong: $addressFromLatLong - isoCountryCode:${placeMark.isoCountryCode} -postalCode:${placeMark.postalCode} ");
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

  void _addMarker() {
    var markerIdVal = const Uuid().v1();
    final MarkerId markerId = MarkerId(markerIdVal);

    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(markLat!, markLng!),
      infoWindow: InfoWindow(title: address, snippet: '*'),
      onTap: () {},
      draggable: true,
        onDragEnd: ((newPosition) {
          markLat = newPosition.latitude;
          markLng = newPosition.longitude;
        })
    );
    markers.clear();
    setState(() {
      markers[markerId] = marker;
    });
  }

  void _onSearch() async {
    try {
      setState(() {
        isLoading = true;
      });
      List<Location> locations =
          await locationFromAddress(_addressTextController.text);

      if (locations.isNotEmpty) {
        Location location = locations.first;
        _onSetLatLong(location.latitude, location.longitude);
      } else {
        context.showSnackBarError("Địa chỉ trên không tồn tại");
      }
      setState(() {
        address = _addressTextController.text;
        isLoading = false;
      });
    } catch (e) {
      context.showSnackBarError("Địa chỉ không tồn tại");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future _onSetLatLong(double lat, double lng) async {
    setState(() {
      isLoading = true;
    });
    String? addressFromLatLong = await getAddressFromLatLong(lat, lng);
    if (addressFromLatLong == null) return;
    markLat = lat;
    markLng = lng;
    _addMarker();
    _addressTextController.text = addressFromLatLong;
    _addressLocation = CameraPosition(target: LatLng(lat, lng), zoom: 14);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_addressLocation!));
    setState(() {
      address = addressFromLatLong;
      isLoading = false;
    });
  }
}
