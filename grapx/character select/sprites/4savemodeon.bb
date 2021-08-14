AppTitle "MSX SPRITES CONVERTER 1.0"
;
; -----------------------------------------------------------------------------
; Event constants...
; -----------------------------------------------------------------------------
Const EVENT_None		= $0		; No event (eg. a WaitEvent timeout)
Const EVENT_KeyDown		= $101		; Key pressed
Const EVENT_KeyUp		= $102		; Key released
Const EVENT_ASCII		= $103		; ASCII key pressed
Const EVENT_MouseDown	= $201		; Mouse button pressed
Const EVENT_MouseUp		= $202		; Mouse button released
Const EVENT_MouseMove	= $203		; Mouse moved
Const EVENT_MouseEnter  = $205		; Mouse on a gadget
Const EVENT_Gadget		= $401		; Gadget clicked
Const EVENT_Move		= $801		; Window moved
Const EVENT_Size		= $802		; Window resized
Const EVENT_Close		= $803		; Window closed
Const EVENT_Front		= $804		; Window brought to front
Const EVENT_Menu		= $1001		; Menu item selected
Const EVENT_LostFocus	= $2001		; App lost focus
Const EVENT_GotFocus	= $2002		; App got focus
Const EVENT_Timer		= $4001		; Timer event occurred
;
Global mouse_x = 0
Global mouse_y = 0
Global sp_mode = 0
;
Global zoomwindow=CreateWindow("Zoom",500+40,00,100,100,0,16+2+1)
Global zoomcanvas = CreateCanvas (0, 0, ClientWidth (zoomwindow), ClientHeight (zoomwindow), zoomwindow)
SetMinWindowSize zoomWindow,100,100
SetGadgetLayout zoomcanvas,1,1,1,1
Global PalWindow=CreateWindow("Palette",800+40,140,200,200,0,16+2+1)
;
Global window=CreateWindow("MSX Sprites Converter 1.0",0,40,806,600,0,13)
menu = WindowMenu (window)
mainmenu = CreateMenu ("&Files", 0, menu)
CreateMenu "&Load", 1, mainmenu
CreateMenu "&Save", 2, mainmenu
CreateMenu "", 3, mainmenu
CreateMenu "E&xit", 4, mainmenu
settingsmenu = CreateMenu ("&Options", 5, menu)
Global SavingMode = CreateMenu ("Save GEN file",6,SettingsMenu)
Global dspZoom=CreateMenu("Display &Zoom",7,SettingsMenu)
CheckMenu SavingMode
CheckMenu dspZoom

;CheckMenu SavingMode

UpdateWindowMenu window;
Global canvas = CreateCanvas (0, 0, ClientWidth (window), ClientHeight (window), window)
SetBuffer CanvasBuffer (canvas)	
;
Global levelPath$ = "_levels\"
;
Dim Palette(15,3)								
Dim MSXPalette(15,2)								
Dim msximg (256,212) 							
Dim sprimg (16,16)
Dim tmparray(7)
Dim TGS_Rep(4,32,128)
Dim TCS_Rep(7,16,128)
Dim SprMode (128)
;
Global winspr = CreateImage(32,32,5)			; Display buffer for sprites
Global SpriteSelected = False
Global ISOnGrid = False
Global IsOnImage = False
Global xlspron = False
Global xlSpriteSelected = False
Global xlselectingspr = False
;
Dim color_used(16,16)							; colors used by the sprite
Dim tgs(4,32)									; tgs buffer
Dim tcs(7,16)									; tcs buffer
Global x,y
Global img       = CreateImage(512,424,1) 		; création d'un buffer de 256*212
Global souris    = CreateImage(32,32,1)
Global SelSprImg = CreateImage(256,544,1)
Global LargeSpr
Global sprmsg$ = ""
Global errmsg$ = ""
Global txtx$ = ""
Global txty$ = ""
Global SelSprX = 0
Global SelSprY = 0
Global XLSelSprX = 0
Global XLSelSprY = 0
Global XLsprW = 0
Global XLsprH = 0
Global SprNbr = 0
Global LastSprNbr = 0
;
SetBuffer ImageBuffer(souris,0)
Color 255,255,255
For x=0 To 7
    Plot x,0
	Plot 0,x
	Plot 31,31-x
	Plot 31-x,31
Next

For sp=0 To 127
    sprmode(sp) = 255
    For i=0 To 3
        For j = 0 To 32
            tgs_rep(i,j,sp) = 255
        Next
    Next
    For i = 0 To 7
        For j = 0 To 15
            tcs_rep(i,j,sp) = 255
        Next
    Next
Next    





RefreshGrid()
;


