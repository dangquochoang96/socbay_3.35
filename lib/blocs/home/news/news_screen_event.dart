abstract class NewsScreenEvent {
  const NewsScreenEvent();
}

class NewsScreenGetNewsEvent extends NewsScreenEvent {
  final bool isRefresh;

  const NewsScreenGetNewsEvent({this.isRefresh = false});
}
