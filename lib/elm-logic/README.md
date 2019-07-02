# Game Logic

An ECS library for Elm. `Logic` provides an easy way to build a full game, using common Entity-Component-System architecture.


## Entity–component–system (ECS)

is an architectural pattern that is mostly used in game development. ECS follows the composition over inheritance principle that allows greater flexibility in defining entities where every object in a game's scene is an entity (e.g. enemies, bullets, vehicles, etc.). Every entity consists of one or more components which add behavior or functionality. Therefore, the behavior of an entity can be changed at runtime by adding or removing components. This eliminates the ambiguity problems of deep and wide inheritance hierarchies that are difficult to understand, maintain and extend. Common ECS approaches are highly compatible and often combined with data-oriented design techniques.

## Entity

Entity is just combination of components

```elm
Entity.create id world
    |> Entity.with ( positionSpec, ( 100, 100 ) )
    |> Entity.with ( velocitySpec, ( -1, -1 ) )
```

## Component

Component can be any type of elm
```elm
type alias Position = (Int, Int)
type alias Velocity = (Int, Int)
type alias Life = Int
```

## System


```elm
system : Logic.Component.Spec Velocity world -> Logic.Component.Spec Position world -> System world
system =
    Logic.System.step2
        (\( velocity, _ ) ( pos, setPos ) -> setPos (Vec2.add velocity pos))
```
