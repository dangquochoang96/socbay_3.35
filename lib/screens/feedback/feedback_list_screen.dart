import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';

import '../../blocs/home/feedbackid/feedbackid_screen_bloc.dart';
import '../../blocs/home/feedbackid/feedbackid_screen_event.dart';
import '../../blocs/home/feedbackid/feedbackid_screen_state.dart';

class StaffFeedbackListScreen extends StatefulWidget {
  const StaffFeedbackListScreen({super.key});

  @override
  State<StaffFeedbackListScreen> createState() => _FeedbackScreenListState();
}

class _FeedbackScreenListState extends State<StaffFeedbackListScreen>
    with TickerProviderStateMixin {
  late FeedbackScreenidBloc _bloc;
  late TextEditingController describeRequestTxtController;
  int page = 0;

  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    describeRequestTxtController = TextEditingController();
    _bloc.add(FeedbackScreenListOfStaffidEvent());
    super.initState();
  }

  @override
  void dispose(){
    _bloc.close();
    describeRequestTxtController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeedbackScreenidBloc, FeedbackScreenidState>(
        builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, FeedbackScreenidState state) {

  }

  Widget _builder(BuildContext context, FeedbackScreenidState state) {
    return Scaffold(
        appBar: MyAppBar(
          isBackNavigation: true,
          title: 'Góp ý và khiếu nại kỹ thuật',
          centerTitle: true,
        ),
        body: _buildListFeedback()
    );
  }
  Widget _buildListFeedback() {
    if (_bloc.feedBacksModel.isNotEmpty) {
      return RefreshIndicator(
          child: LoadingIndicator(
              isLoading: _bloc.isLoading,
              child: ListView.separated(
                  itemBuilder: _buildItemServiceHistory,
                  separatorBuilder: separatorBuilder,
                  itemCount: _bloc.feedBacksModel.length)),
          onRefresh: ()async{
            _bloc.add(FeedbackScreenListOfStaffidEvent());
          }
      );
    }
    return const Center(child: Text('Lịch sử máy'));
  }

  Widget _buildItemServiceHistory(BuildContext context, int index) {
    return Column(
        children: [
          ButtonWidget(
              onTap: () {
                Navigator.pushNamed(
                    context, Routes.staffDetailFeedBackScreen,
                    arguments: {
                      "fbId":_bloc.feedBacksModel[index].id.toString(),
                      "orderId":"0"
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
                              children:[
                                Container(
                                    padding: const EdgeInsets.only(
                                      bottom: 1, // space between underline and text
                                    ),
                                    decoration: const BoxDecoration(
                                        border: Border(bottom: BorderSide(
                                          color: ColorUtil.raisinBlack,  // Text colour here
                                          width: 1.0, // Underline width
                                        ))
                                    ),
                                    child: Text(
                                        'Mã đơn hàng: ĐH_${_bloc.feedBacksModel[index].orderId}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ColorUtil.raisinBlack,
                                            fontSize: 16
                                        )
                                    )
                                )
                              ],
                            ),

                          ],
                        ),
                        const SizedBox(height: 3)
                      ]
                  )
              )
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 0, bottom: 10, right: 8),
            child: Table(
              columnWidths: const { 1:FlexColumnWidth(2)},
              children: [
                TableRow(
                  children: [
                    const Text(
                      "Trạng thái dịch vụ: ",
                      style: TextStyle(fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(_bloc.feedBacksModel[index].getStatus())
                  ],
                ),
                TableRow(
                    children: [
                      const Text('Mô tả: ',
                          style: TextStyle(fontSize: 15,
                              fontWeight: FontWeight.w600)),
                      Text(_bloc.feedBacksModel[index].description ?? '',
                          style: const TextStyle(fontSize: 15)),
                    ]
                ),
              ],
            ),
          )
        ]
    );
  }

  Widget separatorBuilder(BuildContext context, int index) {
    return Container(
        decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 1.0, color: Colors.black26),
            )));
  }
}
