abstract class CommentAndRatingEvent {
  const CommentAndRatingEvent();
}

class CommentAndRatingListEvent extends CommentAndRatingEvent {
  final bool isRefresh;

  const CommentAndRatingListEvent({this.isRefresh = false});
}