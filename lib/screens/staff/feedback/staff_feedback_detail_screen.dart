import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socbay/blocs/home/feedback/feedback_screen_bloc.dart';
import 'package:socbay/blocs/home/feedback/feedback_screen_event.dart';
import 'package:socbay/blocs/home/feedback/feedback_screen_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/model/feed_back_model.dart';
import 'package:socbay/data/model/order_detail_model.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/dialog/custom_alert_dialog.dart';
import 'package:socbay/widgets/my_app_bar.dart';

class StaffDetailFeedbackScreen extends StatefulWidget {
  const StaffDetailFeedbackScreen({Key? key}) : super(key: key);

  @override
  State<StaffDetailFeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<StaffDetailFeedbackScreen>
    with TickerProviderStateMixin {
  late FeedbackScreenBloc _bloc;
  int page = 0;

  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    _bloc.add(FeedbackDetailEvent());
    super.initState();
  }

  @override
  void dispose(){
    _bloc.close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeedbackScreenBloc, FeedbackScreenState>(
        builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, FeedbackScreenState state) {
    if(state is FeedbackUpdateSuccessState){
      context.showSnackBar("Cập nhật thành công!");
      Navigator.pushNamed(
          context, Routes.staffFeedbackScreen,arguments: {"fbId": "0", "orderId": "0"});
    }
    if(state is FeedbackUpdateErrorState){
      context.showSnackBar("Có lỗi hệ thống xảy ra!");
    }
  }

  Widget _builder(BuildContext context, FeedbackScreenState state) {
    return Scaffold(
        appBar: MyAppBar(
          isBackNavigation: true,
          title: 'Góp ý và khiếu nại',
          centerTitle: true,
          // actionWidgets: [
          //   if (_bloc.feedbackDetail.status == '1')
          //     ...[
          //       GestureDetector(
          //         onTap: () {
          //
          //         },
          //         child: const Padding(
          //           padding: EdgeInsets.symmetric(horizontal: 8.0),
          //           child: Center(
          //             child: Text(
          //               'Sửa',
          //               style: TextStyle(fontWeight: FontWeight.bold),
          //             ),
          //           ),
          //         ),
          //       )
          //     ]
          // ],
        ),
        body: Padding(
          padding:const EdgeInsets.symmetric(vertical: 16,horizontal: 16),
          child: Column(
            children: [
              _buildTable(_bloc.feedbackDetail),
              const SizedBox(height: 5),
              const Text(
                'Video - Hình ảnh:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _buildMediaRow(),
              Row(
                children: [
                  _buildButton(
                      text: "Xem chi tiết đơn hàng",
                      isPositive: true,
                      action: () {
                        Navigator.pushNamed(
                            context, Routes.coreReplacementServiceScreen,
                            arguments: {"orderDetail": OrderDetailModel(id: int.parse(_bloc.feedbackDetail.orderId.toString()))});
                      }),
                  if(_bloc.feedbackDetail.status == "1")...[
                    _buildButton(
                        text: "Đã xử lý",
                        isPositive: true,
                        action: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text(
                                    'Chắc chắn đã xử lý khiếu nại?',
                                    textAlign: TextAlign.center,
                                  ),
                                  actions: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildButtonDialog(
                                            isPositive: true,
                                            text: 'Xác nhận',
                                            action: () {
                                              _bloc.add(FeedbackProcessedEvent(id: _bloc.feedbackDetailId.toString()));
                                            }),
                                        _buildButtonDialog(
                                            isPositive: false,
                                            text: 'Hủy',
                                            action: () {
                                              Navigator.pop(context);
                                            }),

                                      ],
                                    )
                                  ],
                                );
                              });

                        })
                  ]
                ],
              )
            ],
          ),
        )
    );
  }

  Widget _buildButton({text, isPositive, action}) {
    return Expanded(
        child: isPositive
            ? _button(isPositive, action, text)
            : ElevatedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(vertical: 10)),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(ColorUtil.white),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(
                        color: ColorUtil.bangladeshGreen,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                child: Text(
                  text,
                  style: const TextStyle(color: ColorUtil.bangladeshGreen),
                ),
                onPressed: () {
                  if (action == null) {
                    Navigator.pop(context);
                  } else {
                    action();
                  }
                },
              ));
  }

  StatelessWidget _button(isPositive, action, text) {
    return ButtonWidget(
        color: isPositive ? ColorUtil.bangladeshGreen : Colors.grey,
        borderRadius: BorderRadius.circular(10),
        padding: const EdgeInsets.symmetric(vertical: 10),
        margin:
            const EdgeInsets.only(left: 10.0),
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

  Widget _buildTable(FeedBackModel? feedBackModel) {
    return Table(
      children: [
        _buildTableRow(
            title: 'Mã đơn hàng',
            content: feedBackModel?.orderId,
            isHighlight: false),
        _buildTableRow(
            title: 'Trạng thái:',
            content: feedBackModel?.getStatus(),
            isHighlight: false),
        _buildTableRow(
            title: 'Mô tả:',
            content: feedBackModel?.description??"",
            isHighlight: false),
        _buildTableRow(
            title: 'Khách hàng:',
            content: feedBackModel?.customer?.username,
            isHighlight: false),
        // TableRow(children: [
        //   Container(
        //     padding: const EdgeInsets.only(bottom: 5.0),
        //     child: const Text(
        //       'Số điện thoại:',
        //       style: TextStyle(
        //           color: ColorUtil.raisinBlack, fontWeight: FontWeight.bold),
        //     ),
        //   ),
        //   ButtonWidget(
        //     onTap: () {
        //       if(feedBackModel?.customer?.phone != null && App.instance.userApp!.isUserCustomer()==false){
        //         var url = "tel:${feedBackModel!.customer!.phone!}";
        //         launch(url);
        //       }
        //     },
        //     child: Text(
        //       feedBackModel?.customer?.phone ?? "",
        //       style: const TextStyle(color: ColorUtil.bangladeshGreen),
        //     ),
        //   ),
        // ]),
        // _buildTableRow(
        //     title: 'Địa chỉ:',
        //     content: feedBackModel?.customer?.address,
        //     isHighlight: false),
      ],
    );
  }

  TableRow _buildTableRow({title, content, isHighlight}) {
    return TableRow(children: [
      Container(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Text(
          title,
          style: const TextStyle(
              color: ColorUtil.raisinBlack, fontWeight: FontWeight.bold),
        ),
      ),
      Text(
        content ?? "",
        style: TextStyle(color: isHighlight ? ColorUtil.bangladeshGreen : null),
      )
    ]);
  }

  Widget _buildMediaRow() {
    return _bloc.feedbackDetail.images != null &&
            _bloc.feedbackDetail.images!.isNotEmpty
        ? SizedBox(
            height: 200,
            width: double.maxFinite,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ListView.builder(
                itemCount: _bloc.feedbackDetail.images?.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return _buildItemMedia(_bloc.feedbackDetail.images![index]);
                },
              ),
            ),
          )
        : Container();
  }

  Widget _buildItemMedia(String url) {
    return Row(
      children: [
        Stack(
          children: [_fullScreenHeroWidget(url)],
        ),
        const SizedBox(width: 5),
      ],
    );
  }

  Widget _fullScreenHeroWidget(String img) {
    return SizedBox(
      width: 100,
      height: 100,
      child: FullScreenWidget(
        child: Hero(
          tag: img,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ImageUtil.loadNetWorkImage(
                url: "$protocol${AppConfig.instance.values.apiUrl}$img", height: 100, fit: BoxFit.contain),
            //fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Future getImage(
    ImageSource img,
  ) async {
    if (await Permission.camera.request().isGranted) {
      // if(_listPath.length  >= 4){
      //   context.showSnackBar('Chỉ được chọn tối đa 4 ảnh!');
      //   return;
      // }else{
      //   final picker = ImagePicker();
      //   File? galleryFile;
      //   final pickedFile = await picker.pickImage(source: img,imageQuality: 30);
      //   List<File>? files= [];
      //   if (pickedFile != null) {
      //     galleryFile = File(pickedFile.path);
      //     files.add(galleryFile!);
      //     _bloc.add(ServiceScreenUploadImageEvent(files));
      //   } else {
      //     ScaffoldMessenger.of(context).showSnackBar(// is this context <<<
      //         const SnackBar(content: Text('Nothing is selected')));
      //   }
      // }
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
  Widget _buildButtonDialog({isPositive, action, text}) {
    return Expanded(child: _button(isPositive, action, text));
  }
}