While Not KeyHit(1)
	e = WaitEvent (1) ; The 'wait' value comes from above section...
	Select e
	Case EVENT_Close
		If EventSource()=zoomWindow Then
   	   		HideGadget zoomWindow
			UncheckMenu dspZoom
			UpdateWindowMenu Window
       	EndIf 
		If EventSource()=window Then 
 		 	If Confirm ("Are you sure you want to quit?") Then 	End
		EndIf
	Case EVENT_Menu
 		 item = EventData ()
		 Select item
				Case 1
					SFile$ = RequestFile("Select GE5 File to convert","sc5,ge5",False);fileselect$(CurrentDir$()+levelPath$,".GE5:.SC5","Load a File")
					If sfile$<>"" Then Read_ge5(sfile$)
				Case 2
					sFile$ = RequestFile("Save tgs file","tgs",True)
					If sfile$<>"" Then save_spr(fileWithoutExt(sFile$))
				Case 4
					If Confirm ("Are you sure you want to quit?") Then 	End
				Case 6
					If MenuChecked(SavingMode) Then
						UncheckMenu savingmode
						Else
						CheckMenu savingmode
					EndIf					
					UpdateWindowMenu window;
				Case 7
					If MenuChecked(dspZoom) Then
						UncheckMenu dspZoom
						HideGadget zoomWindow
							Else
						CheckMenu dspZoom
						ShowGadget zoomWindow
					EndIf
					UpdateWindowMenu window										
		End Select			
	End Select
    mouse_x = MouseX(canvas) And 65534
	mouse_y = MouseY(canvas) And 65534
	IsOnGrid = False
	IsOnImage = False
	xlspron = KeyDown(42)
	If Not xlspron Then xlselectingspr = False
	txtx$ = "X: "+Str(mouse_x/2)
	txty$ = "Y: "+Str(mouse_y/2) 
	If (mouse_x>=512+32) And (mouse_y<512) Then 
	   IsOnGrid = True
	   mouse_x = mouse_x And 65504
	   mouse_y = mouse_y And 65504
	   sprnbr = ((mouse_x-544) /32) + (mouse_y /4)
	   txtx$ = "Sprite:"+Str(sprnbr)
       txty$ = ""
	   sprmsg$=spritemode$(sprmode(sprnbr))
	Else 
	   sprmsg$=spritemode$(sp_mode)
	End If
	If (Mouse_X <512) And (Mouse_y<424) Then
	   IsOnImage = True
	EndIf
	gest_click()
	Refresh_Screen()
	If MenuChecked(dspZoom) Then ActivateGadget(zoomWindow)
Wend 


Function gest_click()
button = GetMouse()
If (button = 1) And (mouse_x<=512-32) And (mouse_y<=424-32) And (Not xlspron) Then 
   errmsg$=""
   sprmsg$=""
   CopyRect mouse_x,mouse_y,32,32,0,0,ImageBuffer(img),ImageBuffer(souris)
   SetBuffer ImageBuffer(souris,0)
   Color 255,255,255
   For x=0 To 7
     Plot x,0
	 Plot 0,x
	 Plot 31,31-x
	 Plot 31-x,31
   Next
   For i = 0 To 15
       For j = 0 To 15
	   sprimg(i,j) = msximg((mouse_x/2)+i,(mouse_y/2)+j)	       
       Next
   Next
   sp_mode = sprite_mode()
   sprmsg$=spritemode$(sp_mode)
   Select sp_mode
   Case 1
        sprite_convert_mode2_3()

        SpriteSelected = True
   Case 2
        sprite_convert_mode2_3()
        SpriteSelected = True
   Case 3
        sprite_convert_mode2_3()
        SpriteSelected = True
   Case 4
        sprite_convert_mode4_5()
        SpriteSelected = True
   Case 5
        sprite_convert_mode4_5()
        SpriteSelected = True
   Case 6
        sprite_convert_mode6()
        SpriteSelected = True
   Default
		SpriteSelected = False
		resetcursor()
   End Select
   If SpriteSelected Then
      SelSprX = Mouse_X
      SelSprY = Mouse_Y
   EndIf
End If

If (button = 1) And (IsOnImage) And (xlspron) Then 
   errmsg$=""
   sprmsg$=""
   If Not xlselectingspr Then
      XLSelsprx = mouse_x
      XLSelspry = mouse_y 
      xlselectingspr=True
      Else
      If mouse_x<XLselsprx Then 
         xs = mouse_x
	   Else
         xs = XLselsprx
       EndIf
	  If mouse_y<XLselspry Then 
	       ys = mouse_y
	   Else
	       ys = XLselspry
	  EndIf	
	  xlsprW = Abs(mouse_x-XLselsprx)
	  XLsprH = Abs(mouse_y-XLselspry)
	  If (xlsprw>0) And (xlsprh>0) Then
	     xlsprW = xlsprW+2
	     xlsprh = xlsprH+2 
         largespr = CreateImage(xlsprw,xlsprh,1)
         CopyRect xs,ys,XLsprW,XLsprH,0,0,ImageBuffer(img),ImageBuffer(largespr)
         xlselectingspr = False  
         xlspriteselected=True 
         XLselsprx=xs
         XLselspry=ys     
      Else
         xlselectingspr = False
      EndIf
   EndIf  
EndIf

If (button = 1) And (isongrid) And (xlspron) And (xlspriteselected) Then
   errmsg$=""
   sprmsg$=""
   bigspritetogrid()
   xlspriteselected = False
EndIf

