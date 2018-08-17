# PixaVoxet

​This is a little tool inside the Godot game engine, made for rendering pixel art spritesheets from voxels models from the voxel modelling software MagicaVoxel.  It features a custom lighting engine, outlining support, and indexed colors.  

Devlog at http://myskamyska.tumblr.com

**Requirements**

Godot (https://godotengine.org/)

MagicaVoxel (https://ephtracy.github.io/)

**Installation**

Import the project folder to Godot.

**Key commands**

Tab - Update Voxel Models, used for when paths to .vox files are changed, or model indexes are changed

**Things to Know**

To change the size of the canvas, you need to set the Size variables identical to eachother inside the following nodes:

- Sideview / Isometric (Camera class)

- Viewport

If Sideview.size is 32, then Viewport.size is (32,32)

Indexed Colors works like this currently: cast shadows are 2 indexes to the right of the base color, shadows are 1 index, lit voxels is the base color.

There are  some variables that only do something if your settings allow for it, for instance most of the lighting variables won’t affect the rendered image with Indexed Colors checked.

If things breakdown from tinkering with code, check to see if the Light variable in the Spatial node is set, as well as if the paths to the .vox files are set.  Variables will reset to their default values if the scripts break inside Godot.
