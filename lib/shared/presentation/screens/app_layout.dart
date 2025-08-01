import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_ai/feat/chat/chat.dart';
import 'package:offline_ai/feat/history/history.dart';
import 'package:offline_ai/feat/model_mangement/model_management.dart';
import 'package:offline_ai/shared/shared.dart';

class NavItem {
  final String title;
  final String icon;
  final String iconFilled;
  final int index;

  NavItem({required this.title, required this.icon, required this.index, required this.iconFilled});
}

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  bool _isKeyboardVisible = false;
  final screens = [
    const ChatScreen(),
    const HistoryScreen(),
    const ListModelsScreen(),
    const SettingsScreen(),
  ];
  static List<NavItem> navBar() => [
        NavItem(
            title: LangUtil.trans("navigation.chat"), iconFilled: AppIcons.chatFilled, icon: AppIcons.chat, index: 0),
        NavItem(
            title: LangUtil.trans("navigation.history"),
            iconFilled: AppIcons.historyFilled,
            icon: AppIcons.history,
            index: 1),
        NavItem(
            title: LangUtil.trans("navigation.explore"),
            iconFilled: AppIcons.exploreFilled,
            icon: AppIcons.explore,
            index: 2),
        NavItem(
            title: LangUtil.trans("navigation.settings"),
            iconFilled: AppIcons.settingsFilled,
            icon: AppIcons.settings,
            index: 3),
      ];
  final navBloc = getIt.get<BottomNavBarBloc>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemBar.setNavBarColor(context: context);
    });

    // LayoutFetch.findUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = View.of(context).viewInsets.bottom;
    bool isKeyboardVisible = bottomInset > 0.0;

    if (isKeyboardVisible != _isKeyboardVisible) {
      setState(() => _isKeyboardVisible = isKeyboardVisible);
    }
    final theme = Theme.of(context);

    return BlocBuilder<BottomNavBarBloc, BottomNavBarState>(builder: (context, state) {
      final bottomItems = navBar();

      return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          type: BottomNavigationBarType.fixed,
          currentIndex: state.activeIndex,
          selectedItemColor: theme.primaryColor,
          selectedLabelStyle: TextStyle(color: theme.primaryColor),
          onTap: (index) {
            navBloc.add(UpdateNavbarIndexEvent(newIndex: index));
          },
          items: bottomItems.map((item) {
            return BottomNavigationBarItem(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: state.activeIndex == item.index
                    ? AppIcon(
                        icon: item.iconFilled,
                        color: theme.primaryColor,
                      )
                    : AppIcon(
                        icon: item.icon,
                        color: theme.primaryColorDark,
                      ),
              ),
              label: item.title,
            );
          }).toList(),
        ),
        body: screens[state.activeIndex],
      );
    });
  }
}
