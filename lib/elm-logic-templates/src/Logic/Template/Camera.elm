module Logic.Template.Camera exposing (Camera, WithId, spec)

{-| <http://www.gamasutra.com/blogs/ItayKeren/20150511/243083/Scroll_Back_The_Theory_and_Practice_of_Cameras_in_SideScrollers.php>

    +---+----------------------+----------------------------------------------------------------------------------------------+
    | + | auto-scroll          | Player only has no control over scrolling                                                    |
    +---+----------------------+----------------------------------------------------------------------------------------------+
    | + | camera-path          | Predefined progression path throughout the level                                             |
    +---+----------------------+----------------------------------------------------------------------------------------------+
    | - | camera-window        | Push camera position as the player hits the window edge                                      |
    +---+----------------------+----------------------------------------------------------------------------------------------+
    | - | cinematic-paths      | Camera suspends normal function to provide an out-of-screen narrative context                |
    +---+----------------------+----------------------------------------------------------------------------------------------+
    | - | cue-focus            | Focus is influenced by game world cues (e.g. attractors)                                     |
    +---+----------------------+----------------------------------------------------------------------------------------------+
    | - | dual-forward-focus   | Player direction changes switch camera focus to enable wide forward view                     |
    +---+----------------------+----------------------------------------------------------------------------------------------+
    | - | edge-snapping        | Set a hard edge for camera positioning                                                       |
    +---+----------------------+----------------------------------------------------------------------------------------------+
    | - | gesture-focus        | Gameplay triggered camera gestures                                                           |
    +---+----------------------+----------------------------------------------------------------------------------------------+
    | - | lerp-smoothing       | Continuously reduce the distance between camera and active player using Linear Interpolation |
    +---+----------------------+----------------------------------------------------------------------------------------------+
    | - | physics-smoothing    | Camera is a physics enabled entity                                                           |
    +---+----------------------+----------------------------------------------------------------------------------------------+
    | + | platform-snapping    | Camera snaps to the player only as it lands on a platform                                    |
    +---+----------------------+----------------------------------------------------------------------------------------------+
    | - | position-averaging   | Focus on the average position of all relevant targets                                        |
    +---+----------------------+----------------------------------------------------------------------------------------------+
    | + | position-locking     | Camera is locked to the player’s position                                                    |
    +---+----------------------+----------------------------------------------------------------------------------------------+
    | - | position-snapping    | Constantly reduce window drift by focusing the camera back on the player                     |
    +---+----------------------+----------------------------------------------------------------------------------------------+
    | - | projected-focus      | Camera follows the projected (extrapolated) position of the player                           |
    +---+----------------------+----------------------------------------------------------------------------------------------+
    | - | region-based-anchors | Different regions (even within levels) set different anchors for position and focus          |
    +---+----------------------+----------------------------------------------------------------------------------------------+
    | - | region-focus         | Focus on a region anchor                                                                     |
    +---+----------------------+----------------------------------------------------------------------------------------------+
    | - | speedup-pull-zone    | Pull the camera to catch up with player’s speed after it crosses over window’s edge          |
    +---+----------------------+----------------------------------------------------------------------------------------------+
    | - | speedup-push-zone    | When inside the push-zone                                                                    |
    +---+----------------------+----------------------------------------------------------------------------------------------+
    | - | static-forward-focus | Extra view space in the principal progression direction                                      |
    +---+----------------------+----------------------------------------------------------------------------------------------+
    | - | target-focus         | Camera follows controller input to provide true visual forward focus                         |
    +---+----------------------+----------------------------------------------------------------------------------------------+
    | - | zoom-to-fit          | Change zoom or move forward/back to provide a close-up view of relevant elements             |
    +---+----------------------+----------------------------------------------------------------------------------------------+

-}

import Logic.Template.Camera.Common


type alias Camera =
    Logic.Template.Camera.Common.Any {}


type alias WithId a =
    Logic.Template.Camera.Common.WithId a


spec =
    { get = .camera
    , set = \comps world -> { world | camera = comps }
    }
