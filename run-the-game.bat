REM Prepare everything needed to run the game locally.
REM In case of problems, look at the console output from this script.

git clone -b assets --single-branch https://github.com/justgook/platformer.git ./gh-pages/assets

REM Following command depends on elm-live (https://github.com/wking-io/elm-live) already being installed here.
elm-live ./src/Main.elm  --dir ./gh-pages --open --pushstate -p 8001  -- --output=./gh-pages/bundle.js
