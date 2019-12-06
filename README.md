# AGE - Abstract Game Engine 
AGE is an elm based 2d game engine to help you, developing your games as easy and comfortable as possible. 
AGE supports two levels of developing:

**1. High Level**

At this level, you don't need any developing experience, just your creativity. After you have chosen a genre ([platformer](https://en.wikipedia.org/wiki/Platform_game), [RPG](https://en.wikipedia.org/wiki/Role-playing_video_game), [SHMUP](https://en.wikipedia.org/wiki/Shoot_%27em_up), etc.) you can download a template suitable for [Tiled](https://www.mapeditor.org/).
With Tiled, you can start changing the template (gravity, AI patterns, graphics, animations, collision, etc.) to create your own game.


**2. Low Level**

"Low level" is for more experienced developers. Instead of starting from a template based on a genre, you start creating your individual genre. AGE provides you with a lot of different building blocks, which you can glue together to build your own game. Those blocks can be found in `lib/elm-logic-templates`. The `Top Down` example in `/lib/elm-logic-templates/src/Logic/Template/Game/TopDown.elm` was created with those building blocks.

## Get started and run some examples
To start, try to run some of the provided examples. To do that, make sure `node`, `npm`, `git`, `elm` and `elm-live` are installed on your machine. To check a installation, type `which {program-name}` in your terminal. For example, `which node` gives you back a path, when node is installed. If you don't see a path, the program is not installed. 

**1. Clone the git repository to your machine**

Open up your terminal and change to the folder, to which you want to clone the repo and run:

`git clone --recursive <https://github.com/justgook/platformer.git>`

To update an existing clone:
```
> cd platformer
> git pull
> git submodule update --init --recursive
```

**2. Initialize the git submodules and update them**

In your `/platformer` folder run this command:

`git submodule init && git submodule update`

**3. Run the examples** 

To run the examples, we recommend using `elm-live`. This way, the examples are not only built, but a dev server is also set up, and the game opens automatically in your browser. To run an example, use this command:

`elm-live examples/{folderName}/{fileName}.elm --dir ./gh-pages -o -p 8001  -- --output=./gh-pages/bundle.js`

Replace `{folderName}` and `{fileName}` accordingly. For example:

`elm-live examples/RPG/Debug.elm --dir ./gh-pages -o -p 8001  -- --output=./gh-pages/bundle.js`
