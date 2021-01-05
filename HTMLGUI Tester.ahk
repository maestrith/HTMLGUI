#SingleInstance,Force
global GG:=New HTMLGUI()
GG.Reset()
GG.createElement("Style").innerHTML:="Body{Font-Size:50px}"
GG.createElement("Input",,{Function:"Input",IgnoreState:1,ID:"My_Search"})
/*
	New Line
*/
GG.createElement("Button",,{Function:"Show"},,,"Show Stuff")
Div:=GG.createElement("Div")
GG.createElement("TreeView",Div,,{Width:300,Height:"calc(100% - 30px)",Float:"Left"},"MyTree")
GG.createElement("ListView",Div,,{Width:"calc(100% - 304px)",Height:"calc(100% - 30px)",Float:"Left"},"MyList")
GG.SubFolderIndent:="0px"
GG.Show(,,602,352)
Tree:=[[{OID:1,Value:"Neat",Parent:"",ClosedIcon:"&#x21C9;",OpenIcon:"&#x2B87;",IconStyle:"Color:Purple",Style:"Color:Pink"}]
	 ,[{OID:2,Value:"<U>S</U><Span Style='Color:Yellow'>t</Span><Span Style='Color:Purple'>u</Span>ff",Parent:1,ClosedIcon:"&#x1F63C;",OpenIcon:"&#x1F63C;",ClosedIconStyle:"Color:Orange",IconStyle:"Color:Purple",Style:"Color:Pink"}]
	 ,[{OID:3,Value:"Folder",Type:"Folder",Parent:0,Icon:"&#2352;",IconStyle:"Color:Purple",Style:"Color:Pink"}]
	 ,[{OID:4,Value:"In Folder",Parent:3,Icon:"&#2353;",IconStyle:"Color:Orange",Style:"Color:Pink"}]]
GG.BuildTree(Tree,"MyTree")
GG.BuildLV("MyList",[{ID:"ID",Name:"ID Name"},{ID:"Title",Name:"The Title"},{ID:"Things",Name:"More Things"}])
GG.BuildBody2([{ID:{Type:"Text",Value:4,OID:1},Title:{Type:"Input",Style:"Width:90%;Color:Pink",Value:"Neat",IgnoreState:1,Function:"This",OID:1},Things:{Type:"Checkbox",Value:"LOL",OID:1}}
		    ,{ID:{Type:"Text",Value:4,OID:2},Title:{Type:"Input",Value:"Fun",Function:"That",OID:2},Things:{Type:"Text",Value:"Other things",OID:2}}],"MyList")
GG.LabelOrder()
GG.FixColumnHeaders()
GG.Tab()
return
Show(){
	All:=GG.querySelectorAll("Input")
	while(aa:=All.Item[A_Index-1]){
		Info.=(((LV:=aa.getAttribute("ListView"))?(LV)" - "(aa.ID)" - "(aa.getAttribute("OID")):aa.ID))" = "(aa.getAttribute("Type")="Checkbox"?(aa.Checked?"Checked":"Un-Checked"):aa.Value)"`n`n"
	}
	m(Info,"","Current TV: "GG.querySelector("Div[ID='MyTree'] LI[Sel] Span[ID='Label']").innerHTML)
}
This(a,b,c){
	t("Function: " A_ThisFunc,"Label: " A_ThisLabel,"Line: " A_LineNumber,"HERE!",a,b,c)
}
That(a,b,c){
	t("Function: " A_ThisFunc,"Label: " A_ThisLabel,"Line: " A_LineNumber,"HERE!",a,b,c)
}
Input(a,b,c){
	t(b)
}
1Close(){
	ExitApp
}
m(x*){
	for a,b in x
		Msg.=(IsObject(b)?Obj2String(b):b)"`n"
	MsgBox,%Msg%
}
#Include <HTMLGUI>
#Include <t.ahk>
#Include <Obj2String.ahk>