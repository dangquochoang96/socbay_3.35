import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:socbay/blocs/home/news/news_screen_bloc.dart';
import 'package:socbay/blocs/home/news/news_screen_event.dart';
import 'package:socbay/blocs/home/news/news_screen_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/widgets/my_app_bar.dart';

import '../../utils/color_util.dart';
import '../../utils/image_util.dart';
import '../../utils/scroll_util.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/indicator_loadmore.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late NewsScreenBloc _bloc;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    _bloc.add(const NewsScreenGetNewsEvent());

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      scrollPaginationListener(
        scrollController: _scrollController,
        condition: _bloc.isHasMore() && !_bloc.isLoading,
        paginationFunction: () {
          _bloc.add(const NewsScreenGetNewsEvent());
        },
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NewsScreenBloc, NewsScreenState>(
      builder: _builder,
      listener: _listener,
    );
  }

  void _listener(BuildContext context, NewsScreenState state) {}

  Widget _builder(BuildContext context, NewsScreenState state) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Tin tức",
        isBackNavigation: true,
      ),
      body: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(
            horizontal: paddingHorizontal, vertical: paddingVertical),
        shrinkWrap: true,
        itemCount: _bloc.blogs.length + (_bloc.isHasMore() ? 1 : 0),
        itemBuilder: _buildItemBlog,
        separatorBuilder: _separateView,
      ),
    );
  }

  Widget _buildItemBlog(BuildContext context, int index) {
    if (index >= _bloc.blogs.length) {
      return const IndicatorLoadMore();
    }
    final itemBlog = _bloc.blogs[index];
    return ButtonWidget(
      onTap: () {
        Navigator.pushNamed(context, Routes.newDetail,arguments: itemBlog);
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: ImageUtil.loadNetWorkImage(
                url: itemBlog.image == null
                    ? ""
                    : "$protocol${AppConfig.instance.values.apiUrl}${itemBlog.image!}",
                fit: BoxFit.cover,
                height: 100,
                width: 100),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${itemBlog.name}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorUtil.bangladeshGreen),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Html(
                    data: itemBlog.shortdes??""
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _separateView(BuildContext context, int index) {
    return const SizedBox(height: 8);
  }
}
