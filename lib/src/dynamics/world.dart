import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:forge2d/forge2d.dart' as box2d;

/// {@template WorldStepNotifier}
/// Notifies whenever the World is stepped in.
/// {@endtemplate}
class WorldStepNotifier extends ChangeNotifier {
  /// {@macro WorldStepNotifier}
  WorldStepNotifier();

  /// Notifies the listeners that the world has stepped.
  void step() => notifyListeners();
}

/// {@template World}
///
/// {@endtemplate}
// TODO(alestiago): Add documentation.
class World extends InheritedNotifier<WorldStepNotifier> {
  /// {@macro World}
  World({
    required Widget child,
    super.key,
  }) : super(
          child: _WorldTicker(child: child),
          notifier: WorldStepNotifier(),
        ) {
    final gravity = box2d.Vector2(0, 10);
    world = box2d.World(gravity);
  }

  /// Raw `Box2D` world.
  ///
  /// See also:
  ///
  /// * [box2d.World], the world class manages all physics entities.
  /// * [Box2D](https://box2d.org/), a 2D Physics Engine.
  late final box2d.World world;

  /// Returns the [World] instance from the closest [World] ancestor.
  ///
  /// Throws an [AssertionError] if there is no [World] ancestor.
  static World of(BuildContext context) {
    final world = context.dependOnInheritedWidgetOfExactType<World>();
    assert(world != null, 'No World found in context');
    return world!;
  }

  @override
  bool updateShouldNotify(covariant World oldWidget) {
    final changed = oldWidget.world != world;
    // TODO(alestiago): Investigate if there are memory leaks when the previous
    // world is not cleared.
    return changed;
  }
}

@immutable
class _WorldTicker extends StatefulWidget {
  const _WorldTicker({required this.child});

  final Widget child;

  @override
  State<_WorldTicker> createState() => _WorldTickerState();
}

class _WorldTickerState extends State<_WorldTicker>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  void _onStep(Duration elapsed) {
    if (!mounted) return;
    final world = World.of(context);

    final dt =
        elapsed.inMicroseconds.toDouble() / Duration.microsecondsPerSecond;

    /// TODO(alestiago): Check if dt unit is microseconds.
    world.world.stepDt(dt);
    world.notifier!.step();
  }

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onStep);
    _ticker.start();
  }

  @override
  void dispose() {
    super.dispose();
    _ticker.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