If (button = 1) And (IsOnGrid) And (SpriteSelected) And (sp_mode >= 1) And (sp_mode <=6) Then
   errmsg$="" 
   sprmsg$=""
   SpriteSelected = False
   CopyRect SelSprX,SelSprY,32,32,mouse_x-544,mouse_y,ImageBuffer(Img),ImageBuffer(SelSprImg)
   sprmsg$= "                                    "
   For i=0 To 3
       For j = 0 To 31
           TGS_Rep(i,j,sprnbr) = tgs (i,j)
       Next
   Next
   For i = 0 To 7
       For j = 0 To 15
           tcs_Rep(i,j,sprnbr) = tcs(i,j) 
       Next
   Next
   sprmode(sprnbr) = sp_mode
   resetcursor()
   refreshgrid()
EndIf

If (button = 2)  Then
   If (xlspron) Then
     If (xlspriteselected) Then FreeImage largespr
     xlselectingspr = False
     xlspriteselected = False
     errmsg$=""
	 sprmsg$=""
   Else
     errmsg$=""
	 sprmsg$=""
     SpriteSelected = False
     sp_mode = 0
     resetcursor()
   EndIf; endif xlspron
   If isongrid Then
	  For g = 0 To 3
        SetBuffer ImageBuffer(SelSprImg,0)
        Color 0,0,0
        For y = mouse_y To mouse_y + 31
    	    For x = mouse_x-544 To mouse_x - 544 + 31
		        Plot x,y
		    Next
	    Next	          
	  Next
        refreshgrid()	
        sprmode(sprnbr) = 255
        For i=0 To 3
            For j = 0 To 32
               tgs_rep(i,j,sprnbr) = 255
            Next
        Next
        For i = 0 To 7
            For j = 0 To 15
                tcs_rep(i,j,sprnbr) = 255
            Next
        Next
     EndIf; endif isongrid
EndIf
SetBuffer CanvasBuffer (canvas)	
;SetBuffer BackBuffer()
End Function

;
; BIG SPRITE TO GRID
;
Function bigspritetogrid()
SetBuffer ImageBuffer(SelSprImg,0)        
errmsg$=""
For spy = 0 To XLsprH-1 Step 32
    For spx = 0 To XLsprW-1 Step 32
        clearspr()
        If (xlsprw-(spx+32)) >= 0 Then
           w = 32
           Else
           w = xlsprw-spx
        EndIf
        If (xlsprh-(spy+32)) >= 0 Then
           h = 32
           Else
           h = xlsprh-spy
        EndIf
        CopyRect XLSelSprX+spx,XLSelSprY+spy,w,h,getxspr()-544,getyspr(),ImageBuffer(Img),ImageBuffer(SelSprImg)        
        For i = 0 To 15
            For j = 0 To 15
            If (j<=(h/2)) And (i<=(w/2)) Then 
               sprimg(i,j) = msximg(((XLSelSprX+spx)/2)+i,((XLSelSprY+spy)/2)+j)
               Else
               sprimg(i,j) = 0
            EndIf
            Next
        Next
	sp_mode = sprite_mode()
	Select sp_mode
	Case 1
        sprite_convert_mode2_3()

	Case 2
        sprite_convert_mode2_3()
	Case 3
        sprite_convert_mode2_3()
	Case 4
        sprite_convert_mode4_5()
	Case 5
        sprite_convert_mode4_5()
	Case 6
        sprite_convert_mode6()
	Default
	End Select
	For i=0 To 3
    	For j = 0 To 31
        	TGS_Rep(i,j,sprnbr) = tgs (i,j)
	    Next
	Next
	For i = 0 To 7
    	For j = 0 To 15
        	tcs_Rep(i,j,sprnbr) = tcs(i,j)
    	Next
	Next
	sprmode(sprnbr) = sp_mode
    sprnbr=sprnbr+1
    Next
Next
sprmsg$= "                                    "
FreeImage largespr
refreshgrid()	
End Function


Function clearspr()
sx = getxspr()-544
sy = getyspr()
Color 10,0,0
For i=0 To 31
    For j=0 To 31
        Plot sx+i,sy+j
    Next
Next
End Function

Function RefreshGrid()
SetBuffer ImageBuffer(SelSprImg,0)
Color 255,255,255
For y=0 To 512+32 Step 32
    For x = 0 To 256 Step 32
        Plot x,y
    Next
Next
End Function

Function getXspr()
Return 544+((sprnbr Mod 8)*32)
End Function

Function getYspr()
Return Int(sprnbr / 8)*32
End Function



Function resetcursor()
SetBuffer ImageBuffer(souris,0)
Color 0,0,0
For y=0 To 31
       For x=0 To 31
		   Plot x,y
	   Next
Next
Color 255,255,255
   For x=0 To 7
     Plot x,0
	 Plot 0,x
	 Plot 31,31-x
	 Plot 31-x,31
Next
End Function

