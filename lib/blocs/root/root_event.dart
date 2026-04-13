import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class RootEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AppStarted extends RootEvent {}

class LoggedIn extends RootEvent {}

class LoggedOut extends RootEvent {}

class NoInternet extends RootEvent {}

class ReplaceOnBoardToProjectScreen extends RootEvent {}

class UpdateButtonPressed extends RootEvent {}

class AccessTokenExpired extends RootEvent {}

class DismissAccessTokenExpiredAlert extends RootEvent {}