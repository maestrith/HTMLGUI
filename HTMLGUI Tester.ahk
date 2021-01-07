#SingleInstance,Force
global GG:=New HTMLGUI()
GG.Reset()
GG.createElement("Style").innerHTML:="Body{Font-Size:50px;Background:Black}"
GG.createElement("Input",,{Function:"Input",IgnoreState:1,ID:"My_Search"})
GG.createElement("DDL",,{Function:"DDL",ID:"MyDDL"},{Background:"Black",Color:"Yellow"},
			 ,[{Value:"Apple",OID:1}
			 ,{Value:"&#0191;Peach",OID:2,Style:"Color:Pink"}
			 ,{Value:"Pear",OID:3}
			 ,{Value:"Banana",OID:4}
			 ,{Value:"&#x1F63C; Kitty",OID:5,Selected:1}]) ;OID is not necessary but if you want it to be something other than 1,2,3,4...etc you can set it, just don't reuse them
GG.createElement("Button",,{Function:"Show"},,,"Show Stuff")
GG.createElement("Button",,{Function:"Revert"},,,"Revert")
Div:=GG.createElement("Div")
GG.createElement("TreeView",Div,,{Width:300,Height:"calc(100% - 30px)",Float:"Left"},"MyTree")
GG.createElement("ListView",Div,,{Width:"calc(100% - 304px)",Height:"calc(100% - 28px)",Float:"Left"},"MyList")
GG.SubFolderIndent:="0px"
GG.Show(,,602,352)
Tree:=[[{OID:1,Value:"Neat",Parent:"",ClosedIcon:"&#x21C9;",OpenIcon:"&#x2B87;",IconStyle:"Color:Purple",Style:"Color:Pink"}]
	 ,[{OID:2,Value:"<U>S</U><Span Style='Color:Yellow'>t</Span><Span Style='Color:Purple'>u</Span>ff",Parent:1,ClosedIcon:"&#x1F63C;",OpenIcon:"&#x1F63C;",ClosedIconStyle:"Color:Orange",IconStyle:"Color:Purple",Style:"Color:Pink"}]
	 ,[{OID:3,Value:"Folder",Type:"Folder",Parent:0,Style:"Color:Pink"}]
	 ,[{OID:4,Value:"In Folder",Parent:3,Icon:"&#0191;",IconStyle:"Color:Orange",Style:"Color:Pink"}]]
TT:=[],OID:=1
Loop,100
{
	II:=A_Index
	for a,b in Tree{
		Obj:=[]
		for c,d in b.1{
			Obj.1[c]:=d
		}
		Obj.1.OID:=(OID++)
		TT.Push(Obj)
	}
}
/*
	m(TT)
*/
GG.BuildTree(TT,"MyTree")
GG.BuildLV("MyList",[{ID:"ID",Name:"ID Name"},{ID:"Title",Name:"The Title"},{ID:"Things",Name:"More Things"}])
GG.BuildBody2([{ID:{Type:"Text",Value:4,OID:1},Title:{Type:"Input",Style:"Width:90%;Color:Pink",Value:"Neat",IgnoreState:1,Function:"This",OID:1},Things:{Type:"Checkbox",Value:"LOL",OID:1}}
		    ,{ID:{Type:"Text",Value:4,OID:2},Title:{Type:"Input",Value:"Fun",Function:"That",OID:2},Things:{Type:"Text",Value:"Other things",Function:"ClickMe",Style:"Cursor:Hand",OID:2}}],"MyList")
GG.LabelOrder()
GG.FixColumnHeaders()
GG.Tab()
return
ClickMe(){
	m("You clicked me :)")
}
DDL(Action,Value,Node){
	t(Action,Value,Node.nodeName) ;Using just Node here would show the entire Select Node which would be huge.
}
Revert(){
	GG.Revert()
}
Show(){
	Values:=GG.Values()
	m("All Values:",Obj2String(Values),""
	 ,"Search Value: "(Values.My_Search),""
	 ,"Title Of Second Row MyList: "(Values.MyList.2.Title))
}
This(a,b,c){
	t("Function: " A_ThisFunc,"Label: " A_ThisLabel,"Line: " A_LineNumber,"HERE!",a,b,c,"time:1")
}
That(a,b,c){
	t("Function: " A_ThisFunc,"Label: " A_ThisLabel,"Line: " A_LineNumber,"HERE!",a,b,c,"time:1")
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
F1::
GG.Revert()
return
#Include <HTMLGUI>