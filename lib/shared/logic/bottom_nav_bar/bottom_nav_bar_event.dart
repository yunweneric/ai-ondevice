part of 'bottom_nav_bar_bloc.dart';

@immutable
sealed class BottomNavBarEvent {}

class UpdateNavbarIndexEvent extends BottomNavBarEvent {
  final int newIndex;

  UpdateNavbarIndexEvent({required this.newIndex});
}
