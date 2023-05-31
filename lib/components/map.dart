import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

class Map extends PositionComponent with HasGameRef {
  Map({super.position});

  @override
  Future<void> onLoad() async {
    super.onLoad();

    size = Vector2(1600, 1200);

    await add(
      RectangleComponent(
        size: Vector2(size.x, 1),
        position: Vector2(0, size.y * 0.5),
        priority: 1,
      ),
    );
    await add(
      RectangleComponent(
        size: Vector2(1, size.y),
        position: Vector2(size.x * 0.5, 0),
        priority: 1,
      ),
    );

    final image = await game.images.load('Retro-Lines-Tiles-transparent.png');

    final spriteSheet = SpriteSheet(
      image: image,
      srcSize: Vector2.all(16),
    );

    for (var i = 0; i < width / spriteSheet.srcSize.x; i++) {
      final sprite = SpriteComponent(
        sprite: spriteSheet.getSprite(0, 1 + i % 3),
        position: Vector2(i * 64, height * 0.5),
        size: Vector2.all(64),
      );
      await add(sprite);
    }
  }
}
