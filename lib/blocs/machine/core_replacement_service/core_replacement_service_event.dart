abstract class CoreReplatementServiceEvent {
  const CoreReplatementServiceEvent();
}
class CoreReplatementServiceStartEvent extends CoreReplatementServiceEvent{}
class OrderFeedbackTaskProcessedEvent extends CoreReplatementServiceEvent{
  final int taskId;
  final String des;
  final double rating;
  OrderFeedbackTaskProcessedEvent(this.taskId, this.des, this.rating);
}

class OrderPaymentStatusUpdatedEvent extends CoreReplatementServiceEvent {
  final int taskId;
  OrderPaymentStatusUpdatedEvent(this.taskId);
}