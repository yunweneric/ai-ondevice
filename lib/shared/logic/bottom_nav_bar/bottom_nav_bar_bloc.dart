import 'package:bloc/bloc.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';

part 'bottom_nav_bar_event.dart';
part 'bottom_nav_bar_state.dart';

class BottomNavBarBloc extends Bloc<BottomNavBarEvent, BottomNavBarState> {
  BottomNavBarBloc() : super(const BottomNavBarInitial(activeIndex: 0)) {
    on<UpdateNavbarIndexEvent>((event, emit) {
      emit(UpdateNavbarIndex(activeIndex: event.newIndex));
    });
  }
}
