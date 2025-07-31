part of 'theme_bloc.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;

  const ThemeState({required this.themeMode});

  @override
  List<Object?> get props => [themeMode];
}

class ThemeInitial extends ThemeState {
  const ThemeInitial({required super.themeMode});
}

class UpdateTheme extends ThemeState {
  const UpdateTheme({required super.themeMode});
}
