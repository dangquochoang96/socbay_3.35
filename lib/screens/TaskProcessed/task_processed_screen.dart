import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:socbay/blocs/booking/task_processed/task_processed_bloc.dart';
import 'package:socbay/blocs/booking/task_processed/task_processed_event.dart';
import 'package:socbay/blocs/booking/task_processed/task_processed_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/utils/logger_util.dart';
import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:socbay/widgets/text_field_default.dart';

// import '../../blocs/booking/task_processed/task_processed_state.dart';
// import '../../utils/image_util.dart';
// import '../../widgets/button_widget.dart';
// import '../../widgets/text_field_default.dart';

class TaskProcessedScreen extends StatefulWidget {
  const TaskProcessedScreen({Key? key}) : super(key: key);
  @override
  State<TaskProcessedScreen> createState() => _TaskProcessedScreenState();
}

class _TaskProcessedScreenState extends State<TaskProcessedScreen> {
  late DetailTaskProcessedBloc _bloc;
  //final _initialRating = 2.0;

  final _isVertical = false;
  IconData? _selectedIcon;
  late double _rating;
  late TextEditingController _feedbackController;
  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    _bloc.add(DetailTaskProcessedStartEvent());
    _rating = _bloc.rating;
    _feedbackController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DetailTaskProcessedBloc, DetailTaskProcessedState>(
        builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, DetailTaskProcessedState state) {}
  Widget _builder(BuildContext context, DetailTaskProcessedState state) {
    var staffName = _bloc.taskProcessedModel?.staff?.username;
    return Scaffold(
      appBar: MyAppBar(
          title: "Chi tiết dịch vụ", isBackNavigation: true, centerTitle: true),
      body: Center(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.shade400),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Expanded(child: _tableAction())],
              ),
            ),
            Container(
                margin: const EdgeInsets.only(left: 15, right: 15),
                decoration: const BoxDecoration(
                    border: Border(
                  bottom: BorderSide(width: 1.0, color: Colors.black26),
                )),
                child: _tablePrice()),
            Container(
              margin: const EdgeInsets.only(left: 15, top: 5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(children: [
                    const TextSpan(text: "Thông tin kỹ thuật viên: "),
                    TextSpan(
                      text: staffName ?? 'NoStaff',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: ColorUtil.bangladeshGreen,
                          decorationThickness: 1,
                          decoration: TextDecoration.underline,
                          fontSize: 13),
                    )
                  ]),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 15, top: 5),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text("Hình ảnh đơn hàng: "),
              ),
            ),
            Container(
                margin: const EdgeInsets.only(left: 15, top: 5),
                child: _buildMediaRow()),
            const SizedBox(height: 10.0),
            Align(
              alignment: Alignment.bottomCenter,
              child: _heading('Đánh giá và nhận xét dịch vụ'),
            ),
            _ratingBarDisplay(),
            Container(
              margin: const EdgeInsets.only(left: 15, right: 15),
              decoration: const BoxDecoration(
                  border: Border(
                bottom: BorderSide(width: 1.0, color: Colors.black26),
              )),
              child: Text(_bloc.des),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.shade400),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Expanded(child: _tableUpdate())],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableAction() {
    return Table(
      border: TableBorder.symmetric(
        inside: const BorderSide(width: 1, color: Colors.blue),
        //outside: const BorderSide(width: 1),
      ),
      children: [
        TableRow(
            decoration: BoxDecoration(
                border: Border.all(color: ColorUtil.bangladeshGreen),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                color: ColorUtil.bangladeshGreen),
            children: const [
              TableCell(
                  child: Align(
                child: Text("Ngày",
                    style: TextStyle(
                      color: ColorUtil.white,
                    )),
                alignment: Alignment.center,
              )),
              TableCell(
                  child: Align(
                child:
                    Text("Tên lõi", style: TextStyle(color: ColorUtil.white)),
                alignment: Alignment.center,
              )),
              TableCell(
                  child: Align(
                child: Text("Thành tiền",
                    style: TextStyle(color: ColorUtil.white)),
                alignment: Alignment.center,
              ))
            ]),
        if (_bloc.taskProcessedModel != null &&
            _bloc.taskProcessedModel!.progress != null &&
            _bloc.taskProcessedModel!.progress!.isNotEmpty)
          for (var item in _bloc.taskProcessedModel!.progress!)
            TableRow(children: [
              TableCell(
                child: Align(
                  child: Text(_formatDatetime(item.createAt.toString())),
                  alignment: Alignment.center,
                ),
              ),
              TableCell(
                child: Align(
                  child: Text(item.name!),
                  alignment: Alignment.centerLeft,
                ),
              ),
              TableCell(
                child: Align(
                  child: Text(item.price.toString()),
                  alignment: Alignment.center,
                ),
              )
            ])
      ],
    );
  }

  Widget _tablePrice() {
    var totalPrice = _bloc.taskProcessedModel?.totalPrice;
    var discount = _bloc.taskProcessedModel?.discount;
    var subPoint = _bloc.taskProcessedModel?.subPoint;
    var totalPriced = _bloc.taskProcessedModel?.totalPriced;
    return Table(
      children: [
        TableRow(children: [
          const TableCell(child: Text("Tổng tiền:")),
          TableCell(child: Text("${totalPrice ?? '0'}"))
        ]),
        TableRow(children: [
          const TableCell(child: Text("Chiết khấu:")),
          TableCell(child: Text("${discount ?? '0'}"))
        ]),
        TableRow(children: [
          const TableCell(child: Text("Trừ tích điểm:")),
          TableCell(child: Text("${subPoint ?? '0'}"))
        ]),
        TableRow(children: [
          const TableCell(child: Text("Tổng tiền thanh toán:")),
          TableCell(child: Text("${totalPriced ?? '0'}"))
        ])
      ],
    );
  }

  Widget _tableUpdate() {
    return Table(
      border: TableBorder.symmetric(
        inside: const BorderSide(width: 1, color: Colors.blue),
        //outside: const BorderSide(width: 1),
      ),
      children: [
        TableRow(
            decoration: BoxDecoration(
                border: Border.all(color: ColorUtil.bangladeshGreen),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                color: ColorUtil.bangladeshGreen),
            children: const [
              TableCell(
                  child: Align(
                child: Text("Dịch vụ",
                    style: TextStyle(
                      color: ColorUtil.white,
                    )),
                alignment: Alignment.center,
              )),
              TableCell(
                  child: Align(
                child: Text("Lịch kiểm tra bảo dưỡng tiếp theo",
                    style: TextStyle(color: ColorUtil.white)),
                alignment: Alignment.center,
              )),
            ]),
        if (_bloc.taskProcessedModel != null &&
            _bloc.taskProcessedModel!.progress != null &&
            _bloc.taskProcessedModel!.progress!.isNotEmpty)
          for (var item in _bloc.taskProcessedModel!.progress!)
            TableRow(children: [
              TableCell(
                child: Align(
                  child: Text(item.name!),
                  alignment: Alignment.centerLeft,
                ),
              ),
              TableCell(
                child: Align(
                  child: Text(_formatDatetime(item.updateAt.toString())
                      .substring(0, 10)),
                  alignment: Alignment.center,
                ),
              )
            ])
      ],
    );
  }

  Widget _buildMediaRow() {
    return _bloc.taskProcessedModel != null &&
            _bloc.taskProcessedModel!.images != null &&
            _bloc.taskProcessedModel!.images!.isNotEmpty
        ? SizedBox(
            height: 200,
            width: double.infinity,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ListView.builder(
                itemCount: _bloc.taskProcessedModel!.images?.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return _buildItemMedia(
                      _bloc.taskProcessedModel!.images![index].replaceAll(
                          "/$protocol${AppConfig.instance.values.apiUrl}/",
                          "/"));
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
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child:
                  ImageUtil.loadNetWorkImage(url: url, width: 120, height: 200),
            ),
          ],
        ),
        const SizedBox(width: 5),
      ],
    );
  }

  Widget _heading(String text) => Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 13.0,
              color: ColorUtil.bangladeshGreen,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            color: ColorUtil.graniteGray,
            onPressed: () {
              /* Your code */
              _ratingAndNote();
            },
          ),
        ],
      ));
  Widget _ratingBar() {
    return RatingBar.builder(
      initialRating: _bloc.rating,
      minRating: 1,
      direction: _isVertical ? Axis.vertical : Axis.horizontal,
      allowHalfRating: true,
      unratedColor: Colors.amber.withAlpha(50),
      itemCount: 5,
      itemSize: 30.0,
      itemPadding: const EdgeInsets.symmetric(horizontal: 0.0),
      itemBuilder: (context, _) => Icon(
        _selectedIcon ?? Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        setState(() {
          _rating = rating;
        });
      },
      updateOnDrag: true,
      tapOnlyMode: true,
    );
  }

  Widget _ratingBarDisplay() {
    return RatingBarIndicator(
      rating: _bloc.rating,
      direction: _isVertical ? Axis.vertical : Axis.horizontal,
      unratedColor: Colors.amber.withAlpha(50),
      itemCount: 5,
      itemSize: 30.0,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(
        _selectedIcon ?? Icons.star,
        color: Colors.amber,
      ),
    );
  }

  Future<void> _ratingAndNote() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            scrollable: true,
            title: const Text(
              'Đánh giá và nhận xét',
              textAlign: TextAlign.center,
            ),
            content: Column(
              children: [
                _ratingBar(),
                TextFieldDefault(
                  controller: _feedbackController,
                  maxLines: 3,
                )
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildButtonDialog(
                      isPositive: false,
                      text: 'Hủy',
                      action: () {
                        Navigator.pop(context);
                        _feedbackController.clear();
                      }),
                  const SizedBox(width: 16),
                  _buildButtonDialog(
                      isPositive: true,
                      text: 'Gửi',
                      action: () {
                        _bloc.add(FeedbackTaskProcessedEvent(
                            _bloc.taskProcessedModel!.id!,
                            _feedbackController.text,
                            _rating));
                        Navigator.pop(context);
                        _feedbackController.clear();
                      }),
                ],
              )
            ],
          );
        });
  }

  Widget _buildButtonDialog({isPositive, action, text}) {
    return Expanded(child: _button(isPositive, action, text));
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

  String _formatDatetime(String? dateTimeString) {
    try {
      var dateTime = dateTimeString ?? DateTime.now().toString();
      DateTime getDateTime = DateTime.parse(dateTime);
      var output = DateFormat('dd/MM/yyyy HH:mm:ss').format(getDateTime);
      return output.toString();
    } on Exception catch (ex) {
      LoggerUtil.error(ex.toString());
      rethrow;
    }
  }
}
