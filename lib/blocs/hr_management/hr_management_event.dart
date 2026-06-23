import 'package:equatable/equatable.dart';

abstract class HRManagementEvent extends Equatable {
  const HRManagementEvent();

  @override
  List<Object?> get props => [];
}

class FetchHRManagementData extends HRManagementEvent {
  final String userId;

  const FetchHRManagementData({required this.userId});

  @override
  List<Object?> get props => [userId];
}
