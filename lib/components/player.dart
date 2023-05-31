import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';

enum PlayerType {
  large,
  small,
}

enum PlayerState {
  walk,
  idle,
  attack,
  jump,
  hit,
}

class Player extends PositionComponent with HasGameRef {
  Player({
    super.position,
    this.type = PlayerType.large,
    this.state = PlayerState.idle,
  }) {
    _groundY = position.y;
  }

  final PlayerType type;
  PlayerState state;

  final speed = 200.0;
  final gravity = 500.0;
  final jumpPower = 200.0;

  late final double _groundY;
  late final SpriteAnimationComponent _sprite;
  late final SpriteSheet _spriteSheet;

  var vx = 0.0;
  var vy = 0.0;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    _sprite = SpriteAnimationComponent(
      position: Vector2(0, -64),
      size: Vector2.all(64),
      anchor: Anchor.topCenter,
    );
    await add(_sprite);

    final image = await game.images.load('Retro-Lines-Player-transparent.png');

    final pixels = await image.pixelsInUint8();
    for (var i = 0; i < pixels.length; i += 4) {
      final r = pixels[i];
      final g = pixels[i + 1];
      final b = pixels[i + 2];
      final a = pixels[i + 3];
      final color = Color.fromARGB(a, r, g, b);

      if (color == const Color.fromARGB(255, 255, 77, 237) ||
          color == const Color.fromARGB(255, 237, 77, 255)) {
        pixels[i] = 255;
        pixels[i + 1] = 0;
        pixels[i + 2] = 0;
        pixels[i + 3] = 255;
      } else if (color == const Color.fromARGB(255, 255, 255, 0) ||
          color == const Color.fromARGB(255, 0, 255, 255)) {
        pixels[i] = 0;
        pixels[i + 1] = 255;
        pixels[i + 2] = 0;
        pixels[i + 3] = 255;
      }
    }
    final replacedImage =
        await ImageExtension.fromPixels(pixels, image.width, image.height);

    _spriteSheet = SpriteSheet(
      image: replacedImage,
      srcSize: Vector2.all(16),
    );

    _updateAnimation();
  }

  @override
  void update(double dt) {
    super.update(dt);

    position += Vector2(vx, vy) * dt;

    if (vy != 0) {
      vy += gravity * dt;
      if (position.y >= _groundY) {
        vy = 0;
        position.y = _groundY;
        if (vx != 0) {
          _updateState(PlayerState.walk);
        } else {
          _updateState(PlayerState.idle);
        }
      }
    }
  }

  void idle() {
    vx = 0;
    if (state != PlayerState.jump) {
      _updateState(PlayerState.idle);
    }
  }

  void moveLeft() {
    _move(-speed);
    if (!isFlippedHorizontally) {
      flipHorizontally();
    }
  }

  void moveRight() {
    _move(speed);
    if (isFlippedHorizontally) {
      flipHorizontally();
    }
  }

  void jump() {
    if (vy != 0) {
      return;
    }

    vy = -jumpPower;
    _updateState(PlayerState.jump);
  }

  void attack() {
    if (state == PlayerState.attack) {
      return;
    }

    _updateState(PlayerState.attack);
    Future.delayed(
      const Duration(milliseconds: 200),
      () {
        if (vy != 0) {
          _updateState(PlayerState.jump);
        } else if (vx != 0) {
          _updateState(PlayerState.walk);
        } else {
          _updateState(PlayerState.idle);
        }
      },
    );
  }

  void takeDamage() {
    _updateState(PlayerState.hit);
  }

  void _move(double vx) {
    this.vx = vx;
    if (state == PlayerState.idle) {
      _updateState(PlayerState.walk);
    }
  }

  void _updateState(PlayerState nextState) {
    if (state == nextState) {
      return;
    }

    state = nextState;
    _updateAnimation();
  }

  void _updateAnimation() async {
    _sprite.animation = _spriteSheet.createAnimation(
      row: _row(),
      from: _from(),
      to: _to(),
      stepTime: _stepTime(),
    );
  }

  int _row() {
    final base = type == PlayerType.large ? 1 : 7;
    switch (state) {
      case PlayerState.walk:
        return base + 0;
      case PlayerState.idle:
        return base + 1;
      case PlayerState.attack:
        return base + 2;
      case PlayerState.jump:
        return base + 3;
      case PlayerState.hit:
        return base + 4;
    }
  }

  int _from() {
    switch (state) {
      case PlayerState.walk:
        return 0;
      case PlayerState.idle:
        return 0;
      case PlayerState.attack:
        return 0;
      case PlayerState.jump:
        return 1;
      case PlayerState.hit:
        return 0;
    }
  }

  int _to() {
    switch (state) {
      case PlayerState.walk:
        return 4;
      case PlayerState.idle:
        return 2;
      case PlayerState.attack:
        return 2;
      case PlayerState.jump:
        return 2;
      case PlayerState.hit:
        return 2;
    }
  }

  double _stepTime() {
    switch (state) {
      case PlayerState.walk:
        return 0.2;
      case PlayerState.idle:
        return 0.4;
      case PlayerState.attack:
        return 0.1;
      case PlayerState.jump:
        return 1.0;
      case PlayerState.hit:
        return 0.1;
    }
  }
}
