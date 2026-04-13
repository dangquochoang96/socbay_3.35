import 'package:equatable/equatable.dart';

abstract class TabBarEvent extends Equatable {
  const TabBarEvent();

  @override
  List<Object> get props => [];
}

class TabBarPressed extends TabBarEvent {
  final int index;

  const TabBarPressed({required this.index});

  @override
  List<Object> get props => [index];

  @override
  String toString() {
    return 'index: $index';
  }
}
