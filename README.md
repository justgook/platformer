```
  elm make examples/${GAME}/Game.elm --optimize --output=./gh-pages/dist/${GAME}_bundle.js \
  && elm make "examples/${GAME}/Build.elm" --optimize --output=./gh-pages/dist/${GAME}_encoder.js \
  && jscodeshift -t transform.js ./gh-pages/dist/${GAME}_bundle.js \
  && uglifyjs ./gh-pages/dist/${GAME}_bundle.js --compress "pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters" --output=./gh-pages/dist/${GAME}_bundle.js \
  && prepack ./gh-pages/dist/${GAME}_bundle.js --inlineExpressions --out ./gh-pages/dist/${GAME}_bundle.js \
  && terser ./gh-pages/dist/${GAME}_bundle.js ./gh-pages/script.js --compress 'keep_fargs=false,unsafe_comps,unsafe' --mangle --output=./gh-pages/dist/${GAME}_bundle.js \
  && npx posthtml ./gh-pages/game.html -o ./gh-pages/dist/${GAME}.html -c posthtml.config.js \
  && if [ "$GAME_SOUNDS" != "" ]; then audiosprite --format howler2 --loop Background --output ./gh-pages/dist/${GAME} "${GAME_SOUNDS}/*.+(mp3|wav)" -u /; fi \
  && node build-assets.js \
  && if [ "$GAME_SOUNDS" != "" ]; then rm ./gh-pages/dist/${GAME}.json; fi
```
