## Custom Level properties
  1. `pixelPerUnit` - `float` - (Default `160.0`) - height in pixels of viewport vertically (horizontally adjusting based on screen ratio)
  1. `offset.x` - `float` - (Default `0`) camera offset of left-bottom corner by **horizontal** axis in pixels
  1. `offset.y` - `float` - (Default `0`) camera offset of left-bottom corner by **vertical** axis in pixels
  1. `gravitiy` - `float` - (Default `-1.0`) - acceleration pixels pers second each second
  1. `System.enable|disable` - `string` enable or disable one of subsystem
      * **Config no working** `jump` - (enable by default) characters can jum
      * **NOT IMPLEMENTED** `slide`
      * **NOT IMPLEMENTED** `wall-jump`
      * **NOT IMPLEMENTED** `shoot`
      * **NOT IMPLEMENTED** `smart-ai`
  1. **NOT IMPLEMENTED** `camera` Static / follow and other stuff - find way how to discribe it

## Custom Layer properties
#All Layers
  1. `scrollRatio` - `float` - (Default `1.0`)
      * `scrollRatio.x` - set relative scrolling speed to offset of screen horizontally
      * `scrollRatio.y` - set relative scrolling speed to offset of screen vertically
      * `scrollRatio` - set relative scrolling speed to offset of screen both dirrections
### Image Layer
  1. `repeat` - `string` - (Default `repeat`)
      * `repeat` repeated both vertically and horizontally
      * `repeat-x` repeated only horizontally
      * `repeat-y` repeated only vertically
      * `no-repeat` not repeated. The layer will only be shown once and repead last pixel (or tile) to fill empty space
  1. **NOT IMPLEMENTED** `position` - `string` - (Default `left bottom`)
      * `left top` -
      * `left center` -
      * `left bottom` -
      * `right top` -
      * `right center` -
      * `right bottom` -
      * `center top` -
      * `center center` -
      * `center bottom` -


## Custom Object properties
  1. `onKey[event.key]` - `string` - `Move.south` | `Move.west` | `Move.east` | `Move.north` | `Fire` | `Jump` or any other that supported by system
  1. `ammo.(name).(id|tileset)` - `int`:
        1. `name` - `string` - (default `_`) - any name to reference in `Fire` action
        1. `id`  - `int` - (default `0`) - relative tile id
        1. `tilset` - (default `0`) - `firstgid` of tileset to which **id** is relative

  1. **NOT IMPLEMENTED** `atomove.x` - `float` - auto move by horizontal axis
  1. **NOT IMPLEMENTED** `atomove.y` - `float` - auto move by vertical axis
  1. **NOT IMPLEMENTED** `cameraOffset` - `Vec2` of `%, float(px)`
  1. **NOT IMPLEMENTED** `onHit.[ID].loadLevel` - `filename`
  1. **NOT IMPLEMENTED** `onClick.[ID].loadLevel` - `filename`
### Physics
  1. `mass` - `float` - (default `1`) - 
### Animactions

  **NOT IMPLEMENTED**

  Can be be assigned only to Tile-Object, and tile will be used as `anim.idle.E.id`

  `anim.(name).(direction).(id|tileset)` - `Int` - Animation atlas

  1. `name`
      * `walk` - walk animation
      * `run` - run animation (_if not defined `walk` will be used_)
      * `stand` | `idle` - no movement aninmation (default animation of tile)
      * `jump` - jumping animation
      * `fall` - animation on fall
      * `hit` - got hit animation
      * `die` - got killed animation

      Advanced

      * `land` - animation after land
      * `before_jump` - animation that take place befor jump (also freezes action for animation time)
      * `slide`
      * `dash` -  air dash animation / hight speed (more than run)
      * `climbing` - sit on wall
      * `wall-jump` - jump out of wall

      ... More be added
  2. `direction`
      * `north` or `N` - up (_not used in platforme_)
      * `north-east` or `NE`
      * `east` or `E` - right
      * `south-east` or `SE`
      * `south` or `S` - down (_not used in platforme_)
      * `south-west` or `SW`
      * `west` or `W` - left
      * `north-west` or `NW`

  3. `id` - TileID of animation
  5. `tileset` - tileset name - default - same as tile-object


[Dark Ambient Retro Game Music](https://www.playonloop.com/2019-music-loops/the-foyer/)



Info for feature work:
https://medium.com/@porteneuve/mastering-git-subtrees-943d29a798ec - use that for levels


http://blogs.love2d.org/content/let-it-glow-dynamically-adding-outlines-characters -- Glow / characters under building

https://www.redblobgames.com/articles/visibility/ -- LIGHTS!!!


LOT OF SHADERS:https://www.raywenderlich.com/2323-opengl-es-pixel-shaders-tutorial
