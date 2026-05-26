import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/evaluate/evaluate_bloc.dart';
import '../../blocs/evaluate/evaluate_event.dart';
import '../../blocs/evaluate/evaluate_state.dart';
import '../../data/model/user_profile.dart';
import '../../routes.dart';
import '../../utils/color_util.dart';
import '../../utils/image_util.dart';
import '../../utils/theme_util.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/my_app_bar.dart';

class FeedbackkScreen extends StatefulWidget {
  const FeedbackkScreen({super.key});

  @override
  State<FeedbackkScreen> createState() => _FeedbackkListState();
}

class _FeedbackkListState extends State<FeedbackkScreen> {
  late EvaluateScreenBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    _bloc.add(EvaluateScreenStartedEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EvaluateScreenBloc, EvaluateScreenState>(
      builder: _builder,
      listener: _listener,
    );
  }

  void _listener(BuildContext context, EvaluateScreenState state) {}

  Widget _builder(BuildContext context, EvaluateScreenState state) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Góp ý và khiêu nại kỹ thuật",
        isBackNavigation: true,
      ),
      body: LoadingIndicator(
        isLoading: _bloc.isLoading,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          itemBuilder: _itemBuilder,
          itemCount: _bloc.users.length,
        ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final UserProfile item = _bloc.users[index];
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.staffFeedbackListScreen,
          arguments: {"id": item.id, "name": item.username, "staffInfo": item},
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ColorUtil.bangladeshGreen),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: ImageUtil.loadNetWorkImage(
                url: item.avatar ?? '',
                height: 50,
                width: 50,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.username}',
                      style: const TextStyle(
                        fontWeight: MyFontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                    Text('${item.phone}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