;
; Refresh the screen
;
Function Refresh_Screen()
	SetBuffer CanvasBuffer (canvas)	
	Color 0,0,0
	Cls
	DrawBlock img,0,0
    DrawBlock SelSprImg,512+32,0	
	If xlspron Then 
		ShowPointer canvas
		Else
		If (MouseY()-GadgetY(window))>=50 Then HidePointer canvas
	EndIf
	If (xlspron) And (Not xlspriteselected) Then
	   Color 255,255,255
	   Plot mouse_x,mouse_y
	EndIf
    If xlspron And xlspriteselected Then DrawBlock largespr,mouse_x,mouse_y	
	If Not xlspron Then
        If SpriteSelected Then
     		 DrawBlock souris,mouse_x,mouse_y	
 	   	     Else
             DrawImage souris,mouse_x,mouse_y
		EndIf
	EndIf
	If (xlspron) And (xlselectingspr) And (isonimage) Then 
	   If mouse_x<XLselsprx Then 
	      xs = mouse_x
	      Else
	      xs = XLselsprx
	   EndIf
	   If mouse_y<xlselspry Then 
	      ys = mouse_y
	      Else
	      ys = xlselspry
	   EndIf	
	   txtw$ = "W: "+Str(1+Abs(mouse_x-XLselsprx)/2)
	   txth$ = "H: "+Str(1+Abs(mouse_y-XLselspry)/2)	
	   Color 255,255,255
	   Rect xs,ys,Abs(mouse_x-XLselsprx)+2,Abs(mouse_y-XLselspry)+2,0
	EndIf
	If isongrid Then
	    clearwinspr()
	    dspspr()
		SetBuffer CanvasBuffer (canvas)	
	    DrawImage winspr,10,450,0
	    DrawImage winspr,50,450,1
	    DrawImage winspr,90,450,2
	    DrawImage winspr,130,450,3	
	    DrawImage winspr,170,450,4
	EndIf
	For i=0 To 15
		Color 255,255,255
		Text 10+(i*16),490,i
	    Color palette(i,0),palette(i,1),palette(i,2)
		Rect 10+(i*16),510,15,15
	Next
	If (Not spriteselected) And (Not isongrid) Then sprmsg$=""
	txtbar$=txtx$+" - "+txty$+" - "+sprmsg$
	If (xlspron) And (xlselectingspr) Then txtbar$=txtbar$+" - "+txtw$+" - "+txth$	
	SetStatusText window,txtbar$
	SetBuffer CanvasBuffer(zoomCanvas)
	Cls
	CopyRect mouse_x-25,mouse_y-25,100,100,0,0,CanvasBuffer(canvas)
	FlipCanvas zoomCanvas	
	VWait												
	FlipCanvas canvas	
End Function

;
; Read .GE5 file
;
Function Read_GE5(filename$)
file = OpenFile(filename$) 				    
	SeekFile( file, 7 + 30336) 						
	For c = 0 To 15
		Byte_RB = ReadByte(file)					
		Byte_G=ReadByte(file)						
		Palette (c,0)= (Byte_RB And 240)*2			
		Palette (c,1)= (Byte_G And 15)*32			
		Palette (c,2)= (Byte_RB And 15)*32			
	Next
	CloseFile(file)									
file = OpenFile (filename$)
;skip header
SeekFile(file,7)
SetBuffer ImageBuffer(img,0) 		
For y=0 To 211
    For x=0 To 127
	    pixels = ReadByte(file)
	    colora = (pixels And 240)/16
	    colorb = (pixels And 15)
		msximg(x*2,y)     = Colora
		msximg((x*2)+1,y) = colorb
	    Color palette(colora,0),palette(colora,1),palette(colora,2)
	    Plot x*4,Y*2
	    Plot (x*4)+1,Y*2	
	    Plot x*4,(Y*2)+1
	    Plot (x*4)+1,(Y*2)+1		
	    Color palette(colorb,0),palette(colorb,1),palette(colorb,2)
	    Plot (x*4)+2,y*2
	    Plot (x*4)+3,y*2	
	    Plot (x*4)+2,(y*2)+1
	    Plot (x*4)+3,(y*2)+1		
    Next
Next
End Function

;
; Clear Winspr
;
Function clearwinspr()
For i = 0 To 3
 SetBuffer ImageBuffer(winspr,i) 
 Color 255,255,255
 Rect 0,0,32,32,1
Next
End Function
;
; Write sprite data
;
Function Save_Spr(filename$)
; Write tgs & tcs
tgsfile    = WriteFile(filename$+".tgs") 	
tcsfile    = WriteFile(filename$+".tcs") 	
If MenuChecked(SavingMode) Then tgsgenfile    = WriteFile(filename$+".tgs.gen") 	
If MenuChecked(SavingMode) Then tcsgenfile    = WriteFile(filename$+".tcs.gen") 	
For i = 0 To 127
	spmode=sprmode(i)
	If (spmode<>255) Then
		nbspr=spritecount(spmode)
		If MenuChecked(SavingMode) Then WriteLine (tgsgenfile,"; Sprite "+Str(i)+" - "+spritemode$(spmode))
		If MenuChecked(SavingMode) Then WriteLine (tcsgenfile,"; Sprite "+Str(i)+" - "+spritemode$(spmode))
		For j = 0 To nbspr -1
			;write tgs
			For y=0 To 31
				WriteByte(tgsfile,tgs_rep(j,y,i))
				If MenuChecked(SavingMode) Then WriteLine (tgsgenfile,"  db "+Str(tgs_rep(j,y,i)))				
			Next		
			;write tcs
			For y=0 To 15
				WriteByte(tcsfile,tcs_rep(j,y,i) Or 64)

				If j<>0 Then If MenuChecked(SavingMode) Then WriteLine (tcsgenfile,"  db "+Str(tcs_rep(j,y,i) Or 64))					
				If j=0 Then If MenuChecked(SavingMode) Then WriteLine (tcsgenfile,"  db "+Str(tcs_rep(j,y,i) ))					

			Next
		Next
	EndIf
