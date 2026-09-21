import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/route_names.dart';

/// Standard back button for secondary/detail screens.
///
/// Returns to the previous screen using Navigator or GoRouter stack pop.
/// If there is no route to pop (e.g. opened directly), gracefully navigates
/// to [fallbackRoute].
class AppBackButton extends StatelessWidget {
  final String fallbackRoute;
  final VoidCallback? onPreBack;

  const AppBackButton({
    super.key,
    this.fallbackRoute = RouteNames.dashboard,
    this.onPreBack,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () {
        onPreBack?.call();
        final navigator = Navigator.maybeOf(context);
        if (navigator != null && navigator.canPop()) {
          navigator.pop();
          return;
        }
        try {
          if (context.canPop()) {
            context.pop();
            return;
          }
        } catch (_) {}
        try {
          context.go(fallbackRoute);
        } catch (_) {}
      },
    );
  }
}
