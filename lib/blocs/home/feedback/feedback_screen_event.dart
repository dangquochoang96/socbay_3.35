import 'dart:io';

abstract class FeedbackScreenEvent {}

class FeedbackScreenTabPressEvent extends FeedbackScreenEvent {
  final int index;

  FeedbackScreenTabPressEvent(this.index);
}

class FeedbackScreenListOfStaffEvent extends FeedbackScreenEvent {}

class FeedbackCreateEvent extends FeedbackScreenEvent {
  final String orderId;
  final String description;
  final List<String> images;
  final String? historyId;

  FeedbackCreateEvent({
    required this.orderId,
    required this.description,
    required this.images,
    this.historyId,
  });
}

class UploadImageEvent extends FeedbackScreenEvent {
  final List<File> files;
  UploadImageEvent(this.files);
}

class FeedbackDetailEvent extends FeedbackScreenEvent {}

class FeedbackUpdateEvent extends FeedbackScreenEvent {
  final int? id;
  final String? status;
  final String? description;
  FeedbackUpdateEvent({this.id, this.status, this.description});
}

class FeedbackProcessedEvent extends FeedbackScreenEvent {
  final String id;
  FeedbackProcessedEvent({required this.id});
}
