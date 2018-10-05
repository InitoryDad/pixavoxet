# PixaVoxet

​This is a little tool inside the Godot game engine, made for rendering pixel art spritesheets from voxels models.  It features a custom lighting engine, outlining support/

# Voxel Modeller
Voxel modeller allows users to create, edit, and import images and MagicaVoxel models (https://ephtracy.github.io/) for use with the PixaVoxet system.

**Requirements**

Godot (https://godotengine.org/)

**Installation**

Import the project folder to Godot.

**PixaVoxet System:  Scene Setup**

To use the PixaVoxet system, first create or import a voxel model using the Voxel Modeller tab, save the model and it will be exported as a scene in the voxel_models folder.

Add the voxel model scenes to your currently open scene.

Add the scene "PixaVoxetSystem.tscn" in the addons folder

Right-Click PixaVoxet node and select "Discard Instancing" to access it's child nodes

Save and reload the scene for the voxel lighting engine to work.

**Animation**

Animation uses Godot's built in Animation timeline, which allows you to key any exposed property in the inspector dialog.  In order to bring up the animation timeline, select the AnimationPlayer that PixaVoxet is packaged with, once selected a small key symbol will appear next to properties of any subsequently selected node, which allows you to key the value in the timeline.

**Frame by Frame Playback**

PixaVoxet comes coupled with a frame by frame toolbar, as Godot's animation timeline does not work frame by frame, the frame by frame toolbar modifies playback to allow for frames to be played every 1 sec resulting in a frame by frame playback.

**Rendering Spritesheets**

The frame by frame toolbar has a render button, for automatically rendering spritesheets to a folder named "render" (default) in the project folder.  Spritesheets are optimized to be rendered in squares rather than strips at this point.

**Voxel Model Roots**

An imported scene created from the Voxel Modeller are to be considered Voxel Model Roots.  They can contain any number of Voxel Model children, but will only show the selected model chosen in the property Model Index.

**Curve Deformation**

You can add Position3D nodes to any Voxel Model, a chain of 2 or more will deform the voxel model along the curve created between the Position3D nodes.  Additionally, the first two nodes added to any Position3D, will set in and out points.

Voxel Model Roots have a property "Path Length Limit Multiplier" which limits the stretch of a voxel model.  It's calculation is based on the y height of the voxel model * path_length_limit_multiplier.

**Curve Scaling**

Changing the scaling on a Position3D node, will scale the voxels between points.


**Frame Size**

To change the size of the frame, set the Frame Size property located in the FramePreview node.  A box will be displayed eminating from the camera position as a helpful guide for animating within the camera bounds.
