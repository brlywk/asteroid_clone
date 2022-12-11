# Just another Asteroid clone

This is my first foray into game development, and also my first usage of Godot (using version 4, because why not?).

I've created this to learn how to develop a simple game (Asteroids is a great start), so although I come from a software development background
and tried my best, some of the ways things are done in this project are probably not the best way to do things.

Some things that might be interesting (or not):
* All "graphics" are either shaders (backround shader taken and adapted from https://godotshaders.com/shader/star-nest/) or Line2D art
* Asteroid shapes are randomly generated and validated / adjusted using Godot's ConvexHull algorithm
* Looks of most graphical things can be adjusted in-game (via settings menu)
* Saves game settings and highscores
* I tried to use different methods to do things in different places, just to see how these things work, so don't be confused if the same thing is done in different ways throughout the code (it absolutely and definitely has nothing to do with not being consistent... cough cough)


## Godot Engine 4
Uses Godot Engine 4 (https://godotengine.org/license)


## License

__Please note that the explosion sounds used are licensed sounds, so I'm afraid these cannot be reused freely.
All other sounds (music, lasers) have been created by me, so feel free to use them as you see fit (attribution appreciated).__

Released under MIT license (see LICENSE.MD)
