part of 'theme_bloc.dart';

sealed class ThemeEvent extends Equatable {}

class ChangeThemeEvent extends ThemeEvent {
  final ThemeMode themeMode;

  ChangeThemeEvent({required this.themeMode});

  @override
  List<Object?> get props => [themeMode];
}
