abstract class DetailTaskProcessedEvent {}
class DetailTaskProcessedStartEvent extends DetailTaskProcessedEvent{
}
class FeedbackTaskProcessedEvent extends DetailTaskProcessedEvent{
  final int taskId;
  final String des;
  final double rating;
  FeedbackTaskProcessedEvent(this.taskId, this.des, this.rating);
}

