## Custom Level properties
  1. `pixelPerUnit` - `float` - (Default `160.0`) - height in pixels of viewport vertically (horizontally adjusting based on screen ratio)
  2. `gravitiy` - `float` - (Default `10.0`) - acceleration pixels pers second each second * mass

## Custom Layer properties
  1. `repeat` - `string` - (Default `no-repeat`)
      * `repeat`	repeated both vertically and horizontally
      * `repeat-x` repeated only horizontally
      * `repeat-y`	repeated only vertically
      * `no-repeat` not repeated. The layer will only be shown once and repead last pixel (or tile) to fill empty space

  2. `scrollRatio` - `float` - (Default `1.0`)
      * `scrollRatio.x` - set relative scrolling speed to offset of screen horizontally
      * `scrollRatio.y` - set relative scrolling speed to offset of screen vertically
      * `scrollRatio` - set relative scrolling speed to offset of screen both dirrections

## Custom Object properties
  1. `runLeftAnim` - `TileId`
  2. `runRightAnim` - `TileId`
  3. `buttonLeft` (Maybe change to `OnKeyUp[KeyCode] - Player.Move.Right` - where `Player` is name of object) - [`keyCode`](http://keycode.info/) - (Fallback to `37`)
  4. `buttonRight` - [`KeyCode`](http://keycode.info/) - (Fallback to `39`)
  5. `atomove.x` - `float` - auto move by horizontal axis
  6. `atomove.y` - `float` - auto move by vertical axis
  7. `cameraOffset` - `Vec2` of `%, float(px)`