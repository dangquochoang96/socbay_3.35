abstract class CommentTechniqueEvent {
  const CommentTechniqueEvent();
}

class CommentTechniqueListEvent extends CommentTechniqueEvent {
  final bool isRefresh;

  const CommentTechniqueListEvent({this.isRefresh = false});
}