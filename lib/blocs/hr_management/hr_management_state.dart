import 'package:equatable/equatable.dart';
import 'package:socbay/data/model/user_profile.dart';

abstract class HRManagementState extends Equatable {
  const HRManagementState();

  @override
  List<Object?> get props => [];
}

class HRManagementInitial extends HRManagementState {}

class HRManagementLoading extends HRManagementState {}

class HRManagementLoaded extends HRManagementState {
  final UserProfile userProfile;
  final UserProfile? userInfoProfile;

  const HRManagementLoaded({required this.userProfile, this.userInfoProfile});

  @override
  List<Object?> get props => [userProfile, userInfoProfile];
}

class HRManagementError extends HRManagementState {
  final String message;

  const HRManagementError({required this.message});

  @override
  List<Object?> get props => [message];
}
