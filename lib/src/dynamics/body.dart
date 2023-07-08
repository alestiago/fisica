import 'package:fisica/fisica.dart';
import 'package:flutter/widgets.dart';
import 'package:forge2d/forge2d.dart' as box2d;

/// {@template Body}
///
/// {@endtemplate}
// TODO(alestiago): Add documentation.
@immutable
class Body extends StatefulWidget {
  /// {@macro Body}
  const Body({
    required this.child,
    super.key,
  });

  /// The body's child.
  final Widget child;

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  World? _world;
  box2d.Body? _body;
  final Matrix4 _currentTransformation = Matrix4.identity();
  final Matrix4 _candidateTransformation = Matrix4.identity();

  void _createBody(box2d.World world) {
    final bodyDef = box2d.BodyDef(
      type: box2d.BodyType.dynamic,
    );
    final body = world.createBody(bodyDef);

    // TODO(alestiago): Provide an interface for users to provide their own fixtures.
    final fixtureDef = box2d.FixtureDef(
      box2d.PolygonShape()
        ..setAsBox(
          0.5,
          0.5,
          box2d.Vector2.zero(),
          0,
        ),
    );
    body.createFixture(fixtureDef);

    _body = body;
  }

  void _updateTransformation() {
    final body = _body;
    if (body == null) return;

    body._computeTransformation(_candidateTransformation);
    if (_candidateTransformation != _currentTransformation) {
      setState(() {
        _currentTransformation.setFrom(_candidateTransformation);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final world = _world;
    if (world == null) {
      final world = World.of(context);
      _world = world;
      _createBody(world.world);
      world.notifier!.addListener(_updateTransformation);
    } else {
      final newWorld = World.of(context);
      if (_world != newWorld) {
        world.notifier!.removeListener(_updateTransformation);
        _world = newWorld;
        _createBody(newWorld.world);
        newWorld.notifier!.addListener(_updateTransformation);
      }
    }
  }

  @override
  void dispose() {
    final world = _world;
    if (world != null) {
      world.notifier!.removeListener(_updateTransformation);
      world.world.destroyBody(_body!);
      _world = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Transform(
        transform: _currentTransformation,
        child: widget.child,
      ),
    );
  }
}

extension on box2d.Body {
  void _computeTransformation(Matrix4 matrix4) {
    matrix4
      ..setIdentity()
      ..translate(position.x, position.y)
      ..rotateZ(angle);
  }
}
