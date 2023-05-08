import 'dart:async';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:figuras_flame/figures.dart';
import 'package:flutter/services.dart';
import 'tap_button.dart';
import 'dart:math';
import 'package:flame/components.dart';

var end = 0;

class MyGame extends FlameGame with KeyboardEvents {
  bool get debug => true;
  late Star star;

  final sizeOfPlayer = Vector2(80, 100);

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 200, 200, 200);
  }

  @override
  void render(Canvas canvas) {
    final Flower flower = children.query<Flower>().first;
    flower.position = Vector2(flower.position.x, size.y - sizeOfPlayer.y);
    super.render(canvas);
  }

  @override
  Future<void> onLoad() async {
    children.register<Flower>();
    await add(Flower(
      position: Vector2(size.x / 2, size.y - sizeOfPlayer.y),
      paint: Paint()..color = Colors.pink,
      size: sizeOfPlayer,
    ));

    await add(Tapbutton(moverDerecha)
      ..position = Vector2(size.x - 50, 75)
      ..size = Vector2(100, 100));
    await add(Tapbutton(moverIzquierda)
      ..position = Vector2(50, 75)
      ..size = Vector2(100, 100));

    star = Star(
      color: Color.fromARGB(255, 255, 143, 143),
      position: Vector2(0, size.x),
    );
    await add(star);
  }

  @override
  void update(double dt) {
    if (children.isNotEmpty) {
      final Flower flower = children.query<Flower>().first;
      // final Vector2 starPosition = star.position;
      // final Vector2 flowerPosition = flower.position;
      // const double speed = 10000; // ajustar la velocidad de seguimiento
      // final double dx = starPosition.x - flowerPosition.x;
      // final double dy = starPosition.y - flowerPosition.y;
      // final double distance = sqrt(dx * dx + dy * dy);
      // final double ratio = speed / distance;
      // final double vx = dx * ratio;
      // final double vy = dy * ratio;
      // flower.position.y += vy * dt;

      flower.position.x += end * dt;
    }

    super.update(dt);
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isKeyDown = event is RawKeyDownEvent;
    if (isKeyDown) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
        moverIzquierda();
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
        moverDerecha();
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void moverIzquierda() {
    final Flower flower = children.query<Flower>().first;
    flower.position.x -= 8;
    if (flower.position.x + flower.width < 0) {
      flower.position.x = size.x;
    }
  }

  mover() {
    final Flower flower = children.query<Flower>().first;
    flower.position.x -= 8;
  }

  void moverDerecha() {
    final Flower flower = children.query<Flower>().first;
    flower.position.x += 8;
    if (flower.position.x > size.x) {
      flower.position.x = -flower.size.x;
    }
  }
}

class Star extends PositionComponent with DragCallbacks {
  Star({
    required this.color,
    super.position,
  }) {
    _path = Path()..addRect(Rect.fromLTWH(0, 0, 1000, 60));
  }

  final Color color;
  final Paint _paint = Paint();
  final Paint _borderPaint = Paint()
    ..color = const Color(0xFFffffff)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  final _shadowPaint = Paint()
    ..color = const Color(0xFF000000)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
  late final Path _path;
  bool _isDragged = false;

  @override
  bool containsLocalPoint(Vector2 point) {
    return _path.contains(point.toOffset());
  }

  @override
  void render(Canvas canvas) {
    if (_isDragged) {
      _paint.color = color.withOpacity(0.5);
      canvas.drawRect(Rect.fromLTWH(0, 0, 1000, 60), _paint);
      canvas.drawRect(Rect.fromLTWH(0, 0, 1000, 60), _borderPaint);
    } else {
      _paint.color = color.withOpacity(1);
      canvas.drawRect(Rect.fromLTWH(0, 0, 1000,60), _shadowPaint);
      canvas.drawRect(Rect.fromLTWH(0, 0, 1000,60), _paint);
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _isDragged = true;
    priority = 10;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _isDragged = false;
    priority = 0;
    end = 0;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    final delta = event.delta;
    //position += Vector2(delta.x, 0); // solo actualizar la posición en el eje X
    if (delta.x > 0) {
      end += 3;
    } else if (delta.x < 0) {
      end -= 3;
    }
  }
}

const tau = 2 * pi;