Next
CloseFile(tgsfile)
CloseFile(tcsfile)
If MenuChecked(SavingMode) Then CloseFile(tgsgenfile)
If MenuChecked(SavingMode) Then CloseFile(tcsgenfile)
End Function

;
; Return the sprite mode as text
;
Function spritemode$(sp)
Select sp
	Case 1
  	Return "Mode : 1 sprite               "
	Case 2
   	Return "Mode : 2 sprites, color OR off"
    Case 3
   	Return "Mode : 2 sprites, color OR on "
    Case 4 
  	Return "Mode : 3 sprites, color OR off"
	Case 5
    Return "Mode : 3 sprites, color OR on "
    Case 6 
    Return "Mode : 4 sprites"
    Default
   	Return " "
End Select
End Function


Function spritecount(sp)
Select sp
	Case 1
   	Return 2
	Case 2
   	Return 2
    Case 3
    Return 2
    Case 4
   	Return 3
    Case 5
   	Return 3
    Case 6 
    Return 4
    Default
   	Return -1
End Select
End Function

Function sprite_mode()
max_color_mode = -1
For y=0 To 15
    For i = 0 To 15
        color_used (i,y) = 255
    Next
    color_mode = 0
    countcol=0
    For x=0 To 15
        a=sprimg(x,y)
	    If (a<>0) And (Not findcolor(a)) Then 
           addcolor(a)
           countcol = countcol+1
        End If
    Next
    sort_colors()
    If (countcol>15) Then 
       errormessage = "Too many colors used (max 7)"
       Return -1
    End If
    If (countcol = 0) Or (countcol=1) Then color_mode=3
    If (countcol = 2) Then color_mode = 3; 2 sprites, no Or'ing
    If (countcol = 3) Then 
       If color_used(2,y) = (color_used(0,y) Or color_used(1,y)) Then
          color_mode = 3; 2 sprites, Or'ing
          Else
          color_mode = 4; 3 sprites, no Or'ing
       End If
    End If
    If (countcol>=4) And (countcol<=7) Then
	if ismode5() then 
           color_mode=5; 3 sprites, Or'ing
	else
	   color_mode=6; 4 sprites, Or'ing
        endif
    End If
    If (countcol>7) Then color_mode = 6
    If (color_mode=0) Then 
       errormessage = "Invalid use of color."
       Return -1       
    End If
    If color_mode>Max_color_mode Then max_color_mode = color_mode
Next
Return max_color_mode
End Function

function ismode5()
;
; Set the 3 first colors as baseline
;
For i=0 To 7 
    tmparray(i) = color_used(i,y)
next
If tmparray(2) = tmparray(0) Or  tmparray(1) Then
   For i=2 To 6
       tmparray(i) = tmparray(i+1)
       countcol = countcol - 1
   next
end if
countspr=3
for i = 3 to 7
    foundcol = false
    If (tmparray(i)=255) Or  (tmparray(i) = tmparray(0) Or tmparray(1)) Then foundcol = True
    If (tmparray(i)=255) Or  (tmparray(i) = tmparray(0) Or tmparray(2)) Then foundcol = True
    If (tmparray(i)=255) Or  (tmparray(i) = tmparray(1) Or tmparray(2)) Then foundcol = True
    If (tmparray(i)=255) Or  (tmparray(i) = tmparray(1) Or tmparray(2) Or tmparray(3)) Then foundcol = True
    if not foundcol then countspr = countspr +1
Next 
Return (countspr = 3)
End Function

;
; Return true if a color is found in an array
;
Function findcolor(scolor)
fcolor = False
For i=0 To 15
    If color_used(i,y) = scolor Then fcolor=True
Next
Return fcolor
End Function

;
; Add color to an array
;
Function addcolor(scolor)
For i = 0 To 15
    If (color_used(i,y) = 255) Then 
        color_used(i,y) = scolor
        Exit
	EndIf
Next
End Function

;
; Sort colors
;
Function sort_colors()
For i = 0 To 15
    For j= 0 To 15
        If (color_used(i,y)<Color_used(j,y)) Then
		   tmpcol = color_used(j,y)
		   Color_used(j,y) = color_used(i,y)
		   color_used(i,y) = tmpcol 	
        EndIf
    Next
Next
End Function


;
; Find color in TCS
;
Function findtcscol(scolor)
fcolor = False
For i=0 To 6
    If tcs(i,y) = scolor Then fcolor=True
Next
Return fcolor
End Function

;
; Sort TCS Colors
;
Function sort_tcs()
For i = 0 To 6
    For j= 0 To 6
        If (tcs(i,y)<tcs(j,y)) Then
		   tmpcol = tcs(j,y)
		   tcs(j,y) = tcs(i,y)
		   tcs(i,y) = tmpcol 	
        EndIf
    Next
