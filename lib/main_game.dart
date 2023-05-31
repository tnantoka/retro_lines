import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'components/components.dart';

class MainGame extends FlameGame with KeyboardEvents {
  late final Player _playerLarge;
  late final Player _playerSmall;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final map = Map();
    await add(map);

    await add(
      _playerLarge = Player(
        position: Vector2(
          size.x * 0.5,
          map.height * 0.5,
        ),
      ),
    );
    await add(
      _playerSmall = Player(
        position: Vector2(
          size.x * 0.4,
          map.height * 0.5,
        ),
        type: PlayerType.small,
      ),
    );

    camera.followComponent(
      _playerLarge,
      worldBounds: Rect.fromLTWH(
        0,
        0,
        map.width,
        map.height,
      ),
    );
  }

  @override
  KeyEventResult onKeyEvent(
      RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    var isHandled = false;

    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      _playerLarge.moveLeft();
      _playerSmall.moveLeft();
      isHandled = true;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      _playerLarge.moveRight();
      _playerSmall.moveRight();
      isHandled = true;
    }

    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      _playerLarge.jump();
      _playerSmall.jump();
      isHandled = true;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      _playerLarge.takeDamage();
      _playerSmall.takeDamage();
      isHandled = true;
    }

    if (keysPressed.contains(LogicalKeyboardKey.space)) {
      _playerLarge.attack();
      _playerSmall.attack();
      isHandled = true;
    }

    if (!isHandled) {
      _playerLarge.idle();
      _playerSmall.idle();
    }

    return isHandled ? KeyEventResult.handled : KeyEventResult.ignored;
  }
}
