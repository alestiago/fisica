import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:forge2d/forge2d.dart' as box2d;

/// {@template WorldStepListenable}
///
/// {@endtemplate}
class WorldStepListenable extends ChangeNotifier {
  /// {@macro WorldStepListenable}
  WorldStepListenable();

  /// Notifies the listeners that the world has stepped.
  void step() {
    notifyListeners();
  }
}

/// {@template World}
///
/// {@endtemplate}
// TODO(alestiago): Add documentation.
class World extends InheritedWidget {
  /// {@macro World}
  World({
    required Widget child,
    super.key,
  })  : stepListenable = WorldStepListenable(),
        super(
          child: _WorldTicker(child: child),
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

  /// {@macro WorldStepListenable}
  final WorldStepListenable stepListenable;

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
    // TODO(alestiago): Invesitgate if there are memory leaks when the previous
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
    world.world.stepDt(dt);
    world.stepListenable.step();
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
