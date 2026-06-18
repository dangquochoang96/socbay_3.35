abstract class FeedbackScreenState {
  const FeedbackScreenState();
}

class FeedbackScreenInitialState extends FeedbackScreenState {}

class FeedbackScreenStaffInitialState extends FeedbackScreenState {}

class FeedbackScreenChangeTabState extends FeedbackScreenState {
  final int index;

  const FeedbackScreenChangeTabState(this.index);
}

class FeedbackCreateSuccessState extends FeedbackScreenState {
  final String msg;
  FeedbackCreateSuccessState(this.msg);
}

class FeedbackUpdateSuccessState extends FeedbackScreenState {
  final String msg;
  FeedbackUpdateSuccessState(this.msg);
}

class FeedbackCreateErrorState extends FeedbackScreenState {
  final String msg;
  FeedbackCreateErrorState(this.msg);
}

class FeedbackUpdateErrorState extends FeedbackScreenState {
  final String msg;
  FeedbackUpdateErrorState(this.msg);
}

class FeedbackUploadImagesSuccessState extends FeedbackScreenState {
  final List<String> paths;
  FeedbackUploadImagesSuccessState(this.paths);
}

class FeedbackUploadImagesErrorState extends FeedbackScreenState {
  final String msg;
  FeedbackUploadImagesErrorState(this.msg);
}
