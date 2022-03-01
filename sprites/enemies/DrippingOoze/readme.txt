MSX2 Sprite Converter 0.5
-------------------------

This tool has been created to convert Screen 5 MSX graphics to Sprite data.
The sprite converter analyses graphic data and converts them in the most efficient way (that is using the less possible amount of sprites). 

1) Installing the application.

Just unzip the archive in any folder. There is no specific DLL to install. 
However, DirectX needs to be present on the PC.

2) Launching the application.

Launch "sprconv.exe"
You will have to select a .GE5 file (age format) or .SC5 file. 
Any screen5 file in Bsave format will do.

3) Selecting sprites

3A) Normal mode: Just move the selection cursor over the 16*16 sprite you want to convert, select it and move it to the sprite-grid on the right side of the screen. The sprite will automatically be converted in the most “sprite efficient” way. The different sprite layers created will be displayed and also information about the mode selected.

The sprite different modes are:

1 sprite  (max 1 color / line)
2 sprites (max 3 colors / line with color "Or")
3 sprites (max 7 colors / line with color "Or")
4 sprites (max 15 colors / line with color "Or")

Note that if you want the application to make the best possible use of color "Or", and thus reduce the number of sprites, the color palette used should be optimized for it.

Up to 128 "Sprites" can be selected.

3B) Large sprite mode: Hold the Shift key down to switch to Large 
Sprite mode. In that mode, you can select area larger than 16*16. When dragging the selected area above the sprite-grid, the application will create series of 16*16 sprites automatically.

Right mouse button can be used to clear the sprite selection at any time (in either normal and large sprite mode).

4) Saving Sprites.

Click on the "Disk" Icon and enter a file name (without file extension but path can be specified). 

2 files will be created:

* "filename".log
A text file containing the commented sprite data, this file can be compiled.
The file contains graphic and color data for every sprite, as well as the palette data.

* "filename".spr

The equivalent binary file.

[Left Mouse Button] - Select sprite
[Right Mouse Button] - Clear sprite selection
[SHIFT] Switch to large sprite mode
[ESC]   Exit without saving
