part of 'bottom_nav_bar_bloc.dart';

@immutable
class BottomNavBarState {
  final int activeIndex;

  const BottomNavBarState({required this.activeIndex});
}

final class BottomNavBarInitial extends BottomNavBarState {
  const BottomNavBarInitial({required super.activeIndex});
}

final class UpdateNavbarIndex extends BottomNavBarState {
  const UpdateNavbarIndex({required super.activeIndex});
}
