import 'package:flutter/material.dart';

import '../design_system/app_breakpoints.dart';

/// Centraliza o conteúdo com [maxWidth] e padding responsivo.
///
/// No celular usa quase toda a largura; no desktop evita esticar cards
/// infinitamente e centraliza o bloco principal.
class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.contentMaxWidth,
    this.padding,
    this.bottomExtra = 0,
    this.scrollable = true,
    this.physics,
    this.controller,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final double bottomExtra;
  final bool scrollable;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final h = context.pagePaddingH;
    final resolved = padding ??
        EdgeInsets.fromLTRB(
          h,
          8,
          h,
          // Espaço para bottom nav flutuante no mobile.
          (context.useSideNav ? 24 : 110) + bottomExtra,
        );

    final body = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: resolved,
          child: child,
        ),
      ),
    );

    if (!scrollable) return body;

    return SingleChildScrollView(
      controller: controller,
      physics: physics,
      child: body,
    );
  }
}

/// Grade responsiva sem aspect ratio gigante — altura intrínseca por filho.
class ResponsiveWrapGrid extends StatelessWidget {
  const ResponsiveWrapGrid({
    super.key,
    required this.children,
    this.columns,
    this.spacing = 10,
    this.runSpacing = 10,
    this.childAspectRatio,
  });

  final List<Widget> children;
  final int? columns;
  final double spacing;
  final double runSpacing;

  /// Se nulo, usa altura intrínseca via [Wrap] em vez de GridView.
  final double? childAspectRatio;

  @override
  Widget build(BuildContext context) {
    final cols = columns ?? context.quickAccessColumns;

    if (childAspectRatio != null) {
      return GridView.count(
        crossAxisCount: cols,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: runSpacing,
        crossAxisSpacing: spacing,
        childAspectRatio: childAspectRatio!,
        children: children,
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      final totalGaps = spacing * (cols - 1);
      final itemWidth = (constraints.maxWidth - totalGaps) / cols;
      return Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        children: [
          for (final child in children)
            SizedBox(width: itemWidth, child: child),
        ],
      );
    });
  }
}