Next
End Function
;
; Sprite convert (1 sprite)
; 
Function sprite_convert_mode1()
For y=0 To 15
    tcs(0,y)=255
    tgs(0,y)=0
    tgs(0,y+16)=0	
    For x=0 To 7
        If sprimg(x,Y) <> 0 Then
	       tcs(0,y) = sprimg(x,y)
	       tgs(0,y) = tgs(0,y) Or (2^(7-x))
        End If
        If sprimg(x+8,Y) <> 0 Then
	       tcs(0,y) = sprimg(x,y)
	       tgs(0,y+16) = tgs(0,y+16) Or (2^(7-x))
        End If
    Next
Next
End Function
;
; Sprite convert (2 sprites)
;
Function sprite_convert_mode2_3()
For y=0 To 15
	For x=0 To 6
        tcs(x,y)=255
    Next
    tgs(0,y)=0
    tgs(0,y+16)=0	
    tgs(1,y)=0
    tgs(1,y+16)=0	
    nbcol = 0
    For x=0 To 15
	; set tcs
	    dbc=sprimg(x,y)
        If (sprimg(x,y)<>0) And (Not findtcscol(sprimg(x,y))) Then
           tcs(nbcol,y) = sprimg(x,y)
           nbcol = nbcol + 1
        End If
    Next
;	If (nbcol=1) Then tcs(1,y)=tcs(0,y)
    sort_tcs()
    For x=0 To 7
	; set tgs
        If sprimg(x,Y) = tcs(0,y)  Then
	       tgs(0,y) = tgs(0,y) Or (2^(7-x))
        End If
        If sprimg(x+8,Y) = tcs(0,y) Then
	       tgs(0,y+16) = tgs(0,y+16) Or (2^(7-x))
        End If
        If sprimg(x,Y) = tcs(1,y)  Then
	       tgs(1,y) = tgs(1,y) Or (2^(7-x))
        End If
        If sprimg(x+8,Y) = tcs(1,y) Then
	       tgs(1,y+16) = tgs(1,y+16) Or (2^(7-x))
        End If
        If sprimg(x,Y) = tcs(2,y)  Then
	       tgs(0,y) = tgs(0,y) Or (2^(7-x))
	       tgs(1,y) = tgs(1,y) Or (2^(7-x))
        End If
        If sprimg(x+8,Y) = tcs(2,y) Then
	       tgs(0,y+16) = tgs(0,y+16) Or (2^(7-x))
	       tgs(1,y+16) = tgs(1,y+16) Or (2^(7-x))
        End If 
    Next
Next
End Function

;
; Sprite convert (3 sprites)
;
Function sprite_convert_mode4_5()
For y=0 To 15
    For x=0 To 7
        tcs(x,y)=255
    Next
    tgs(0,y)=0
    tgs(0,y+16)=0	
    tgs(1,y)=0
    tgs(1,y+16)=0	
    tgs(2,y)=0
    tgs(2,y+16)=0	
    nbcol = 0	
    For x=0 To 15
	; set tcs
        If (sprimg(x,y)<>0) And (Not findtcscol(sprimg(x,y))) Then
           tcs(nbcol,y) = sprimg(x,y)
           nbcol = nbcol + 1
        End If
    Next
    sort_tcs()
	If tcs(2,y) = (tcs(0,y) Or tcs(1,y)) Then
      For i=2 To 6
       tcs(i,y) = tcs(i+1,y)
      Next
    End If
    For x=0 To 7
		; set tgs
        ; for color 0
        If sprimg(x,Y) = tcs(0,y)  Then
	       tgs(0,y) = tgs(0,y) Or (2^(7-x))
        End If
        If sprimg(x+8,Y) = tcs(0,y) Then
	       tgs(0,y+16) = tgs(0,y+16) Or (2^(7-x))
        End If

        ; for color 1
        If sprimg(x,Y) = tcs(1,y)  Then
	       tgs(1,y) = tgs(1,y) Or (2^(7-x))
        End If
        If sprimg(x+8,Y) = tcs(1,y) Then
	       tgs(1,y+16) = tgs(1,y+16) Or (2^(7-x))
        End If

        ; for color 2
        If sprimg(x,Y) = tcs(2,y)  Then
	       tgs(2,y) = tgs(2,y) Or (2^(7-x))
        End If
        If sprimg(x+8,Y) = tcs(2,y) Then
	       tgs(2,y+16) = tgs(2,y+16) Or (2^(7-x))
        End If 
	    ; for (color 0) OR (color 1)
    	If sprimg(x,y) = (tcs(0,y) Or tcs(1,y)) Then
	       tgs(0,y) = tgs(0,y) Or (2^(7-x))
	       tgs(1,y) = tgs(1,y) Or (2^(7-x))
        End If
        If sprimg(x+8,Y) = (tcs(0,y) Or tcs(1,y)) Then
	       tgs(0,y+16) = tgs(0,y+16) Or (2^(7-x))
	       tgs(1,y+16) = tgs(1,y+16) Or (2^(7-x))
        End If 
	    ; for (color 0) OR (color 2)
     	If sprimg(x,y) = (tcs(0,y) Or tcs(2,y)) Then
	       tgs(0,y) = tgs(0,y) Or (2^(7-x))
	       tgs(2,y) = tgs(2,y) Or (2^(7-x))
        End If
        If sprimg(x+8,Y) = (tcs(0,y) Or tcs(2,y)) Then
	       tgs(0,y+16) = tgs(0,y+16) Or (2^(7-x))
	       tgs(2,y+16) = tgs(2,y+16) Or (2^(7-x))
        End If 
	    ; for (color 1) OR (color 2)
	    If sprimg(x,y) = (tcs(1,y) Or tcs(2,y)) Then
	       tgs(1,y) = tgs(1,y) Or (2^(7-x))
	       tgs(2,y) = tgs(2,y) Or (2^(7-x))
        End If
        If sprimg(x+8,Y) = (tcs(1,y) Or tcs(2,y)) Then
	       tgs(1,y+16) = tgs(1,y+16) Or (2^(7-x))
	       tgs(2,y+16) = tgs(2,y+16) Or (2^(7-x))
        End If 
	    ; for (color 0) OR (color 1) or (color 2)
	    If sprimg(x,y) = (tcs(0,y) Or tcs(1,y) Or tcs(2,y)) Then
	       tgs(0,y) = tgs(0,y) Or (2^(7-x))
	       tgs(1,y) = tgs(1,y) Or (2^(7-x))
	       tgs(2,y) = tgs(2,y) Or (2^(7-x))
        End If
        If sprimg(x+8,Y) = (tcs(0,y) Or tcs(1,y) Or tcs(2,y)) Then
	       tgs(0,y+16) = tgs(0,y+16) Or (2^(7-x))
	       tgs(1,y+16) = tgs(1,y+16) Or (2^(7-x))
	       tgs(2,y+16) = tgs(2,y+16) Or (2^(7-x))
        End If 
    Next
