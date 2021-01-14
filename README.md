# HTMLGUI
I have included an example script to explain it.

Variable Naming Rules: Any Letters/Numbers and Underscores are valid.  (This_Is_Correct1) (This is Incorrect)

Create the Instance to the Class
`GG:=New HTMLGUI(Win,ProgramName,Style,Options)`

* Win: ID of the Window *Variable Naming Rules
* ProgramName: The name you want to be in the Caption of your GUI
* Style: Object with basic HTML Styles: (EG {Background:"Blue",Color:"Brown",Size:45})
  * Note: Size is not a Normal HTML value but it will be the size of the Font used for the GUI
* Options: Object {Resize:0,ToolWindow:1,Owner:HWND,Caption:0}
  * Resize: If you do not want to allow the user to resize the window set it to 0
  * ToolWindow: Sets the style of your window to ToolWindow
  * Owner: Pass the HWND of the Owner of the new GUI
  * Caption: Set this to 0 if you do not want to have a Caption for the GUI

Now Add Controls to the GUI

`GG.createElement("Input",Parent,{Function:"Input",IgnoreState:1,ID:"My_Search"})`
This will add an Input to the GUI.  It does not have any Style attributes so it will use what you set when you create the GUI.
* Input is the first Attribute and sets what type of Element you want to use
* Parent would be whatever Element you would like to put this new Element below
* {Function:"Input",IgnoreState:1,ID:"My_Search"}
  * Function: Allows you to set which Function or Label you want to trigger when a user types within the Input
  * IgnoreState: If this is set to 1 the Background of the Input does not turn red
  * ID: Whatever you want the control to be associated with.  *Variable Naming Rules

```
GG.createElement("DDL",Parent,{Function:"DDL",ID:"MyDDL",Drop:"DDLDrop"},{Background:"Black",Color:"Yellow"},""
             		,[{Value:"Apple",OID:1,Language:1}
		            ,{Value:"&#0191;Peach",OID:2,Style:"Color:Pink",Language:2}
			          ,{Value:"Pear",OID:3,Language:3}
			          ,{Value:"Banana",OID:4,Language:4}
		            ,{Value:"Kitty &#x1F63C;",OID:5,Language:5,Selected:1}])
 ```
 This will create a Drop Down List (DDL)
* DDL is the type "String"
* Parent Element
* {Function:"DDL",ID:"MyDDL",Drop:"DDLDrop"}
  * Function: Allows you to set which Function or Label you want to trigger when a user clicks on this Element
  * IgnoreState: If this is set to 1 the Background of the Input does not turn red
  * ID: Whatever you want the control to be associated with.  *Variable Naming Rules
  * Drop: Function to be triggered when you Drag/Drop File(s) onto that specific Element
* {Background:"Black",Color:"Yellow"}
  * Standard HTML Styles
* Array of Objects to be put into your DDL
  * {Value:"Apple",OID:1,Language:1}
    * Value: The Text for the DDL Item
    * OID: The ID of the DDL Item
    * Language: If you want to setup multiple Languages for your GUI set this to the Name you want to associate to the translation (Discussed Below)
`GG.Show(X,Y,Width,Height)`
* X:
  * Can be left blank to just be Centered Horizontally
  * Pass it an Integer offset it from the Left of the screen
  * Can be an HWND of a Window that you want it to be Centered within (Like a centered Pop-Up Window)
* Y:
  * Can be left blank to just be Centered Vertically
  * Pass it an Integer offset it from the Top of the screen
  * Can be an HWND of a Window that you want it to be Centered within (Like a centered Pop-Up Window)
* Width: The Width of the new GUI
* Height: The Height of the new GUI
