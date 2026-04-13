import 'package:equatable/equatable.dart';

abstract class TabBarState extends Equatable {
  const TabBarState();

  @override
  List<Object> get props => [];
}

class InitialTabbarState extends TabBarState {}

class TabbarChanged extends TabBarState {
  final int index;

  const TabbarChanged(this.index);

  @override
  List<Object> get props => [index];
}
