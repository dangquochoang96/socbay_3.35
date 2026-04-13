import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socbay/blocs/home/feedback/feedback_screen_bloc.dart';
import 'package:socbay/blocs/home/feedback/feedback_screen_event.dart';
import 'package:socbay/blocs/home/feedback/feedback_screen_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/order_filter_core_model.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/file_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/dialog/custom_alert_dialog.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with TickerProviderStateMixin {
  late FeedbackScreenBloc _bloc;
  late TabController _tabController;
  late TextEditingController describeRequestTxtController;
  late final ImagePicker _picker;
  final List<String> _listFile = [];
  final List<OrderFilterCoreModel> _listOrders = [];
  String? _selectedValue;
  int page = 0;

  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    _tabController = TabController(
      length: 2,
      initialIndex: 0,
      vsync: this,
    );
    if (_tabController.index == 0) {
      _bloc.add(FeedbackScreenTabPressEvent(_tabController.index));
    }
    _tabController.addListener(() {
      if (_tabController.index != _tabController.previousIndex) {
        _bloc.add(FeedbackScreenTabPressEvent(_tabController.index));
      }
    });

    describeRequestTxtController = TextEditingController();
    _picker = ImagePicker();
    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    _tabController.dispose();
    describeRequestTxtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeedbackScreenBloc, FeedbackScreenState>(
        builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, FeedbackScreenState state) {
    if (state is FeedbackScreenChangeTabState) {
      setState(() {
        if (state.index == 0) {
          _listOrders.clear();
          _listOrders.add(OrderFilterCoreModel(id: 0, name: "--Chọn--"));
          _listOrders.addAll(_bloc.ordersModel);
          _selectedValue = _bloc.currentOrderId.toString();
          describeRequestTxtController.clear();
        } else {
          _tabController.index = 1;
        }
      });
    }
    if (state is FeedbackUploadImagesSuccessState) {
      for (var element in state.paths) {
        _listFile.add(element);
      }
    }
    if (state is FeedbackCreateSuccessState) {
      context.showSnackBar("Phản hồi thành công!");
    }
    if (state is FeedbackCreateErrorState) {
      context.showSnackBar("Phản hồi không thành công!");
    }
  }

  Widget _builder(BuildContext context, FeedbackScreenState state) {
    return Scaffold(
      appBar: MyAppBar(
        isBackNavigation: true,
        title: 'Góp ý và khiếu nại',
        centerTitle: true,
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: ColorUtil.bangladeshGreen,
            tabs: [
              _buildTab('Tạo mới'),
              _buildTab('Đã gửi'),
            ],
          ),
          Expanded(
            child: IndexedStack(
              index: _tabController.index,
              children: [_buildCreateFeedback(), _buildListFeedback()],
            ),
          )
        ],
      ),
    );
  }

  Tab _buildTab(text) {
    return Tab(
        height: 36,
        child: Text(
          text,
          style:
              const TextStyle(color: ColorUtil.bangladeshGreen, fontSize: 20),
        ));
  }

  Widget _buildCreateFeedback() {
    return LoadingIndicator(
        isLoading: _bloc.isLoading,
        child: ListView(
          padding: const EdgeInsets.symmetric(
              horizontal: paddingHorizontal, vertical: paddingVertical),
          children: [
            _buildField(Icons.feedback_outlined, null,
                value: "Góp ý và khiếu nại", onTap: () {}),
            const SizedBox(
              height: 10,
            ),
            _buildDropdownFieldOrders(),
            const SizedBox(
              height: 10,
            ),
            _buildFormDescribe('Mô tả yêu cầu', describeRequestTxtController,
                Icons.description_outlined, null),
            const SizedBox(
              height: 10,
            ),
            _buildSectionMedia(),
            const SizedBox(
              height: 10,
            ),
            _buildButton(
                text: 'GỬI',
                isPositive: true,
                action: () {
                  _onCreateFeedBack();
                })
          ],
        ));
  }

  Future _onCreateFeedBack() async {
    if (_selectedValue == null || _selectedValue!.trim() == "0") {
      context.showSnackBar("Đơn hàng không hợp lệ!");
      return;
    }
    _bloc.add(FeedbackCreateEvent(
        orderId: _selectedValue ?? "",
        description: describeRequestTxtController.text,
        images: _listFile));
  }

  Widget _buildListFeedback() {
    if (_bloc.feedBacksModel.isNotEmpty) {
      return LoadingIndicator(
          isLoading: _bloc.isLoading,
          child: ListView.separated(
              itemBuilder: _buildItemServiceHistory,
              separatorBuilder: separatorBuilder,
              itemCount: _bloc.feedBacksModel.length));
    }
    return const Center(child: Text('Lịch sử máy'));
  }

  Widget _buildItemServiceHistory(BuildContext context, int index) {
    return Column(children: [
      ButtonWidget(
          onTap: () {
            Navigator.pushNamed(context, Routes.detailFeedBackScreen,
                arguments: {
                  "fbId": _bloc.feedBacksModel[index].id.toString(),
                  "orderId": "0"
                });
          },
          child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: paddingHorizontal, vertical: 8),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                padding: const EdgeInsets.only(
                                  bottom: 1, // space between underline and text
                                ),
                                decoration: const BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                  color:
                                      ColorUtil.raisinBlack, // Text colour here
                                  width: 1.0, // Underline width
                                ))),
                                child: Text(
                                    'Mã đơn hàng: ĐH_${_bloc.feedBacksModel[index].orderId}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ColorUtil.raisinBlack,
                                        fontSize: 16)))
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 3)
                  ]))),
      Padding(
        padding: const EdgeInsets.only(left: 20, top: 0, bottom: 10, right: 8),
        child: Table(
          columnWidths: const {1: FlexColumnWidth(2)},
          children: [
            TableRow(
              children: [
                const Text(
                  "Trạng thái dịch vụ: ",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Text(_bloc.feedBacksModel[index].getStatus())
              ],
            ),
            TableRow(children: [
              const Text('Mô tả: ',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              Text(_bloc.feedBacksModel[index].description ?? '',
                  style: const TextStyle(fontSize: 15)),
            ]),
          ],
        ),
      )
    ]);
  }

  Widget separatorBuilder(BuildContext context, int index) {
    return Container(
        decoration: const BoxDecoration(
            border: Border(
      bottom: BorderSide(width: 1.0, color: Colors.black26),
    )));
  }

  Widget _buildButton({text, isPositive, action}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: _button(isPositive, action, text),
    );
  }

  StatelessWidget _button(isPositive, action, text) {
    return ButtonWidget(
        color: isPositive ? ColorUtil.bangladeshGreen : Colors.grey,
        borderRadius: BorderRadius.circular(30),
        padding: const EdgeInsets.symmetric(vertical: 10),
        onTap: () {
          if (action == null) {
            Navigator.pop(context);
          } else {
            action();
          }
        },
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ));
  }

  Widget _buildField(
    IconData iconPrefix,
    IconData? iconSuffix, {
    required String value,
    required void Function() onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 5,
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
              height: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border:
                      Border.all(color: ColorUtil.bangladeshGreen, width: 0.5)),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Icon(
                      iconPrefix,
                      color: ColorUtil.spanishGray,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(value,
                        style: TextStyle(
                            color: value.isEmpty
                                ? ColorUtil.silverChalice
                                : ColorUtil.raisinBlack),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      iconSuffix,
                      color: ColorUtil.spanishGray,
                    ),
                  ),
                ],
              )),
        ),
      ],
    );
  }

  // Widget _buildForm(
  //   String placeHolder,
  //   TextEditingController controller,
  //   IconData iconPrefix,
  //   IconData? iconSuffix, {
  //   bool isNumberType = false,
  //   bool isReadOnly = false,
  //   bool haveSuffixIcon = false,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Container(
  //         padding: const EdgeInsets.only(top: 5),
  //         height: 40,
  //         child: TextFormField(
  //             readOnly: isReadOnly,
  //             keyboardType:
  //                 isNumberType ? TextInputType.phone : TextInputType.text,
  //             controller: controller,
  //             cursorColor: ColorUtil.bangladeshGreen,
  //             decoration: InputDecoration(
  //               prefixIcon: Icon(iconPrefix),
  //               suffixIcon: haveSuffixIcon ? Icon(iconSuffix) : null,
  //               enabledBorder: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(8.0),
  //                 borderSide: const BorderSide(
  //                     color: ColorUtil.bangladeshGreen, width: 0.5),
  //               ),
  //               focusedBorder: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(8.0),
  //                 borderSide: const BorderSide(
  //                     color: ColorUtil.bangladeshGreen, width: 0.5),
  //               ),
  //               hintText: placeHolder,
  //               hintStyle: const TextStyle(
  //                   color: ColorUtil.silverChalice, fontSize: 13),
  //               contentPadding:
  //                   const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
  //               suffixIconConstraints:
  //                   const BoxConstraints(minHeight: 20, minWidth: 20),
  //             )),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildFormDescribe(
    String placeHolder,
    TextEditingController controller,
    IconData iconPrefix,
    IconData? iconSuffix, {
    // bool isNumberType = false,
    bool isReadOnly = false,
    bool haveSuffixIcon = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 5),
          child: TextFormField(
              readOnly: isReadOnly,
              keyboardType: TextInputType.multiline,
                  // isNumberType ? TextInputType.phone : TextInputType.text,
              controller: controller,
              maxLines: 5,
              cursorColor: ColorUtil.bangladeshGreen,
              decoration: InputDecoration(
                prefixIcon: SizedBox(
                  width: 20,
                  height: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 5.0),
                        child: Icon(iconPrefix),
                      ),
                    ],
                  ),
                ),
                suffixIcon: haveSuffixIcon ? Icon(iconSuffix) : null,
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
                hintText: placeHolder,
                hintStyle: const TextStyle(
                    color: ColorUtil.silverChalice, fontSize: 13),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                suffixIconConstraints:
                    const BoxConstraints(minHeight: 20, minWidth: 20),
              )),
        ),
      ],
    );
  }

  Widget _buildSectionMedia() {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: ColorUtil.bangladeshGreen, width: 0.5),
          borderRadius: BorderRadius.circular(8.0)),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
      child: Column(
        children: [
          Row(
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.upload_file,
                  color: ColorUtil.spanishGray,
                ),
              ),
              Flexible(
                  child: Text(
                'Up ảnh (tối đa 4 ảnh) và video (tối đa 15s) để kỹ thuật xem xét.',
                style: TextStyle(color: ColorUtil.spanishGray),
              ))
            ],
          ),
          SizedBox(
              height: 200,
              width: double.infinity,
              child: ListView.builder(
                itemCount: _listFile.length + 1,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return index < _listFile.length
                      ? _buildItemMedia(_listFile[index])
                      : _buildDefaultItemMedia();
                },
              )),
        ],
      ),
    );
  }

  Widget _buildDefaultItemMedia() {
    return GestureDetector(
      onTap: _showModalBottomSheetMedia,
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: ColorUtil.bangladeshGreen, width: 0.5),
        ),
        child: const Icon(Icons.add_circle_outline),
      ),
    );
  }

  void _showModalBottomSheetMedia() {
    showModalBottomSheet(
        useSafeArea: true,
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Image'),
                onTap: _onChooseImages,
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  // Widget _buildDefaultItemMedia() {
  //   return GestureDetector(
  //     onTap: _onChooseImages,
  //     child: Container(
  //       height: 120,
  //       width: 120,
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(8.0),
  //         border: Border.all(color: ColorUtil.bangladeshGreen, width: 0.5),
  //       ),
  //       child: const Icon(Icons.add_circle_outline),
  //     ),
  //   );
  // }

  Widget _buildItemMedia(String path) {
    return Row(
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: ImageUtil.loadNetWorkImage(
                  url: "$protocol${AppConfig.instance.values.apiUrl}" + path,
                  width: 120,
                  height: 200),
            ),
            Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _listFile.remove(path);
                    });
                  },
                ))
          ],
        ),
        const SizedBox(
          width: 5.0,
        ),
      ],
    );
  }

  Widget _buildDropdownFieldOrders() {
    return FormField<String>(
      builder: (FormFieldState<String> state) {
        return InputDecorator(
          decoration: InputDecoration(
              errorStyle:
                  const TextStyle(color: Colors.redAccent, fontSize: 16.0),
              hintText: 'Please select expense',
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
              prefixIcon: const Icon(Icons.account_box_outlined)),
          isEmpty: false,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedValue,
              isDense: true,
              isExpanded: true,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedValue = newValue;
                });
              },
              items: _listOrders.map((OrderFilterCoreModel sv) {
                return DropdownMenuItem<String>(
                    value: sv.id.toString(),
                    child: Text(sv.id == 0
                        ? "--Chọn--"
                        :
                        //"${sv.product!=null?"${sv.product}:":""}${sv.id! > 0 ? sv.id.toString() : ""}-${sv.name}"),
                        "${sv.product} - ${_createdDateConvert(sv.createdAt)}: Mã đơn ${sv.id}"));
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  String _createdDateConvert(String? dateTime) {
    if (dateTime == null) {
      return "";
    }
    return dateTime.substring(0, 10);
  }

  // void _onChooseMedia() async {
  //   File? file = await onGetPhotoFromGallery(
  //       context: context, funcPermission: () {}, picker: _picker);
  //   if (file != null) {
  //     setState(() {
  //       if (_listFile.length < 4) {
  //         _listFile.add(file);
  //       } else {
  //         context.showSnackBar('Chỉ được chọn tối đa 4 ảnh!');
  //         return;
  //       }
  //     });
  //   }
  // }
  void _onChooseImages() async {
    Navigator.of(context).pop();
    List<File>? files = await onGetMultiPhoto(
        context: context, funcPermission: () {}, picker: _picker);
    if (files != null && files.isNotEmpty) {
      if ((_listFile.length + files.length) <= 4) {
        _bloc.add(UploadImageEvent(files));
      } else {
        context.showSnackBar('Chỉ được chọn tối đa 4 ảnh!');
        return;
      }
    }
  }

  Future getImage(
    ImageSource img,
  ) async {
    if (await Permission.camera.request().isGranted) {
      if (_listFile.length >= 4) {
        context.showSnackBar('Chỉ được chọn tối đa 4 ảnh!');
        return;
      } else {
        final picker = ImagePicker();
        File? galleryFile;
        final pickedFile =
            await picker.pickImage(source: img, imageQuality: 30);
        List<File>? files = [];
        if (pickedFile != null) {
          galleryFile = File(pickedFile.path);
          files.add(galleryFile);
          _bloc.add(UploadImageEvent(files));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(// is this context <<<
              const SnackBar(content: Text('Nothing is selected')));
        }
      }
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
        content: 'Vui lòng cấp quyền truy cập camera.',
      );
    }
  }
}
