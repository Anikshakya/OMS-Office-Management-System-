import 'package:flutter/material.dart';

class FadeInUp extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Function(AnimationController)? controller;
  final bool manualTrigger;
  final bool animate;
  final double from;

  FadeInUp({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.delay = const Duration(milliseconds: 0),
    this.controller,
    this.manualTrigger = false,
    this.animate = true,
    this.from = 100,
  }) {
    if (manualTrigger && controller == null) {
      throw FlutterError(
        'If you want to use manualTrigger:true, '
        'you must provide the controller property.',
      );
    }
  }

  @override
  FadeInUpState createState() => FadeInUpState();
}

class FadeInUpState extends State<FadeInUp>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  late Animation<double> opacity;

  bool disposed = false;
  bool hasAnimated = false;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: widget.duration, vsync: this);

    animation = Tween<double>(
      begin: widget.from,
      end: 0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));

    opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
      ),
    );

    if (widget.controller != null) {
      widget.controller!(controller);
    }

    if (!widget.animate) {
      controller.value = 1;
    } else {
      _startAnimation();
    }
  }

  void _startAnimation() {
    if (disposed || hasAnimated || !widget.animate || widget.manualTrigger) {
      return;
    }

    hasAnimated = true;

    Future.delayed(widget.delay, () {
      if (!disposed && mounted) {
        controller.forward();
      }
    });
  }

  @override
  void dispose() {
    disposed = true;
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, animation.value),
          child: Opacity(opacity: opacity.value, child: widget.child),
        );
      },
    );
  }
}

class FadeInRight extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Function(AnimationController)? controller;
  final bool manualTrigger;
  final bool animate;
  final double from;

  FadeInRight({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.delay = const Duration(milliseconds: 0),
    this.controller,
    this.manualTrigger = false,
    this.animate = true,
    this.from = 100,
  }) {
    if (manualTrigger && controller == null) {
      throw FlutterError(
        'If you want to use manualTrigger:true, '
        'you must provide the controller property.',
      );
    }
  }

  @override
  FadeInRightState createState() => FadeInRightState();
}

class FadeInRightState extends State<FadeInRight>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  late Animation<double> opacity;

  bool disposed = false;
  bool hasAnimated = false;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: widget.duration, vsync: this);

    animation = Tween<double>(
      begin: widget.from,
      end: 0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));

    opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
      ),
    );

    if (widget.controller != null) {
      widget.controller!(controller);
    }

    if (!widget.animate) {
      controller.value = 1;
    } else {
      _startAnimation();
    }
  }

  void _startAnimation() {
    if (disposed || hasAnimated || !widget.animate || widget.manualTrigger) {
      return;
    }

    hasAnimated = true;

    Future.delayed(widget.delay, () {
      if (!disposed && mounted) {
        controller.forward();
      }
    });
  }

  @override
  void dispose() {
    disposed = true;
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(animation.value, 0),
          child: Opacity(opacity: opacity.value, child: widget.child),
        );
      },
    );
  }
}

class FadeInRightBig extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Function(AnimationController)? controller;
  final bool manualTrigger;
  final bool animate;
  final double from;

  FadeInRightBig({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1400),
    this.delay = const Duration(milliseconds: 0),
    this.controller,
    this.manualTrigger = false,
    this.animate = true,
    this.from = 600,
  }) {
    if (manualTrigger && controller == null) {
      throw FlutterError(
        'If you want to use manualTrigger:true, '
        'you must provide the controller property.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeInRight(
      duration: duration,
      delay: delay,
      controller: controller,
      manualTrigger: manualTrigger,
      animate: animate,
      from: from,
      child: child,
    );
  }
}
