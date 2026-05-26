import 'dart:io';

abstract class FeedbackScreenidEvent {}

class FeedbackScreenTabPressidEvent extends FeedbackScreenidEvent {
  final int index;

  FeedbackScreenTabPressidEvent(this.index);
}

class FeedbackScreenListOfStaffidEvent extends FeedbackScreenidEvent {}

class FeedbackCreateidEvent extends FeedbackScreenidEvent {
  final String orderId;
  final String description;
  final List<String> images;

  FeedbackCreateidEvent({
    required this.orderId,
    required this.description,
    required this.images,
  });
}

class UploadImageidEvent extends FeedbackScreenidEvent {
  final List<File> files;
  UploadImageidEvent(this.files);
}

class FeedbackDetailidEvent extends FeedbackScreenidEvent {}

class FeedbackUpdateidEvent extends FeedbackScreenidEvent {
  final int? id;
  final String? status;
  final String? description;
  FeedbackUpdateidEvent({this.id, this.status, this.description});
}

class FeedbackProcessedidEvent extends FeedbackScreenidEvent {
  final String id;
  FeedbackProcessedidEvent({required this.id});
}
