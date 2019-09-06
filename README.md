# Tutorials for graphics
https://www.slynyrd.com/blog/2019/5/21/pixelblog-17-human-anatomy

https://raymond-schlitter.squarespace.com/blog/2018/1/10/pixelblog-1-color-palettes

https://makegames.tumblr.com/post/42648699708/pixel-art-tutorial

![](https://images.squarespace-cdn.com/content/v1/551a19f8e4b0e8322a93850a/1505784288105-DMW1RHB3RCZ8G6GLJ0OL/ke17ZwdGBToddI8pDm48kMql2_yefxtFZB38HrfJP65Zw-zPPgdn4jUwVcJE1ZvWQUxwkmyExglNqGp0IvTJZUJFbgE-7XRK3dMEBRBhUpzHWhcVKNmqX8Cqzw5ie5qqyN8Fihd2F-VIlcCn_YqesH5fieixBNmAtelFUm2FaA8/image-asset.gif?format=750w)

https://raymond-schlitter.squarespace.com/blog/2017/9/18/thyria-devlog-06-one-year-and-going-strong



# Custom Level properties
  1. `pixelsPerUnit` - `float` - (Default `160.0`) - height in pixels of viewport vertically (horizontally adjusting based on screen ratio)
  1. `offset.x` - `float` - (Default `0`) camera offset of left-bottom corner by **horizontal** axis in pixels
  1. `offset.y` - `float` - (Default `0`) camera offset of left-bottom corner by **vertical** axis in pixels

# Custom Layer properties
## All Layers
  1. `scrollRatio` - `float` - (Default `1.0`)
      * `scrollRatio.x` - set relative scrolling speed to offset of screen horizontally
      * `scrollRatio.y` - set relative scrolling speed to offset of screen vertically
      * `scrollRatio` - set relative scrolling speed to offset of screen both dirrections


# Custom Object properties
  1. `onKey[event.key]` - `string` - `Move.south` | `Move.west` | `Move.east` | `Move.north` | `Fire` or any other that supported by system
  1. `ammo.(name)[n].(prop)` - `int`:
    1. `name` - `string` - (default `_`) - any name to reference in `Fire` action   
    1. `prop` is one of 
       * `id`  - `int` - (default `0`) - relative tile id
       * `tilset` - `int` -  (default `0`) - `firstgid` of tileset to which **id** is relative
       * `firerate` - `int` - (default `10`) - pause between bullets are fired 
       * `damage` - `int` - (default `10`) - damage done by each individual  bullet
       * `offset.x` / `offset.y` - `int` - 
       * `velocity.x` / `velocity.y` - `int` - 
    1. `n` - `int` - each ammo pattern can have multiple bullets - it is just index of bullet  

## Animations

  Can be be assigned only to Tile-Object, and tile will be used as `anim.idle.E.id`

  `anim.(name).(direction).(id|tileset)` - `Int` - Animation atlas

  1. `name`
      * `walk` - movement animation

      Advanced

  2. `direction`
      * `none` or `_`  - default direction (no movement)   
      * `north` or `N` - up 
      * `north-east` or `NE`
      * `east` or `E` - right
      * `south-east` or `SE`
      * `south` or `S` - down 
      * `south-west` or `SW`
      * `west` or `W` - left
      * `north-west` or `NW`

  3. `id` - TileID of animation
  5. `tileset` - tileset name - default - same as tile-object


## Artificial Intelligence (Enemies)

   Hit points 
   
   1. `hp` - `int` -(default `10`)
   
   Death
   
   `onDeath.(explosion|reward|loadLevel|spwn)[n].(prop)` - `Int` - Animation atlas
   
   1. `onDeath.explosion[0].id` - `int`
   1. `onDeath.explosion[0].tileset` - `int`
   1. `onDeath.reward.id` - `int` -
   1. `onDeath.reward.tileset` - `int` -  
   1. `onDeath.reward.setAmmo` - `string` - 

   Spawn definition
   
   1. `spawn.delay` - `int`
   1. `spawn.interval` - `int`
   1. `spawn.lifetime` - `int`
   1. `spawn.repeat` - `int`
   1. `spawn.object` - `int`
   
   
 

  
   Path definition `a.target[n].(steps|wait|action)` - path definition of enemy
    
   1. `n` - `int` - incremental index of target
   1. `steps` - `int` - amount of frames to travel to next target spot
   1. `wait` - `int` - amount of frames stay on that spot
   1. `action` - `string` - any action (`onKey`) that take while traveling to that spot / waiting on spot