Next
End Function

;
; Sprite convert (3 sprites)
;
Function sprite_convert_mode6()
For y=0 To 15
	For x=0 To 6
        tcs(x,y)=255
    Next
    tgs(0,y)=0
    tgs(0,y+16)=0	
    tgs(1,y)=0
    tgs(1,y+16)=0	
    tgs(2,y)=0
    tgs(2,y+16)=0	
    tgs(3,y)=0
    tgs(3,y+16)=0	
    For x=0 To 15
	; set tcs
        tcs(0,y) = 1
		tcs(1,y) = 2
		tcs(2,y) = 4
		tcs(3,y) = 8
    Next
	;Stop
    For x=0 To 7
		For l=0 To 3
		    If ((sprimg(x,y) And (2^l))) Then tgs(l,y) = tgs(l,y)  Or (2^(7-x))
		    If ((sprimg(x+8,y) And (2^l))) Then tgs(l,y+16) = tgs(l,y+16)  Or (2^(7-x))		
		Next 
	Next
Next 
End Function


Function setwinspr(nbspr)
If nbspr>=1 Then
   SetBuffer ImageBuffer(winspr,0)
   For y=0 To 15
    tcsval = tcs(0,y)
    If (tcsval>15) Then tcsval = 0
    Color palette(tcsval,0),palette(tcsval,1),palette(tcsval,2)
    For x=0 To 7
        If (tgs(0,y) And (2^x)) Then Rect (7-x)*2,y*2,2,2
        If (tgs(0,y+16) And (2^x)) Then Rect (15-x)*2,y*2,2,2
    Next
   Next
EndIf
If nbspr>=2 Then
   SetBuffer ImageBuffer(winspr,1)
   For y=0 To 15
    tcsval = tcs(1,y)
    If (tcsval>15) Then tcsval = 0
    Color palette(tcsval,0),palette(tcsval,1),palette(tcsval,2)
    For x=0 To 7
        If (tgs(1,y) And (2^x)) Then Rect (7-x)*2,y*2,2,2
        If (tgs(1,y+16) And (2^x)) Then Rect (15-x)*2,y*2,2,2
    Next
   Next
EndIf
If nbspr>=3 Then
   SetBuffer ImageBuffer(winspr,2)
   For y=0 To 15
    tcsval = tcs(2,y)
    If (tcsval>15) Then tcsval = 0
    Color palette(tcsval,0),palette(tcsval,1),palette(tcsval,2)
    For x=0 To 7
        If (tgs(2,y) And (2^x)) Then Rect (7-x)*2,y*2,2,2
        If (tgs(2,y+16) And (2^x)) Then Rect (15-x)*2,y*2,2,2
    Next
   Next
EndIf
If nbspr>=4 Then
   SetBuffer ImageBuffer(winspr,3)
   For y=0 To 15
    tcsval = tcs(3,y)
    If (tcsval>15) Then tcsval = 0
    Color palette(tcsval,0),palette(tcsval,1),palette(tcsval,2)
    For x=0 To 7
        If (tgs(3,y) And (2^x)) Then Rect (7-x)*2,y*2,2,2
        If (tgs(3,y+16) And (2^x)) Then Rect (15-x)*2,y*2,2,2
    Next
   Next
EndIf
End Function

