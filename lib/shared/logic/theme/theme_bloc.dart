import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends HydratedBloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeInitial(themeMode: ThemeMode.system)) {
    on<ChangeThemeEvent>((event, emit) {
      emit(UpdateTheme(themeMode: event.themeMode));
    });
  }

  @override
  ThemeState? fromJson(Map<String, dynamic> json) {
    if (json['mode'] == null)
      return const ThemeState(themeMode: ThemeMode.system);
    final themeName = json['mode'];
    if (themeName == ThemeMode.dark.name) {
      return const ThemeState(themeMode: ThemeMode.dark);
    }
    if (themeName == ThemeMode.light.name) {
      return const ThemeState(themeMode: ThemeMode.light);
    }
    return const ThemeState(themeMode: ThemeMode.system);
  }

  @override
  Map<String, dynamic>? toJson(ThemeState state) {
    return {
      "mode": state.themeMode.name,
    };
  }
}
