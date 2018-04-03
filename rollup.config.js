import commonjs from 'rollup-plugin-commonjs'
import elm from 'rollup-plugin-elm'
import resolve from 'rollup-plugin-node-resolve'
import uglify from 'rollup-plugin-uglify'

import replaceHtmlVars from './rollup-forks/rollup-plugin-replace-html-vars'
import copy from './rollup-forks/rollup-plugin-copy'

const uglifyJSOptions = {
  sequences: true, // join consecutive statemets with the "comma operator"
  properties: true, // optimize property access: a["foo"] → a.foo
  dead_code: true, // discard unreachable code
  drop_debugger: true, // discard "debugger" statements
  drop_console: true,
  unsafe: false, // some unsafe optimizations (see below)
  conditionals: true, // optimize if-s and conditional expressions
  comparisons: true, // optimize comparisons
  evaluate: true, // evaluate constant expressions
  booleans: true, // optimize boolean expressions
  loops: true, // optimize loops
  unused: true, // drop unused variables/functions
  hoist_funs: true, // hoist function declarations
  hoist_vars: false, // hoist variable declarations
  if_return: true, // optimize if-s followed by return/continue
  join_vars: true, // join var declarations
  side_effects: true, // drop side-effect-free statements
  warnings: true, // warn about potentially dangerous optimizations/code
  global_defs: {}, // global definitions
  pure_funcs: ['F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'Math.floor', 'Math.pow', 'Math.min', 'Math.ceil'],
};

export default {
  input: 'src/index.js',
  output: {
    file: `dist/bundle.js`,
    format: 'cjs'
  },
  plugins: [
    copy({
      "production.html": "dist/index.html",
      "assets": "dist/assets",
      verbose: true
    }),
    replaceHtmlVars({
      files: 'dist/*.html',
      from: [/\${timestamp}/g, /\${subfolder}/g],
      to: [Date.now(), '.'],
    }),
    elm({
      // include: [],
      exclude: 'elm_stuff/**',
      // compiler: {
      //   // provides --debug to elm-make if enabled
      //   debug: false
      // }
    }),
    resolve({
      browser: true,
      preferBuiltins: false
    }),
    commonjs({
      extensions: ['.js', '.elm']
    }),
    uglify({
      ie8: false,
      ecma: 5,
      compress: uglifyJSOptions,
    }),

  ]
}


