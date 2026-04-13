import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:intl/intl.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/booking/detail_booking/detail_booking_bloc.dart';
import 'package:socbay/blocs/booking/detail_booking/detail_booking_event.dart';
import 'package:socbay/blocs/booking/detail_booking/detail_booking_state.dart';
import 'package:socbay/blocs/task/task_screen_event.dart';
import 'package:socbay/blocs/task/task_screen_sale_bloc.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/constants/maps.dart';
import 'package:socbay/data/model/order_detail_model.dart';
import 'package:socbay/data/model/task_model.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/utils/logger_util.dart';
import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';

class DetailBookingScreen extends StatefulWidget {
  const DetailBookingScreen({Key? key}) : super(key: key);

  @override
  State<DetailBookingScreen> createState() => _DetailBookingScreenState();
}

class _DetailBookingScreenState extends State<DetailBookingScreen> {
  late DetailBookingBloc _bloc;
  late TaskScreenSaleBloc _taskScreenSaleBloc;

  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    _taskScreenSaleBloc = BlocProvider.of<TaskScreenSaleBloc>(context);
    _bloc.add(DetailBookingStartedEvent());
    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DetailBookingBloc, DetailBookingState>(
        builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, DetailBookingState state) {}

  Widget _builder(BuildContext context, DetailBookingState state) {
    return Scaffold(
      appBar: MyAppBar(
        titleWidget: GestureDetector(
            //onTap: onTapTitleWidget,
            child: RichText(
          text: TextSpan(
            children: <TextSpan>[
              //  khách hàng
              if (App.instance.userApp?.isUserCustomer() == true)
                const TextSpan(
                  text: 'Chi tiết đặt lịch ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    fontSize: 18,
                    color: ColorUtil.white,
                  ),
                ),
              //  kỹ thuật
              if (App.instance.userApp?.isUserRole() == true)
                const TextSpan(
                  text: 'Chi tiết công việc ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    fontSize: 18,
                    color: ColorUtil.white,
                  ),
                ),
              if (App.instance.userApp?.isUserSale() == true)
                const TextSpan(
                  text: 'Chi tiết công việc ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    fontSize: 18,
                    color: ColorUtil.white,
                  ),
                ),
              TextSpan(
                text: '${_bloc.taskModel?.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  fontSize: 18,
                  color: ColorUtil.white,
                ),
              ),
            ],
          ),
        )),
        isBackNavigation: true,
        title: 'Chi tiết đơn hàng ${_bloc.taskModel?.id}',
        centerTitle: true,
        actionWidgets: [
          if ((_bloc.taskModel?.status == '1' ||
                  _bloc.taskModel?.status == '2' ||
                  _bloc.taskModel?.status == '5') &&
              _bloc.taskModel?.userCreate ==
                  App.instance.userApp?.id.toString()) ...[
            GestureDetector(
              onTap: () {
                _editBooking(_bloc.taskModel?.id ?? 0);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                  child: Text(
                    'Sửa',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          ]
        ],
      ),
      body: LoadingIndicator(
        isLoading: _bloc.isLoading,
        child: ListView(
          padding: const EdgeInsets.symmetric(
              horizontal: paddingHorizontal, vertical: paddingVertical),
          children: [
            _buildTable(_bloc.taskModel),
            const SizedBox(height: 5),
            const Text(
              'VIDEO - HÌNH ẢNH:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            _buildMediaRow(),
            if (App.instance.userApp?.isUserRole() == true) ...[
              if (_bloc.taskModel?.status == "3") _detailTask(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    if (_bloc.taskModel?.status != "3" &&
                        _bloc.taskModel?.status != "4" &&
                        !(App.instance.userApp?.isUserCustomer() == true))
                      _buildButton(
                          text: 'TẠO HÓA ĐƠN',
                          isPositive: true,
                          action: () {
                            _createOrder(_bloc.taskModel?.id ?? 0);
                          }),
                    const SizedBox(
                      width: 16,
                    )
                  ],
                ),
              )
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailTask() {
    if (_bloc.taskModel?.status == '3') {
      return Container(
        alignment: Alignment.center,
        child: _builderTaskProcessedDetail(_bloc.taskModel),
      );
    } else {
      return const SizedBox();
    }
  }

  void _editBooking(int id) {
    Navigator.pushNamed(context, Routes.editServiceScreen,
        arguments: {'id': id}).then((value) async {
      if (value == null) {
        return;
      } else {
        Map<String, dynamic>? result = value as Map<String, dynamic>?;
        if (result != null) {
          setState(() {
            _bloc.add(DetailBookingStartedEvent());
            _taskScreenSaleBloc
                .add(const StaffTaskScreenGetTaskAssigedEvent(isRefresh: true));
            _taskScreenSaleBloc
                .add(const StaffTaskScreenGetTaskByDayEvent(isRefresh: true));
          });
        }
      }
    });
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
                url: img, height: 100, fit: BoxFit.contain),
            //fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  TableRow buildTableRowDivider({
    required int cols,
    double height = 1,
    Color color = Colors.orange,
  }) =>
      TableRow(
        children: [
          for (var i = 0; i < cols; i++)
            Container(
              height: height,
              color: color,
            )
        ],
      );

  Widget _buildTable(TaskModel? taskModel) {
    final tableRowDivider = buildTableRowDivider(cols: 2, height: 1);
    return Table(
      // border: const TableBorder(
      //     bottom: BorderSide(), horizontalInside: BorderSide()),
      children: [
        TableRow(children: [
          Container(
            padding: const EdgeInsets.only(
              bottom: 20,
            ),
            child: const Text(
              'Thời gian:',
              style: TextStyle(
                color: ColorUtil.raisinBlack,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Text(
            _formatDatetime(taskModel?.timeStar),
            style: const TextStyle(
                color: ColorUtil.red,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          )
        ]),
        _buildTableRow(
          title: 'Công việc:',
          content: taskModel?.name,
          isHighlight: false,
        ),
        _buildTableRow(
            title: 'Tên sản phẩm:',
            content: taskModel?.productInfo?.machineModel?.name ?? "",
            isHighlight: false),
        _buildTableRow(
            title: 'Nội dung:', content: taskModel?.des, isHighlight: false),
        if (App.instance.userApp?.isUserCustomer() == false) ...[
          tableRowDivider,
        ],
        if (App.instance.userApp?.isUserCustomer() == true) ...[
          TableRow(children: [
            Container(
              padding: const EdgeInsets.only(bottom: 20),
              child: const Text(
                'Vị trí lắp đặt:',
                style: TextStyle(
                    color: ColorUtil.raisinBlack,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            Text(
              (taskModel?.productInfo?.address) ?? "",
              style: const TextStyle(
                  color: ColorUtil.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            )
          ]),
        ],
        if (App.instance.userApp?.isUserCustomer() == false) ...[
          TableRow(children: [
            Container(
              padding: const EdgeInsets.only(bottom: 20, top: 10),
              child: const Text(
                'Số điện thoại:',
                style: TextStyle(
                    color: ColorUtil.raisinBlack,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            ButtonWidget(
              padding: const EdgeInsets.only(bottom: 20, top: 10),
              onTap: () {
                if (taskModel?.customer?.phone != null &&
                    App.instance.userApp!.isUserCustomer() == false) {
                  var url = "tel:${taskModel!.customer!.phone!}";
                  launchUrl(Uri.parse(url));
                }
              },
              child: Text(
                taskModel?.customer?.phone ?? "",
                style: const TextStyle(
                    color: ColorUtil.bangladeshGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline),
              ),
            ),
          ]),
          _buildTableRow(
            title: 'Địa chỉ:',
            content: taskModel?.customer?.address ?? "",
            isHighlight: true,
            color: ColorUtil.brightYellow,
            decoration: TextDecoration.underline,
            onTap: () async {
              if (isAndroid) {
                final AndroidIntent intent = AndroidIntent(
                  action: 'action_view',
                  data:
                      'google.navigation:q=${taskModel?.customer?.address ?? ""}',
                  package: 'package:com.google.android.apps.maps',
                );
                await intent.launch();
              } else {
                commonLaunchUrl(
                    '$GOOGLE_MAP_PREFIX${Uri.encodeFull(taskModel?.customer?.address ?? "")}',
                    launchMode: LaunchMode.externalApplication);
              }
            },
          ),
          _buildTableRow(
            title: 'Vị trí lắp đặt:',
            content: taskModel?.productInfo?.address ?? "",
            isHighlight: true,
            color: ColorUtil.brightYellow,
            onTap: () async {
              if (isAndroid) {
                final AndroidIntent intent = AndroidIntent(
                  action: 'action_view',
                  data:
                      'google.navigation:q=${taskModel?.productInfo?.address ?? ""}',
                  package: 'package:com.google.android.apps.maps',
                );
                await intent.launch();
              } else {
                commonLaunchUrl(
                    '$GOOGLE_MAP_PREFIX${Uri.encodeFull(taskModel?.productInfo?.address ?? "")}',
                    launchMode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
        tableRowDivider,
        TableRow(children: [
          Container(
            padding: const EdgeInsets.only(
              bottom: 20,
            ),
            child: const Text(
              'Trạng thái:',
              style: TextStyle(
                  color: ColorUtil.raisinBlack,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
          Text(
            (taskModel?.getStatus()) ?? "",
            style: const TextStyle(
                color: ColorUtil.red,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          )
        ]),
        _buildTableRow(
          title: 'Kỹ thuật viên:',
          content: taskModel?.staff?.username ?? "",
          isHighlight: true,
          color: ColorUtil.brightYellow,
          decoration: TextDecoration.underline,
          onTap: () {
            Navigator.pushNamed(context, Routes.staffCommentTechniqueList,
                arguments: {
                  "id": taskModel?.staff?.id,
                  "name": taskModel?.staff?.username,
                  "staffInfo": taskModel?.staff
                });
          },
        ),
        TableRow(children: [
          Container(
            padding: const EdgeInsets.only(bottom: 20),
            child: const Text(
              'SĐT KTV:',
              style: TextStyle(
                  color: ColorUtil.raisinBlack,
                  fontWeight: FontWeight.w600,
                  fontSize: 20),
            ),
          ),
          ButtonWidget(
            onTap: () {
              if (taskModel?.staff?.phone != null) {
                var url = "tel:${taskModel!.staff!.phone!}";
                launchUrl(Uri.parse(url));
              }
            },
            child: Text(
              taskModel?.staff?.phone ?? "",
              style: const TextStyle(
                  color: ColorUtil.bangladeshGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  decoration: TextDecoration.underline),
            ),
          ),
        ]),
        _buildTableRow(
            title: 'Thông báo:', content: taskModel?.noti, isHighlight: false),
        tableRowDivider,
      ],
    );
  }

  TableRow _buildTableRow(
      {title, onTap, content, isHighlight, color, fontWeight, decoration}) {
    return TableRow(children: [
      Container(
        padding: const EdgeInsets.only(bottom: 20),
        child: Text(
          title,
          style: const TextStyle(
              color: ColorUtil.raisinBlack,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
      ),
      ButtonWidget(
          onTap: onTap,
          child: Text(
            content ?? "",
            style: TextStyle(
                color: isHighlight ? color : null,
                fontWeight: fontWeight ?? FontWeight.normal,
                // decoration: TextDecoration.underline,
                decoration: decoration,
                fontSize: 18),
          )),
    ]);
  }

  Widget _buildMediaRow() {
    return _bloc.taskModel != null &&
            _bloc.taskModel!.images != null &&
            _bloc.taskModel!.images!.isNotEmpty
        ? SizedBox(
            height: 200,
            width: double.maxFinite,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ListView.builder(
                itemCount: _bloc.taskModel!.images?.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return _buildItemMedia(_bloc.taskModel!.images![index].isEmpty
                      ? ""
                      : "$protocol${AppConfig.instance.values.apiUrl}" +
                          _bloc.taskModel!.images![index]);
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

  Widget _builderTaskProcessedDetail(TaskModel? taskModel) {
    return taskModel?.id != null
        ? ButtonWidget(
            color: ColorUtil.bangladeshGreen,
            borderRadius: BorderRadius.circular(30),
            padding: const EdgeInsets.all(10),
            onTap: () => {
                  // Navigator.pushNamed(context, Routes.detailTaskProcessedScreen,
                  //     arguments: {"id": taskModel?.id})
                  Navigator.pushNamed(
                      context, Routes.coreReplacementServiceScreen,
                      arguments: {
                        "orderDetail": OrderDetailModel(
                            id: int.tryParse(_bloc.taskModel?.orderId ?? "") ??
                                0)
                      })
                },
            child: const Text(
              "Xem chi tiết Xử lý",
              style: TextStyle(color: ColorUtil.white),
            ))
        : const SizedBox();
  }

  String _formatDatetime(String? dateTimeString) {
    try {
      var dateTime = dateTimeString ?? DateTime.now().toString();
      DateTime getDateTime = DateTime.parse(dateTime);
      var output = DateFormat('dd/MM/yyyy HH:mm:ss').format(getDateTime);
      return output.toString();
    } on Exception catch (ex) {
      LoggerUtil.error("format datetime error: " + ex.toString());
      rethrow;
    }
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
        borderRadius: BorderRadius.circular(30),
        padding: const EdgeInsets.symmetric(vertical: 10),
        margin:
            const EdgeInsets.only(left: 60.0, right: 60, bottom: 30, top: 10),
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
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ));
  }

  void _createOrder(int id) {
    Navigator.pushNamed(context, Routes.createOrderScreen,
        arguments: {'id': id});
  }
}