;--------------------------------------------------------------
; Dspspr
;--------------------------------------------------------------
Function dspSpr()
spmode=sprmode(sprnbr)
 nbspr=spritecount(spmode)
 If nbspr>=1 Then
   SetBuffer ImageBuffer(winspr,0)
   For y=0 To 15
    tcsval = tcs_rep(0,y,sprnbr)
    If (tcsval>15) Then tcsval = 0
    Color palette(tcsval,0),palette(tcsval,1),palette(tcsval,2)
    For x=0 To 7
        If (tgs_rep(0,y,sprnbr) And (2^x)) Then Rect (7-x)*2,y*2,2,2
        If (tgs_rep(0,y+16,sprnbr) And (2^x)) Then Rect (15-x)*2,y*2,2,2
    Next
   Next
 EndIf
 If nbspr>=2 Then
   SetBuffer ImageBuffer(winspr,1)
   For y=0 To 15
    tcsval = tcs_rep(1,y,sprnbr)
    If (tcsval>15) Then tcsval = 0
    Color palette(tcsval,0),palette(tcsval,1),palette(tcsval,2)
    For x=0 To 7
        If (tgs_rep(1,y,sprnbr) And (2^x)) Then Rect (7-x)*2,y*2,2,2
        If (tgs_rep(1,y+16,sprnbr) And (2^x)) Then Rect (15-x)*2,y*2,2,2
    Next
   Next
 EndIf
 If nbspr>=3 Then
   SetBuffer ImageBuffer(winspr,2)
   For y=0 To 15
    tcsval = tcs_rep(2,y,sprnbr)
    If (tcsval>15) Then tcsval = 0
    Color palette(tcsval,0),palette(tcsval,1),palette(tcsval,2)
    For x=0 To 7
        If (tgs_rep(2,y,sprnbr) And (2^x)) Then Rect (7-x)*2,y*2,2,2
        If (tgs_rep(2,y+16,sprnbr) And (2^x)) Then Rect (15-x)*2,y*2,2,2
    Next
   Next
 EndIf
 If nbspr>=4 Then
   SetBuffer ImageBuffer(winspr,3)
   For y=0 To 15
    tcsval = tcs_rep(3,y,sprnbr)
    If (tcsval>15) Then tcsval = 0
    Color palette(tcsval,0),palette(tcsval,1),palette(tcsval,2)
    For x=0 To 7
        If (tgs_rep(3,y,sprnbr) And (2^x)) Then Rect (7-x)*2,y*2,2,2
        If (tgs_rep(3,y+16,sprnbr) And (2^x)) Then Rect (15-x)*2,y*2,2,2
    Next
   Next
 EndIf
SetBuffer ImageBuffer(winspr,4)
For y=0 To 15
    For x=0 To 7
		col=0
		For l = 0 To nbspr-1		
			If (tgs_rep(l,y,sprnbr) And (2^x)) Then col=col Or tcs_rep(l,y,sprnbr)
		Next	
	    Color palette(col,0),palette(col,1),palette(col,2)
		Rect (7-x)*2,y*2,2,2
		col=0
		For l = 0 To nbspr-1		
			If (tgs_rep(l,y+16,sprnbr) And (2^x)) Then col=col Or tcs_rep(l,y,sprnbr)
		Next	
	    Color palette(col,0),palette(col,1),palette(col,2)
		Rect (15-x)*2,y*2,2,2		
	Next
Next
;If sprnbr<>lastSprNbr Then
;	SetGadgetText debugtext,""
;	AddTextAreaText(debugtext,"Nbspr:"+nbspr+Chr$(13)+Chr$(10))
;	For y = 0 To 15
;		AddTextAreaText(debugtext,"Row"+y+":")
;		For l = 0 To nbspr-1
;			AddTextAreaText (debugtext," "+tcs_rep(l,y,sprnbr))
;		Next
;		For l = 0 To nbspr-1
;			AddTextAreaText (debugtext,"|"+Right$(Bin(tgs_rep(l,y+16,sprnbr)),8))
;		Next		
;		AddTextAreaText(debugtext,Chr$(13)+Chr$(10))
;	Next
;	lastSprNbr=sprnbr
;EndIf
End Function

;--------------------------------------------------------
; FileWithoutExt$ function
;--------------------------------------------------------
Function FileWithoutExt$(filename$)
i=Instr(filename$,".")
If i>0 Then filename$=Left$(filename$,i-1)
Return filename$
End Function
;--------------------------------------------------------
; Fileexists function
;--------------------------------------------------------
Function fileExists(filename$)
test = ReadFile(filename$)
If Not test 
   Return False 
Else 
  CloseFile test 
  Return True 
EndIf 
End Function

;--------------------------------------------------------
; FileNameWithoutExtension function
;--------------------------------------------------------
Function ExtractFileName$(sFilePath$)
;LOCAL VARS 
Local iStartPos% = 0 
Local iSearchPos% = 0 
Local iFilePathLength = 0 
Local sFileName$ = "" 
;BEGIN FUNCTION CODE 
iFilePathLength = Len(sFilePath$) 
iSearchPos% = iFilePathLength 
While (iStartPos% < 1) And (iSearchPos% > 1)
 iStartPos% = Instr(sFilePath$, "\", iSearchPos%) 
iSearchPos% = iSearchPos% - 1 
Wend 
If iStartPos = 0 Then ;if the filepath contains no backslashes 
 sFileName$ = sFilePath$ 
Else 
 sFileName$ = Right$(sFilePath$, iFilePathLength% - iStartPos%) 
EndIf 
Return sFileName$
End Function