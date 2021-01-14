#SingleInstance,Force
global GG:=New HTMLGUI(1,"",{Background:"Black",Size:30}),Different:=1
GG.Reset()
;~ GG.SetLanguageObj({Main:{Show:{English:"Show Values",Jibberish:"Flhsoqns"},Save:{English:"Save",Jibberish:"oEioah#"},Language:{English:"Jibberish",Jibberish:"English"},Four:{English:4,Jibberish:"Toast"}}})
GG.createElement("Input",,{Function:"Input",IgnoreState:1,ID:"My_Search"})
GG.createElement("DDL",,{Function:"DDL",ID:"MyDDL",Drop:"DDLDrop"},{Background:"Black",Color:"Yellow"},
			 ,[{Value:"Apple",OID:1,Language:1}
			 ,{Value:"&#0191;Peach",OID:2,Style:"Color:Pink",Language:2}
			 ,{Value:"Pear",OID:3,Language:3}
			 ,{Value:"Banana",OID:4,Language:4}
			 ,{Value:"Kitty &#x1F63C;",OID:5,Language:5,Selected:1}]) ;OID is not necessary but if you want it to be something other than 1,2,3,4...etc you can set it, just don't reuse them
GG.createElement("Button",,{Function:"Show",Language:"Show"},,,"Show Values")
GG.createElement("Button",,{Function:"Save",Language:"Save"},,,"Save Edited")
GG.createElement("Button",,{Function:"Revert",Language:6},,,"Revert")
GG.createElement("Button",,{Function:"Different",Menu:"Testing",Language:7},,,"Different Tree")
GG.createElement("Button",,{Function:"Change_Language",Language:"Language"},,,"Change Language")
GG.createElement("Checkbox",,{ID:"Large",Function:"RefreshTree",Language:8},{"Font-Size":15,Color:"Yellow"},,"Large Tree")
Div:=GG.createElement("Div",,,{Width:"100%",Height:"calc(50%)",Display:"Inline-Block"})
GG.createElement("TreeView",Div,,{Width:300,Height:"100%",Float:"Left"},"MyTree")
GG.createElement("ListView",Div,{Drop:"MyListDrop"},{Width:"calc(100% - 304px)",Height:"calc(100% + 2px)",Float:"Left"},"MyList")
GG.SubFolderIndent:="0px"
MG:=GG.createElement("MediaGrid",Div,{Drop:"ImageDrop",AutoPlay:1},{Width:"60%",Height:"calc(100% - 27px)",Float:"Left"},"MG")
GG.createElement("Span",Div,{Language:10},{"Font-Size":25},,"Media Grid:</BR>Arrow Keys change the Selection</BR>Space Toggles Selection</BR>Double Click to Select</BR>Shift+Click to Toggle Selection</BR>Control+Click to Toggle Selection</BR>Ctrl+A to Toggle the Selection for All Items</BR>Shift+(Left/Up/Right/Down) to Toggle Selection in that direction</BR>P to Play/Pause Media")
Images:=[]
Loop,Files,Images\*.*
	Images.Push({SRC:A_LoopFileLongPath,OID:A_Index,Text:"Image: "(A_Index),Language:200+A_Index})
MG.Populate(Images)
MG.SelectHotkeys({"!a":"Select_All"})
Different()
GG.BuildLV("MyList",[{ID:"ID",Name:"ID Name",Language:"Header1"},{ID:"Title",Name:"The Title",Language:"Header2"},{ID:"Things",Name:"More Things",Language:"Header3"}])
GG.BuildBody2([{ID:{Type:"Text",Value:4,OID:1,Language:11},Title:{Type:"Input",Language:12,Style:"Width:90%;Color:Pink",Value:"Neat",Drop:"Woot",IgnoreState:1,Function:"This",OID:1},Things:{Type:"Checkbox",Language:13,Checked:1,Value:"LOL",OID:1}}
		    ,{ID:{Type:"Text",Value:4,OID:2,Language:14},Title:{Type:"Input",Language:15,Value:"Fun",Menu:"Testing",Function:"That",OID:2},Things:{Type:"Text",Language:16,Value:"Other things",Function:"ClickMe",Style:"Cursor:Hand",OID:2}}],"MyList")
