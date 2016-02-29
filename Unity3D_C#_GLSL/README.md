# Parking lot visualization system
#### Licensed under MIT
###### Year: 2015
# 
This project was assigned in the fall 2015 to a student team I was a member in in Karelian University of Applied Sciences. The objective was to create a 3D representation of the campus parking lot area that
- mirrors the occupation of individual parking slots in (almost) real time
- can be made accessible on the Internet.

The tools were chosen based on lecturer suggestions and whatever past experience the team had: Unity3D (v5 supports WebGL builds) in C# and GLSL for WebGL-compatible image processing shaders. The exact Unity version we used was 5.2.2f1.

During the development, webcam installation the team was promised in the parking lot site never saw daylight, so we had to resort to still images and unprotected foreign parking lot camera streams a savvy googler may find online.

My responsibility areas in the project included
- creating a way to define parking slot areas in the source image, setting detection sensitivity and adding an option to save/restore definitions to/from a file
- coding GLSL shaders to process source image efficiently in GPU, through several processing steps, to eventually produce binary (B/W) edge detection data
- extraction of binary color information from processed images to determine reservation state of parking slots under observation
- adding visual components in the 3D scene to display processing stages for each chosen image source.

I've copyright-signed all source code files I've produced. You'll find them in Assets/Detection, Assets/Detection/Shaders and Assets/Editor subfolders.

To give the project a test run, Mac people should be fine as they are. On Windows, you'll need to explicitly start Unity in OpenGL mode: 
``` 
    "N:\PathToUnity\Unity.exe" -force-opengl
```
Please also take a look at Tekninen_dokumentti.pdf for technical details (in Finnish).