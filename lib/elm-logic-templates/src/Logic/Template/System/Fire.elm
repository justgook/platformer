module Logic.Template.System.Fire exposing (system)

import Logic.Component as Component
import Logic.Entity as Entity exposing (EntityID)
import Logic.Launcher as Launcher
import Logic.System exposing (System, applyIf)
import Logic.Template.Component.Ammo as Ammo exposing (Ammo)
import Logic.Template.Input as Input exposing (Input)
import Set


system : (EntityID -> Ammo.Template -> Launcher.World world -> Launcher.World world) -> Component.Spec Input (Launcher.World world) -> Component.Spec Ammo (Launcher.World world) -> Launcher.World world -> Launcher.World world
system f inputSpec ammoSpec world =
    Logic.System.indexedFoldl2
        (\i key ammo acc ->
            if Set.member "Fire" key.action then
                case Ammo.get ammo of
                    Just templates ->
                        List.foldl
                            (\template acc_ ->
                                if modBy template.fireRate acc.frame == 0 then
                                    f i template acc_

                                else
                                    acc_
                            )
                            acc
                            templates

                    Nothing ->
                        acc

            else
                acc
        )
        (inputSpec.get world)
        (ammoSpec.get world)
        world