GG.Tab()
GG.Menus("Testing","<Menu><Item Name='First'><Item Name='Under First' Function='Under'/></Item><Item Name='Testing' Function='Testing'/></Menu>")
GG.Show(,,1400,650)
GG.SetCurrentLanguage("English")
GG.SetScreen("Main")
BuildJibberish()
BuildJibberish(){
	All:=GG.querySelectorAll("*[Language]")
	Lang:=[]
	Letters:=StrSplit("ABCDEFGHIJKLMNOPQRSTUVWXYZAabcdefghijklmnopqrstuvwxyz1234567890!#@$_- ")
	while(aa:=All.Item[A_Index-1]){
		if(Language:=aa.getAttribute("Language")){
			if(LL:=GG.LanguageObj.Main[Language]){
				Lang[Language]:=LL
			}else if(Label:=aa.querySelector("Span[ID='Label']")){
				Jibberish:=""
				Loop,% Strlen(Label.innerHTML){
					Random,Letter,1,% Letters.MaxIndex()
					Jibberish.=Letters[Letter]
				}
				Lang[Language]:={English:Label.innerHTML,Jibberish:Jibberish}
			}else if(Language){
				if(Value:=aa.getAttribute("Value")){
					Jibberish:=""
					Loop,% Strlen(Value){
						Random,Letter,1,% Letters.MaxIndex()
						Jibberish.=Letters[Letter]
					}
					Lang[Language]:={English:Value,Jibberish:Jibberish}
				}else{
					Jibberish:=""
					Loop,% Strlen(aa.innerHTML){
						Random,Letter,1,% Letters.MaxIndex()
						Jibberish.=Letters[Letter]
					}
					Lang[Language]:={English:aa.innerHTML,Jibberish:Jibberish}
				}
			}
		}
	}
	Lang.Language:={English:"Jibberish",Jibberish:"English"}
	GG.SetLanguageObj({Main:Lang})
	GG.UpdateLanguage()
}
return
Nifty(){
	m("Function: " A_ThisFunc,"Line: " A_LineNumber,"Nice")
}
Testing(MenuItem,Position,Menu){
	m("Function: " A_ThisFunc,"Line: " A_LineNumber,"Here!",Menu,Position,MenuItem)
}
Under(MenuItem,Position,Menu){
	m("Function: " A_ThisFunc,"Line: " A_LineNumber,"Here!",Menu,Position,MenuItem)
}
Save(){
	m("Function: " A_ThisFunc,"Line: " A_LineNumber,"Here!")
}
F1::
mHTML()
return
1Escape(){
	ExitApp
}
Change_Language(){
	GG.SetCurrentLanguage(GG.CurrentLanguage="English"?"Jibberish":"English"),GG.UpdateLanguage()
}
ClickMe(){
	m("You clicked me :)")
}
DDL(Action,Value,Node){
	t(Action,Value,Node.nodeName,"time:2") ;Using just Node here would show the entire Select Node which can be huge.
}
DDLDrop(Files){
	m("Function: " A_ThisFunc,"Line: " A_LineNumber,"Here!",Files)
}
Different(Refresh:=0){
	static Count:=2
	Different:=Refresh=1?1:Different+1
	if(Different>Count)
		Different:=1,Tree2(),BuildJibberish()
	else
		Tree1()
}
DropFiles(Files){ ;General Drop Destination
	m("Function: " A_ThisFunc,"Line: " A_LineNumber,"Here!",Files)
}
ImageDrop(Files){
	m("Function: " A_ThisFunc,"Line: " A_LineNumber,"Here!",Files)
}
Input(a,b,c){
	t("Function: " A_ThisFunc,"Label: " A_ThisLabel,"Line: " A_LineNumber,"HERE!",b)
}
m(x*){
	for a,b in x
		Msg.=(IsObject(b)?Obj2String(b):b)"`n"
	MsgBox,%Msg%
}
MyListDrop(Files){
	m("Function: " A_ThisFunc,"Line: " A_LineNumber,"Here!",Files)
}
mNode(Node){
	m("Function: " A_ThisFunc,"Line: " A_LineNumber,"Here!",RegExReplace(Node.outerHTML,">.*",">"))
}
RefreshTree(){
	Different(1)
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
That(a,b,c){
	t("Function: " A_ThisFunc,"Label: " A_ThisLabel,"Line: " A_LineNumber,"HERE!",a,b,c,"time:1")
}
This(a,b,c){
	t("Function: " A_ThisFunc,"Label: " A_ThisLabel,"Line: " A_LineNumber,"HERE!",a,b,c,"time:1")
}
Tree1(){
	Tree:=[{OID:1,Language:33,Menu:"Testing",Value:"Neat",Parent:"",ClosedIcon:"&#x21C9;",OpenIcon:"&#x2B87;",IconStyle:"Color:Purple",Style:"Color:Pink",Expand:1}
		 ,{OID:2,Language:34,Menu:"Testing",Function:"TreeClick1",Value:"<U>S</U><Span Style='Color:Yellow'>t</Span><Span Style='Color:Purple'>u</Span>ff With a lot of text to show </BR> that it will scroll to the right or left depending on what the text is",Parent:1,ClosedIcon:"&#x1F63C;",OpenIcon:"&#x1F63C;",ClosedIconStyle:"Color:Orange",IconStyle:"Color:Purple",Style:{Color:"Pink"}}
		 ,{OID:3,Language:35,Function:"TreeClick2",Value:"<U>S</U><Span Style='Color:Yellow'>t</Span><Span Style='Color:Purple'>u</Span>ff",Parent:1,ClosedIcon:"&#x1F63C;",OpenIcon:"&#x1F63C;",ClosedIconStyle:"Color:Orange",IconStyle:"Color:Purple",Style:{Color:"Pink"}}
		 ,{OID:4,Language:36,Value:"Folder",Type:"Folder",Parent:0,Style:"Color:Pink",Language:"Four"}
		 ,{OID:5,Language:37,Value:"In Folder",Parent:4,Icon:"&#0191;",IconStyle:"Color:Orange",Style:"Color:Pink"}]
	if(GG.querySelector("#Large").Checked){
		TT:=[],Index:=0
		Loop,100
			for c,d in Tree
				Obj:=d.Clone(),Obj.OID:=++Index,TT.Push(Obj)
		GG.BuildTree(TT,"MyTree")
	}else
		GG.BuildTree(Tree,"MyTree")
}
Tree2(){
	TT:=[],Index:=0,Index:=100
	Loop,10
	{
		TT.Push({OID:++Index,Value:"Things",Type:"Folder",Language:Index}),Parent:=Index
		Sub:=3
		Loop,%Sub%
			TT.Push({OID:++Index,Value:"Moar Things",Parent:Parent,Type:(A_Index=Sub?"Folder":""),Language:Index})
		Parent:=Index,TT.Push({OID:++Index,Value:"Even Moar Things",Parent:Parent,Language:Index})
	}
	GG.BuildTree(TT,"MyTree")
}
TreeClick1(a,b,c){
	t("Function: " A_ThisFunc,"Label: " A_ThisLabel,"Line: " A_LineNumber,"HERE!",a,b,c,"Will go away in 3 seconds","time:3")
}
TreeClick2(){
	t("Function: " A_ThisFunc,"Label: " A_ThisLabel,"Line: " A_LineNumber,"HERE!","Will go away in 1 second","time:1")
}
Woot(Files){
	m("Function: " A_ThisFunc,"Line: " A_LineNumber,"Here!",Files)
}
#Include <HTMLGUI>