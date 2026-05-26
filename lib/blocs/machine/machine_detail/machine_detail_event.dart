abstract class MachineDetailScreenEvent {
  const MachineDetailScreenEvent();
}

class MachineDetailScreenStartedEvent extends MachineDetailScreenEvent {}

class MachineDetailScreenLikeProductEvent extends MachineDetailScreenEvent {
  final bool isLike;
  const MachineDetailScreenLikeProductEvent(this.isLike);
}
