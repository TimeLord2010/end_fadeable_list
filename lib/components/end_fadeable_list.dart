import 'package:flutter/material.dart';

import '../usecases/create_linear_func.dart';

class EndFadeableList extends StatefulWidget {
  const EndFadeableList({
    super.key,
    required this.scrollController,
    required this.child,
    this.maxShadeSizeFraction,
    this.shadeFadeScrollPosition,
    this.scrollDirection = Axis.vertical,
  });

  /// Used as a gradient stop. This parameter defines the height or width
  /// of the fade effect.
  ///
  /// Default value is 0.2.
  final double? maxShadeSizeFraction;

  /// The position at the end of the scrollable widget to beging to display the
  /// fade effect.
  ///
  /// Default value is 50.
  final double? shadeFadeScrollPosition;

  final Axis scrollDirection;

  final ScrollController scrollController;

  final Widget child;

  factory EndFadeableList.listView({
    required List<Widget> children,
    required ScrollController scrollController,
    required double? maxShadeSizeFraction,
  }) {
    return EndFadeableList(
      scrollController: scrollController,
      maxShadeSizeFraction: maxShadeSizeFraction,
      child: ListView(
        controller: scrollController,
        children: children,
      ),
    );
  }

  @override
  State<EndFadeableList> createState() => _EndFadeableListState();
}

class _EndFadeableListState extends State<EndFadeableList> {
  @override
  void initState() {
    widget.scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var maxShadeSizeFraction = widget.maxShadeSizeFraction ?? .2;
    assert(maxShadeSizeFraction >= 0 && maxShadeSizeFraction <= 1);
    return ShaderMask(
      shaderCallback: (bounds) {
        double endVisibleFrac = 1;
        double beginVisibleFrac = 1 - maxShadeSizeFraction;

        if (widget.scrollController.hasClients) {
          var position = widget.scrollController.position;
          var maxScrollExtent = position.maxScrollExtent;
          var shadeFadeScrollPosition = widget.shadeFadeScrollPosition ?? 50;
          var endShadeBegin = maxScrollExtent - shadeFadeScrollPosition;
          var currentPos = position.pixels;

          // Calculating end frac
          if (currentPos >= endShadeBegin) {
            var equation = createLinearFunc(
              Offset(endShadeBegin, 1),
              Offset(maxScrollExtent, 0),
            );
            endVisibleFrac = equation(currentPos);
          }

          // Calculating begin frac
          if (currentPos < shadeFadeScrollPosition) {
            var equation = createLinearFunc(
              const Offset(0, 1),
              Offset(shadeFadeScrollPosition, 1 - maxShadeSizeFraction),
            );
            beginVisibleFrac = equation(currentPos);
          }
        }

        var finalStop = endVisibleFrac * maxShadeSizeFraction;
        var beginStop = beginVisibleFrac;

        LinearGradient linearGradient;

        if (widget.scrollDirection == Axis.vertical) {
          linearGradient = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(1),
              Colors.black.withOpacity(1),
              Colors.transparent,
            ],
            stops: [0, finalStop, beginStop, 1],
          );
        } else {
          linearGradient = LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(1),
              Colors.black.withOpacity(1),
              Colors.transparent,
            ],
            stops: [0.0, finalStop, beginStop, 1.0],
          );
        }

        return linearGradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        );
      },
      blendMode: BlendMode.dstIn,
      child: widget.child,
    );
  }
}
