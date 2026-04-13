import 'package:bloc/bloc.dart';
import 'package:socbay/blocs/tab_bar/tab_bar_event.dart';
import 'package:socbay/blocs/tab_bar/tab_bar_state.dart';

class TabBarBloc extends Bloc<TabBarEvent, TabBarState> {

  TabBarBloc() : super(InitialTabbarState()) {
    on<TabBarPressed>((event, emit) async {
      emit(TabbarChanged(event.index));
    });
  }
}
