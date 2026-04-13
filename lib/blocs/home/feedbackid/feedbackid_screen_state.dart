abstract class FeedbackScreenidState {
  const FeedbackScreenidState();
}

class FeedbackScreenInitialidState extends FeedbackScreenidState {}
class FeedbackScreenStaffInitialidState extends FeedbackScreenidState {}
class FeedbackScreenChangeTabidState extends FeedbackScreenidState {
  final int index;

  const FeedbackScreenChangeTabidState(this.index);

}
class FeedbackCreateSuccessidState extends FeedbackScreenidState {
  final String msg;
  FeedbackCreateSuccessidState(this.msg);
}
class FeedbackUpdateSuccessidState extends FeedbackScreenidState {
  final String msg;
  FeedbackUpdateSuccessidState(this.msg);
}
class FeedbackCreateErroridState extends FeedbackScreenidState {
  final String msg;
  FeedbackCreateErroridState(this.msg);
}
class FeedbackUpdateErroridState extends FeedbackScreenidState {
  final String msg;
  FeedbackUpdateErroridState(this.msg);
}
class FeedbackUploadImagesSuccessidState extends FeedbackScreenidState {
  final List<String> paths;
  FeedbackUploadImagesSuccessidState(this.paths);
}
class FeedbackUploadImagesErroridState extends FeedbackScreenidState {
  final String msg;
  FeedbackUploadImagesErroridState(this.msg);
}