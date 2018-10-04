# PixaVoxet

​This is a little tool inside the Godot game engine, made for rendering pixel art spritesheets from voxels models.  It features a custom lighting engine, outlining support, and indexed colors.  

# Voxel Modeller:
Voxel modeller allows users to create, edit, and import images and MagicaVoxel models (https://ephtracy.github.io/) for use with the PixaVoxet system.

**Requirements**

Godot (https://godotengine.org/)

**Installation**

Import the project folder to Godot.

**PixaVoxet System:  Scene Setup**

To use the PixaVoxet system, first create or import a voxel model using the Voxel Modeller tab, save the model and it will be exported as a scene in the voxel_models folder.

Add the scene to your currently open scene.
Add the scene "voxel_light_source.tscn"
Save and reload the scene for the voxel lighting engine to work.

Add the scene "frame_preview.tscn"
Right-Click and select "Discard Instancing"

**Curve Deformation**
You can add Position3D nodes to any Voxel Model, a chain of 2 or more will deform the voxel model along the curve created between the Position3D nodes.  Additionally, the first two nodes added to any Position3D, will set in and out points.

**Curve Scaling**
Changing the scaling on a Position3D node, will scale the voxels between points.


**Frame Size**

To change the size of the frame, you need to set the Size variables identical to eachother inside the following nodes:

- Sideview (Camera class)
- Viewport

If Sideview.size is 32, then Viewport.size is (32,32)
