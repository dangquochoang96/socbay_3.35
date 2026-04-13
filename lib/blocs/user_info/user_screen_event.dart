import 'dart:io';

abstract class UserScreenEvent {
  const UserScreenEvent();
}

class UserScreenStartedEvent extends UserScreenEvent {}

class UserScreenLogoutEvent extends UserScreenEvent {}

class UserScreenChangeAvatarEvent extends UserScreenEvent {
  final File file;

  const UserScreenChangeAvatarEvent({required this.file});
}
