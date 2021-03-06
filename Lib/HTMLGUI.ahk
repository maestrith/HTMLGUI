HTMLGUI(Win:=1,ProgramName:="",Style:="",Options:=""){
	return New HTMLGUI(Win,ProgramName,Style,Options)
}
GUIDropFiles(a*){
	GuiDropFiles:
	CoordMode, Mouse, Client
	MouseGetPos, x, y
	element := wb.document.elementFromPoint(x, y)
	MsgBox, % element.outerHTML "`n" x " : " xX "`n" y " : " YY
	return
	MsgBox, Received file drop event
}
Class HTMLGUI{
	static Keep:=[]
	_Event(Name,Event){
		static Events:=[],Last:=[]
		Node:=Event.SrcElement,Ident:=Node.getAttribute("Ident")
		;~ t("Function: " A_ThisFunc,"Label: " A_ThisLabel,"Line: " A_LineNumber,"HERE!",Name,SubStr(Node.outerHTML,1,500))
		if(Name="Mouse"){
			if(Function:=Node.getAttribute("Right_Click")){
				Event.preventDefault()
				if(IsLabel(Function))
					SetTimer,%Function%,-1
				return Func(Function).Call("RightClick",Value,Node,Obj.Which)
			}if(Menu:=Node.getAttribute("Menu"))
				return Event.preventDefault(),this.Menu(Menu)
			else if(Menu:=this.GetDiv(Node).getAttribute("Menu"))
				return Event.preventDefault(),this.Menu(Menu)
			else if(Menu:=this.GetControl(Node).getAttribute("Menu"))
				return Event.preventDefault(),this.Menu(Menu)
			if(Node.nodeName="Input")
				return
			return Event.preventDefault()
		}if(Node.getAttribute("Checkbox"))
			return Node.previousSibling.Click()
		if(Node.nodeName="Option")
			Node:=Node.parentNode
		if(Ident="Inner")
			return ID:=Node.parentNode.ID,NN:=this.MainGUI[ID],NN.innerText:="#" ID " Div.Container1{transform:translate(-" Node.ScrollLeft "px)}"
		Events.Push({Name:Name,Node:Node,this:this,Which:(Name="Mouse"?Event.Which:"")})
		SetTimer,HTMLGUIGUIEvent,-10
		return
		HTMLGUIGUIEvent:
		ComObjError(0)
		while(Obj:=Events.Pop()){
			Node:=Obj.Node,Name:=Obj.Name,this:=Obj.this,OID:=Node.getAttribute("OID"),LV:=Node.getAttribute("ListView"),Type:=Node.getAttribute("Type"),ID:=(Lookup:=Node.getAttribute("Lookup"))?Lookup:Node.ID,Value:=Node.getAttribute("Value")
			if(Node.getAttribute("IgnoreClick")&&Name="Click")
				return
			if(Node.nodeName="Select")
				Value:=Node.querySelector("Option[Value='"(Node.Value)"']").getAttribute("OID")
			else if(Node.nodeName="Span")
				Value:=Node.innerText
			else
				Value:=Node.Value
			if(Type~="i)\b(Checkbox)\b"||Node.nodeName~="i)\b(Input)\b")
				Value:=Type="Checkbox"?(Node.Checked?-1:0):Node.Value
			if(Tree:=Node.getAttribute("Tree")){
				if(Node.ID="Icon"){
					PN:=Node.parentNode
					if(PN.querySelector("LI"))
						PN.setAttribute("Expand",(PN.getAttribute("Expand")?"":1))
					return
				}if(Obj.Name="DoubleClick"){
					Node:=this.querySelector("Div[Tree='"(Tree)"'] LI[OID='"(Node.getAttribute("OID"))"']")
					if(Node.querySelector("LI"))
						Node.setAttribute("Expand",Node.getAttribute("Expand")?"":1)
					return
				}this.TVSetSel(Tree,Node.getAttribute("OID"))
			}if(Node.nodeName="Input"&&Name="Click"&&Type!="Checkbox")
				return ComObjError(1)
			if((Name="Click"||Name="DoubleClick")&&Type="MediaGrid")
				return this.MediaGrid[Node.ID][Name](Node)
			if(Name="OnInput"||(Name="Click"&&Type~="i)(Checkbox|Select|Date)"))
				this.CheckUpdated(Node)
			if((Method:=Node.getAttribute("IG"))&&IsObject(IG:=this.IG))
				return IG[Method](Name,Value,Node)
			if((Function:=Node.getAttribute("Function"))||(Node.getAttribute("Tree")&&(Function:=this.GetLI(Node).getAttribute("Function")))){
				if(IsLabel(Function))
					SetTimer,%Function%,-1
				return Func(Function).Call(Name,Value,Node,Obj.Which)
			}else if(IsFunc("Actions"))
				return Func("Actions").Call(Name,Value,Node)
			if((Label:=Node.getAttribute("Label"))&&IsLabel(Label))
				SetTimer,%Label%,-1
			if(Timer:=Node.getAttribute("Timer"))
				SetTimer,% Obj.this.Timers[Timer].Name,% Obj.this.Timers[Timer].Period
			if(Name="Click"){
				if(LV:=this.IsLV(Node)){
					if(!GetKeyState("Shift","P")&&!GetKeyState("Ctrl","P"))
						this.Selected[LV]:={(OID):1}
					else if(GetKeyState("Shift","P")){
						if((Current:=this.LastSelected[LV])="")
							return this.Selected[LV,OID]:=1,this.SetSel(LV,OID),ComObjError(1)
						this.Selected[LV]:=[],Last:=Current,Last:=Last?Last:1,Min:=Last<OID?Last:OID,Max:=Last>OID?Last:OID
						for a,b in (this.Data[LV]){
							if(b.OID<Min)
								Continue
							if(b.OID>Max)
								Break
							if(b.OID>=Min&&b.OID<=Max)
								this.Selected[LV,b.OID]:=1
					}}if(GetKeyState("Ctrl","P"))
						this.Selected[LV].HasKey(OID)?this.Selected[LV].Delete(OID):this.Selected[LV,OID]:=1
					this.SetSel(LV,OID)
				}
			}
		}return ComObjError(1)
	}_HTML(Node:=""){
		this.m(Clipboard:=RegExReplace(Node?Node.outerHtml:this.Doc.Body.outerHTML,"<","`n<"))
	}__New(Win:=1,ProgramName:="",Style:="",Options:=""){
		static
		#MaxHotkeysPerInterval,1000
		#HotkeyInterval,1
		SetWinDelay,-1
		for a,b in {Background:"Black",Highlight:"#333",SelectedColor:"#999",Color:"Grey",Changed:"Red",HeaderColor:"Orange",Size:15}
			this[a]:=b
		for a,b in Style
			this[a]:=b
		Gui,%Win%:Destroy
		Gui,%Win%:Default
		Gui,Margin,0,0
		this.BodyHTML:="<Body Style='Background:"(this.Background)";Color:"(this.Color)";Margin:0px'>"
		Gui,% Foo:="+HWNDMHWND "(Options.Resize!=0?"+Resize":"")(Options.ToolWindow?" +ToolWindow":"")(Options.Owner?" +Owner"(Options.Owner):"")(Options.Caption=0?" -Caption":"")
		for a,b in Options
			if(a="GUI")
				Gui,%b%
		this.MainGUI:=[],this.FixIE(11)
		Gui,Add,ActiveX,vMain HWNDMainHWND w500 h300,about:blank
		Gui,+LabelHTMLGUI. +HWNDhMain
		Detect:=A_DetectHiddenWindows
		DetectHiddenWindows,On
		Sleep,100
		ControlGet,hIE,hWnd,,Internet Explorer_Server1,% "ahk_id" hMain
		DetectHiddenWindows,%Detect%
		Main.RegisterAsDropTarget:=false
		DllCall("ole32\RevokeDragDrop","UPtr",hIE)
		this.FixIE(),this.Win:=Win,this.FunctionObj:=[]
		this.WB:=Main,this.LastLV:=[]
		this.AllMenus:=[]
		this.ListViewStyles:=[]
		this.Doc:=Main.Document,this.HWND:=MHWND,this.ID:="ahk_id"MHWND,this.WB:=Main,this.MediaGrid:=[]
		this.Functions:=[],this.ChangedObj:=[],this.ChangedNode:=[],this.Columns:=[],this.Data:=[],this.ProgramName:=ProgramName,this.Selected:=[],this.SelectedCSS:=[],this.Styles:=[],this.StylesObj:=[],this.Timers:=[],this.Controls:={Main:{HWND:MainHWND,ID:"ahk_id"MainHWND}}
		HTMLGUI.Keep[Win]:=this
		this.IEHWND:=MainHWND
		HTMLGUI.Keep[hMain]:=this
		IID:="{332C4427-26CB-11D0-B483-00C04FD90119}" ;IID_IWebBrowserApp
		this.window:=ComObj(9,ComObjQuery(Main,IID,IID),1)
		this.OpenFolder:="&#x1f4c2;",this.ClosedFolder:="&#128193;",this.SubFolderIndent:="-25px",this.TreeViewSelectColor:="Blue",this.TreeViewUnFocusedBorderColor:="Grey"
		;this.OpenFolder:="\1F5C1",this.ClosedFolder:="\1F5C0",this.SubFolderIndent:="-25px",this.TreeViewSelectColor:="Blue"
		this.DirectionsObj:=this.Directions.Bind(this)
		this.Hotkeys()
	}AddCSS(Selector,Declarations:=""){
		if(Selector&&!Declarations)
			RegExMatch(Selector,"OUi)(.*)(\{.*\})",Found),Selector:=Found.1,Declarations:=Found.2
		if(!Obj:=this.Styles[Selector])
			Obj:=this.Styles[Selector]:=[]
		if(!IsObject(Declarations)&&Declarations){
			Info:=Trim(Declarations,"{}")
			for a,b in StrSplit(Info,";"){
				OO:=StrSplit(b,":")
				Obj[OO.1]:=OO.2
			}
		}if(IsObject(Declarations))
			this.Styles[Selector]:=Declarations
		return this.SetCSS(Selector)
	}AutoCommit(OnOff:=0){
		this.ACommit:=OnOff
	}BuildBody(Data,ListView,AutoAdd:=""){
		New:=this.Data[ListView]:=[],this.LastSelected[ListView]:="",this.SelectedCSS[ListView].innerText:="",Function:=this.Functions[ListView]
		for a,b in Data{
			BodyHTML.="<TR ListView='"(ListView)"' Row='"(A_Index)"'>",this.PadID:=StrLen(Data.Count()),ID:=New.Push(OO:=[]),OO.OID:=b.OID
			for c,d in this.Columns[ListView]{
				OO[d.ID]:=(d.Type="Checkbox"?(b[d.ID]?-1:0):b[d.ID]),Value:=((Val:=this.ChangedObj[ListView,b.ID,d.ID])!="")?Val:b[d.ID],Value:=d.ID="Hotkey"?this.Convert_Hotkey(Value):Value,Style:=Val!=""?"Background-Color:Red":"",Style.=Style?";Text-Align:Center":"Text-Align:Center"
				if(d.Type="Input")
					BodyHTML.="<TD OID='"(b.OID)"' ID='"(d.ID)"' "(Style?"Style='"(Style)"'":"")"><Input ListView='"(ListView)"' OID='"(b.OID)"' Function='"(Function)"' ID='"(d.ID)"' Value='"this.cleanHTML(Value)"' Type='Text' oninput='OnInput(event)'"(Val?" Style='"(d.Style)"'":"")"></Input>"this.BuildExtra(d.Extra,b.OID)"</TD>"
				else if(d.Type="Checkbox")
					BodyHTML.="<TD OID='"(b.OID)"' ID='"(d.ID)"' "(Style?"Style='"(Style)"'":"")"><Input ListView='"(ListView)"' OID='"(b.OID)"' Function='"(Function)"' ID='"(d.ID)"' Type='Checkbox'"(Value?"Checked":"")"></Input>"this.BuildExtra(d.Extra,b.OID)"</TD>"
				else if(d.Type="DDL"){
					Item:="<Select Value='"this.cleanHTML(b[d.ID])"' ListView='"(ListView)"' OID='"(b.OID)"' ID='"(d.ID)"' Label='" d.Label "' onchange='OnInput(Event)' Column='" Column++ "' " AddAtt ""(d.Style?" Style='"(d.Style)"'":"")">"
					for g,h in d.Obj
						Item.="<Option OValue='"this.cleanHTML(h.Value)"' OID='"(h.OID)"' " (h.OID=b[d.ID]?" selected='selected'":"")">" h.Value "</Option>"
					BodyHTML.=Foo:="<TD OID='"(b.OID)"' ID='" b.Equipment "_Condition' oninput='OnInput(Event)' Value='"this.cleanHTML(d.Text)"'><Div Style='Flex-Wrap:NoWrap;Display:Flex'>" Item "</Select>"this.BuildExtra(d.Extra,b.OID)"</Div></TD>"
				}else if(d.Type="Date")
					BodyHTML.="<TD ID='"(d.ID)"' "(Style?"Style='"(Style)"'":"")"><Div Function='"(Function)"' ListView='"(ListView)"' OID='"(b.OID)"' ID='"(d.ID)"' Style='Flex-Wrap:NoWrap;Display:Flex;"(d.Style)"'><Input Type='Date' ListView='"(ListView)"' OID='"(b.OID)"' Function='"(Function)"' ID='"(d.ID)"' Value='"this.cleanHTML(Value)"' oninput='OnInput(event)'"(d.Style?" Style='"(d.Style)"'":"")"></Input>"this.BuildExtra(d.Extra,b.OID,b.OID)"</Div></TD>"
				else if(d.Type="Text")
					BodyHTML.=Foo:="<TD Function='"(Function)"' ListView='"(ListView)"' OID='"(b.OID)"' ID='"(d.ID)"' "(Style?"Style='"(Style)"'":"")"><Div Function='"(Function)"' ListView='"(ListView)"' OID='"(b.OID)"' ID='"(d.ID)"' Style='Flex-Wrap:NoWrap;Display:Flex;"(d.Style)"'><Span Function='"(Function)"' ListView='"(ListView)"' OID='"(b.OID)"' ID='"(d.ID)"' Style='"(d.Style)"'>"(Value)"</Span>"this.BuildExtra(d.Extra,b.OID)"</Div></TD>"
				else if(d.Type="Button")
					BodyHTML.="<TD ListView='"(ListView)"' OID='"(b.OID)"' ID='"(d.ID)"' "(Style?"Style='"(Style)"'":"")"><Button Function='"(d.Function)"' ListView='"(ListView)"' OID='"(b.OID)"' ID='"(d.ID)"' "(Style?"Style='"(Style)"'":"")">"(Value)"</Button>"this.BuildExtra(d.Extra,b.OID)"</TD>"
				else if(IsFunc(b.Type))
					BodyHTML.=Func(b.Type).Call(b,ListView)
				else
					this.m("Function: " A_ThisFunc,"Line: " A_LineNumber,"",d.Type " Has not yet been implemented",b,"",d)
			}BodyHTML.="</TR>"
		}ComObjError(1)
		if(AutoAdd){
			this.querySelector("#"(ListView)" .Container2").GetElementsByTagName("TBody").Item[0].innerHTML:=BodyHTML
			this.LabelOrder(),this.SetAllOValues()
			;~ this.FixColumnHeaders()
		}else
			return BodyHTML
	}BuildBody2(Data,ListView){
		static Atts:=["Menu","Drop","Function","ListView","Lookup","IgnoreState"]
		New:=this.Data[ListView]:=[]
		for a,b in Data{
			Total.="<TR ListView='"(ListView)"'>"
			ID:=New.Push(OO:=[])
			for c,d in this.Columns[ListView]{
				Info:=b[d.ID],Value:=Info.Value?Info.Value:Info.Name,Function:=Info.Function,OO[d.ID]:=(Info.Type="Checkbox"?(b[d.ID]?-1:0):Value),OO.OID:=Info.OID,Style:=Info.Style,ID:=Info.ID?Info.ID:d.ID,Type:=Info.Type?Info.Type:d.Type,AllItems:=""
				for c,d in Atts
					if(VVal:=Info[d])
						AllItems.=(d)"='"(VVal)"' "
				AllItems.="ListView='"(ListView)"' OID='"(Info.OID)"' ID='"(ID)"' Style='"(Style)"'"
				if(Type="Text")
					Total.=Foo:="<TD "(AllItems)" "(Style?"Style='"(Style)"'":"")"><Div "(AllItems)" Style='Flex-Wrap:NoWrap;Display:Flex;"(d.Style)"'><Span "(AllItems)" Language='"(Info.Language)"' Value='"this.cleanHTML(Value)"' Style='"(d.Style)"'>"(Value)"</Span>"this.BuildExtra(d.Extra,Info.OID)"</Div></TD>"
				else if(Type="Button")
					Total.=Foo:="<TD "(AllItems)" "(Style?"Style='"(Style)"'":"")"><Div "(AllItems)" Style='Flex-Wrap:NoWrap;Display:Flex;"(d.Style)"'><Button "(AllItems)" Value='"this.cleanHTML(Value)"' Style='"(d.Style)"'>"(Value)this.BuildExtra(d.Extra,Info.OID)"</Div></TD>"
				else if(type="Checkbox")
					Total.=Foo:="<TD "(AllItems)" "(Style?"Style='"(Style)"'":"")"><Div "(AllItems)" Style='Flex-Wrap:NoWrap;Display:Flex;"(d.Style)"'><Input "(AllItems)" Type='Checkbox' Value='"this.cleanHTML(Value)"' "(Info.Checked?" Checked ":"")" Style='"(d.Style)"'><Label "(AllItems)" Language='"(Info.Language)"'>"(Value)(this.BuildExtra(d.Extra,Info.OID))"</Label></Div></TD>"
				else if(Type="Input"){
					Total.=Foo:="<TD "(AllItems)"><Input "(AllItems)" Language='"(Info.Language)"' Value='"this.cleanHTML(Value)"' oninput='OnInput(event)'></Input>"this.BuildExtra(d.Extra,Info.OID)"</TD>"
				}else if(Type="Password")
					Total.=Foo:="<TD "(AllItems)"><Input "(AllItems)" Type='Password' Value='"this.cleanHTML(Value)"' oninput='OnInput(event)'></Input>"this.BuildExtra(d.Extra,Info.OID)"</TD>"
				else if(Type="Date")
					Total.="<TD "(AllItems)"><Span Language='"(Info.Language)"' Type='Date' Value='"this.cleanHTML(Value)"' Style='Cursor:Hand;Color:#3333FF' "(d.IgnoreState?"IgnoreState='1'":"")">"(Value)"</Span></TD>"
				else if(Type="DDL"){
					Item:="<Select "(AllItems)" Value='"this.cleanHTML(Value)"' onchange='OnInput(Event)' Column='" Column++ "' " AddAtt ""(b[d.ID].Style?" Style='"(b[d.ID].Style)"'":"")">"
					for e,f in b.Value.DDL
						Item.="<Option OID='"(f.OID)"' Value='"this.cleanHTML(f.Name)"' OValue='"this.cleanHTML(f.Name)"' "(f.Style?"Style='"(f.Style)"'":"")" "(f.Selected?" selected='selected'":"")">"(f.Name)"</Option>"
					Total.=Foo:="<TD OID='"(b.OID)"' ID='" b.Equipment "_Condition' oninput='OnInput(Event)' Value='"this.cleanHTML(d.Text)"'><Div Style='Flex-Wrap:NoWrap;Display:Flex'>" Item "</Select>"this.BuildExtra(d.Extra,b.OID)"</Div></TD>"
				}else if(IsFunc((Type)"_Column"))
					Total.=Foo:=Func((Type)"_Column").Call(b,Info,Listview)
				else
					this.m("Function: " A_ThisFunc,"Line: " A_LineNumber,"Build for type |"(Type)"|","",Info)
			}
			Total.="</TR>"
		}
		this.querySelector("#"(ListView)" .Container2").GetElementsByTagName("TBody").Item[0].innerHTML:=Total
		this.SetAllOValues()
		this.LabelOrder()
	}BuildExtra(Obj,OID){
		for a,b in Obj{
			if(b.Type="Button"){
				Extra.="<Button OID='"(OID)"' ListView='"(b.ListView)"' Function='"(b.Function)"'"(b.Style?" Style='"(b.Style)"'":"")">"(b.Name)"</Button>"
			}else{
				m("Function: " A_ThisFunc,"Line: " A_LineNumber,"The control type: ",b.Type,"Has not been setup yet.")
			}
		}
		return Extra
	}BuildLV(ListView,Columns:="",Data:=""){
		Build:=1
		this.HideLV(ListView)
		this.Columns[ListView]:=Columns
		for a,b in Columns{
			for c,d in b{
				if(!this.Columns[ListView,a,c]){
					Build:=1
					Break
				}
			}
		}Header:=this.Doc.querySelector("#"(ListView)" .Container1"),Body:=this.Doc.querySelector("#"(ListView)" .Container2")
		if(Build){
			Second:=Head:="<Table Name='"(ListView)"'><THead Class='FixedHeader'><TR Class='Header'>"
			for a,b in this.Columns[ListView]
				Spans.="<TH><Span Menu='"(b.Menu)"' Style="(b.Style)" Class='Header' Language='"(b.Language)"' ListView='"(ListView)"' Function='"(b.Function?b.Function:"SortHDR")"' OText='"(b.ID)"' ID='"(b.ID)"'>"(b.Name)"</Span></TH>",Second.="<TH>"(b.Name)"</TH>"
			Head.="</TR></thead></Table>",Second.="</TR></THead><TBody></TBody>",Header.innerHTML:=Head,Header.querySelector("TR").innerHTML:=Spans,Body.innerHTML:=Second,ComObjError(0)
			if(!this.SelectedCSS[ListView])
				this.SelectedCSS[ListView]:=this.createElement("Style")
			ComObjError(1)
		}if(!Columns.Count())
			Header.innerHTML:="",Body.innerHTML:=""
		if(Data)
			this.BuildBody(Data,ListView,1)
		if(!this.SuspendHeaderUpdate)
			this.FixColumnHeaders()
		this.Columns[ListView]:=Columns
		return Data
	}BuildMenu(Menu){
		if(!IsObject(this.XML))
			this.XML:=New:=ComObjCreate("MSXML2.DOMDocument"),New.SetProperty("SelectionLanguage","XPath")
		this.XML.LoadXML(Menu),Menus:=[],All:=this.XML.SelectNodes("//Item")
		while(aa:=All.Item[A_Index-1],ea:=this.ea(aa)){
			Menu:=aa.SelectNodes("ancestor::*").Length
			Menu,%Menu%,UseErrorLevel,On
			Menu,%Menu%,Add,% ea.Name,% ea.Function?ea.Function:"DeadEnd"
			aa.setAttribute("ID",Menu)
		}while(aa:=All.Item[A_Index-1],ea:=this.ea(aa))
			if(Child:=aa.selectSingleNode("Item/@ID").Text){
				Menu,%Child%,UseErrorLevel,On
				Menu,% ea.ID,Add,% ea.Name,% ":"(Child)
			}
		Menu,% this.XML.selectSingleNode("//Item/@ID").Text,Show
		while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa))
			Menu,% ea.ID,DeleteAll
		return
		DeadEnd:
		return
	}BuildTree(Data,Tree){
		Selected:=[],Expand:=[]
		for a,b in Data{
			Style:=""
			for c,d in b.Style
				Style.=(c)":"(d)";"
			for c,d in {"White-Space":"NoWrap"}
				Style.=(c)":"(d)";"
			Selected[b.OID]:=b.Sel,Expand[b.OID]:=b.Expand,Info.="<LI Language='"(b.Language)"' Menu='"(b.Menu)"' ID='"(b.OID)"' Tree='"(Tree)"' OID='"(b.OID)"' Function='"(b.Function?b.Function:this.MainGUI[Tree].Function)"' Type='"(b.Type)"' Style='Cursor:Hand' Parent='"(b.Parent)"'>",Info.=(b.Type="Folder")?"<Span ID='Icon' Menu='"(Info.Menu)"' Class='Open' Style='Color:Yellow'>"(this.OpenFolder)"</Span><Span Menu='"(Info.Menu)"' ID='Icon' Class='Closed' Style='Color:Yellow'>"(this.ClosedFolder)"</Span><Span Menu='"(Info.Menu)"' ID='Label' Style='"(Style)"'>"(b.Value)"</Span>":Row:="<Span Menu='"(b.Menu)"' ID='Icon' Class='Open' Style='"(b.OpenIconStyle?b.OpenIconStyle:b.IconStyle)"'>"(b.OpenIcon?b.OpenIcon:b.Icon)"</Span><Span Menu='"(b.Menu)"' ID='Icon' Class='Closed' Style='"(b.ClosedIconStyle?b.ClosedIconStyle:b.IconStyle)"'>"(b.ClosedIcon?b.ClosedIcon:b.Icon)"</Span><Span Menu='"(b.Menu)"' ID='Label' Style='"(Style)"'>"(b.Value)"</Span>",Info.="<UL Menu='"(b.Menu)"' Function='"(b.Function)"' Style='Margin:0px;Margin-Left:"(this.SubFolderIndent)"' ID='"(b.OID)"'></UL></LI>"
		}Parent:=this.querySelector("Div[ID='"(Tree)"']"),Parent.Style.Visibility:="Hidden",Parent.innerHTML:=Info
		for a,b in Expand
			if(b)
				Exp.=(a)":"(b?b:"''")","
		this.Window.Eval("(function(){var menu='';var all=document.querySelector('div[id="""(Tree)"""]').querySelectorAll('li[Menu]');for(let i=0;i<all.length;i++){let item=all[i];menu=item.getAttribute('menu');let more=item.querySelectorAll('*');for(let i=0;i<more.length;i++){let item=more[i];item.setAttribute('menu',menu)}}})();(function(){var exp={"Trim(Exp,",")"};var root=document.querySelector('div[id="""(Tree)"""]');var myNodeList=document.querySelectorAll('div[Tree] li');for(let i=0; i<myNodeList.length; i++){let item=myNodeList[i];let parent=item.getAttribute('parent');let oid=item.getAttribute('oid');if(parent>0)root.querySelector(""ul[id='""+parent+""']"").appendChild(item);item.setAttribute(""Expand"",exp[oid]?exp[oid]:''); }var myNodeList=root.querySelectorAll('li');for(let i=0; i<myNodeList.length; i++){let item=myNodeList[i];let all=item.querySelectorAll('*');let oid=item.getAttribute('OID');var node='';for(let j=0;j<all.length;j++){node=all[j];if(node.nodeName!='LI'&&node.nodeName!='UL'){node.setAttribute(""OID"",oid);node.setAttribute(""Tree"",'"(Tree)"'); }}}})()"),Parent.Style.Visibility:="Visible"
	}CenterTV(Node){
		Rect:=Node.getBoundingClientRect(),Parent:=this.querySelector("Div[Tree='"(Node.getAttribute("Tree"))"']"),PRect:=Parent.getBoundingClientRect(),Middle:=(PRect.Bottom-PRect.Top)/2
		PP:=this.GetLI(Node)
		if((NewPos:=Node.offsetTop-Middle))
			Parent.scrollTop:=NewPos
		Parent.ScrollLeft:=PP.offsetLeft
	}CheckUpdated(Node){
		LV:=Node.getAttribute("ListView"),OID:=Node.getAttribute("OID"),ID:=(II:=Node.getAttribute("Lookup"))?II:Node.getAttribute("ID"),Ignore:=Node.getAttribute("IgnoreState"),VV:=Node.getAttribute("OValue"),Value:=Node.getAttribute("Value"),Type:=Node.getAttribute("Type")
		if(Ignore)
			return
		if(Node.nodeName="Select")
			Value:=Node.querySelector("Option[OValue='"(Node.Value)"']").getAttribute("OID")
		else if(Node.nodeName="Span")
			Value:=Node.innerText
		else if(Type="Checkbox")
			Value:=Node.Checked
		else
			Value:=Node.Value
		if(Type~="i)\b(Checkbox)\b"||Node.nodeName~="i)\b(Input)\b")
			Value:=Type="Checkbox"?(Node.Checked?-1:0):Node.Value
		if(Function:=Func("Commit"))
			return Function.Call(Name,Node),ComObjError(1)
		if(this.ACommit||AutoCommit)
			this.Data[LV,OID,ID]:=Value
		if(!IsObject(OO:=this.ChangedObj[LV])&&ID)
			OO:=this.ChangedObj[LV]:=[],this.ChangedNode[LV]:=[]
		if(VV=Value)
			(this.IsLV(Node))?(this.FindParent(Node,"TD").Style.BackgroundColor:="",this.ChangedObj[LV,OID].Delete(ID),this.ChangedNode[LV,OID,ID]:=Node):((Node.nodeName="Select"?"":Node.Style.BackgroundColor:=""),this.ChangedObj[LV,OID].Delete(ID),this.ChangedNode[LV,OID,ID]:=Node)
		else
			(this.IsLV(Node))?((Node.nodeName="Select"?:this.FindParent(Node,"TD").Style.Background:=this.Changed),OO[OID,ID]:=Value,this.ChangedNode[LV,OID,ID]:=Node):((Node.nodeName="Select"?"":Node.Style.Background:=this.Changed),OO[OID,ID]:=Value,this.ChangedNode[LV,OID,ID]:=Node)
	}cleanHTML(Value){
		return RegExReplace(RegExReplace(Value,"'","&apos;"),"\&","&amp;")
	}Close(){
		HTMLGUI.Keep[A_Gui].Escape()
	}Convert_Hotkey(Key){
		StringUpper,Key,Key
		for a,b in [{Ctrl:"^"},{Win:"#"},{Alt:"!"},{Shift:"+"}]
			for c,d in b
				if(InStr(Key,d))
					Build.=c "+",Key:=RegExReplace(Key,"\" d)
		return Build Key
	}createElement(Type,Parent:="",Attributes:="",Style:="",Text:="",HTML:=""){
		local
		global MediaGrid
		for a,b in Style
			SSS.=(a)":"(b)";"
		if(Type="ListView"){
			New:=this.createElement("Div",Parent),New.innerHTML:=this.LVHTML(Text),New.setAttribute("Control",Text),this.MainGUI[Text]:=this.createElement("Style"),this.MainGUI[Text].innerText:="#"(Text)" Div.Container1{transform:translate(0px)}",this.Functions[Text]:=Attributes.Function,Attributes.ListView:=Text,Attributes.Type:="ListView",Attributes.Control:="ListView",New.ID:=Text
			;here
			this.ListViewStyles[Text]:=(this.createElement("Style"))
			this.Testing:=this.AddCSS("Testing",{"Margin-Top":"4px"})
			for a,b in Attributes
				New.setAttribute(a,b)
		}else if(Type="Checkbox")
			New:=this.createElement("Input",Parent,{ID:Attributes.ID,Type:"Checkbox",Language:Attributes.Language})
		else if(Type="TreeView"){
			New:=this.createElement("Div",Parent),New.ID:=Text,New.setAttribute("Control",Text),New.setAttribute("Tree",Text),this.MainGUI[Text]:=Attributes
			if(!Style.Border)
				New.Style.Border:="1px Solid Grey"
			New.Style.OverFlow:="Auto",New.setAttribute("Type","TreeView")
		}else if(Type="DDL"){
			New:=this.createElement("Select",Parent)
			for a,b in HTML
				New.AppendChild(Option:=this.Doc.createElement("Option")),Option.Value:=b.Value,Option.innerHTML:=b.Value,Option.setAttribute("OValue",b.Value),Option.setAttribute("Language",b.Language),Option.setAttribute("OID",(b.OID?b.OID:A_Index)),Option.setAttribute("Style",(b.Style?b.Style:SSS)),(b.Selected)?Option.setAttribute("Selected"):""
		}else if(Type="MediaGrid")
			New:=this.createElement("Div",Parent),New.ID:=Text,New.setAttribute("Control",Text),MG:=this.MediaGrid[Text]:=New this.MediaGridClass(this,Text,(Attributes.Border?Attributes.Border:8),Style)
		else
			New:=this.Doc.createElement(Type),(Parent?Parent:this.Doc.Body).AppendChild(New),(Text)?New.innerText:=Text:HTML?New.innerHTML:=HTML:""
		for a,b in Attributes
			(a="Timer")?(this.Timers[b.ID]:={Name:b.Name,Period:b.Period},New.setAttribute("Timer",b.ID)):New.setAttribute(a,b)
		for a,b in Style
			StyleObj:=New.Style,StyleObj[a]:=b
		if(Type="Input")
			New.setAttribute("oninput","OnInput(event)")
		if(Type="DDL")
			New.setAttribute("onchange","OnInput(event)")
		if(Type="Checkbox")
			Label:=this.createElement("Label",Parent,{Checkbox:Attributes.ID,Language:Attributes.Language},Style,HTML)
		return MG?MG:New
	}CurrentNode(){
		return this.Doc.activeElement
	}Del(Items:=""){
		Remove:=[],Associate:=[]
		for a,b in (Items?Items:this.DelBuild())
			LV:=b.LV,b.Node.parentNode.RemoveChild(b.Node),OID:=b.Node.querySelector("*[OID]").getAttribute("OID"),Remove[OID]:=1
		for a,b in this.Data[LV]
			if(Remove[b.OID])
				Associate[a]:=1
		for a,b in Associate
			this.Data[LV].Delete(a)
		this.LabelOrder(),this.SelectedCSS[LV].innerText:=""
		if(Func:=Func((LV)"_Delete"))
			Func.Call(Remove)
	}DelBuild(){
		Node:=this.Doc.ActiveElement,Delete:=[]
		if(LV:=this.IsLV(Node))
			for a,b in this.Selected[LV]
				Delete.Push({LV:LV,OID:a,Node:this.Doc.querySelector("Div[ListView='"(LV)"'] TD[OID='"(a)"']").parentNode})
		return Delete
	}Delete(){
		if((Active:=this.Doc.ActiveElement).nodeName="Input"){
			if(Active.SelectionStart=Active.SelectionEnd)
				Active.SetSelectionRange(Active.SelectionStart,Active.SelectionEnd+1)
			Send,{Backspace}
			return
		}if(Func:=Func("Delete"))
			return Func.Call(Obj)
		if(!(Obj:=this.DelBuild()).Count())
			return
		if(this.m("Delete "(Obj.Count())" item"(Obj.Count()=1?"":"s"),"Are you sure?","Btn:yn","Def:2")="YES")
			this.Del(Obj)
	}DeleteObj(LV){
		Delete:=[]
		for a,b in this.Selected[LV]
			Delete.Push({LV:LV,OID:a,Node:this.Doc.querySelector("Div[ListView='"(LV)"'] TD[OID='"(a)"']").parentNode})
		return Delete
	}DeleteCSS(Selector,Declaration){
		if(!this.Styles[Selector,Declaration])
			return
		this.Styles[Selector].Delete(Declaration),this.SetCSS(Selector)
	}Destroy(){
		Gui,% this.Win ":Destroy"
	}Directions(){
		Node:=this.CurrentNode(),LV:=Node.getAttribute("ListView"),Type:=Node.getAttribute("Type")
		if(Type="TreeView"){
			Sel:=Node.querySelector("*[Sel='1']")
			if(A_ThisHotkey="Down"){
				All:=Node.querySelectorAll("LI")
				while(aa:=All.Item[A_Index-1]){
					if(Start&&aa.offsetParent)
						return this.RemoveTVSel(Node),aa.setAttribute("Sel",1),this.TriggerFunction(aa),this.CenterTV(aa)
					if(aa.isSameNode(Sel))
						Start:=1
				}
				this.Tab(1)
			}else if(A_ThisHotkey="Up"){
				All:=Sel.previousSibling.querySelectorAll("LI")
				while(aa:=All.Item[All.Length-A_Index])
					if(aa.offsetParent)
						return this.RemoveTVSel(Node),aa.setAttribute("Sel",1),this.TriggerFunction(aa),this.CenterTV(aa)
				if(Prev:=Sel.previousSibling)
					return this.RemoveTVSel(Node),Prev.setAttribute("Sel",1),this.TriggerFunction(Prev),this.CenterTV(Prev)
				else if((Prev:=Sel.parentNode.parentNode).nodeName="LI")
					return this.RemoveTVSel(Node),Prev.setAttribute("Sel",1),this.TriggerFunction(Prev),this.CenterTV(Prev)
				this.TabShift()
			}else if(A_ThisHotkey="Left"){
				if(Sel.getAttribute("Expand"))
					Sel.setAttribute("Expand",""),this.TriggerFunction(Sel,"Contract"),this.CenterTV(Sel)
				else if((Parent:=Sel.parentNode.parentNode).nodeName="LI")
					this.RemoveTVSel(Node),Parent.setAttribute("Sel",1),this.TriggerFunction(Parent),this.CenterTV(Parent)
			}else if(A_ThisHotkey="Right"){
				if(!Sel.getAttribute("Expand")&&Sel.querySelector("LI"))
					Sel.setAttribute("Expand",1),this.TriggerFunction(Sel),this.CenterTV(Sel)
				else if(Sel.querySelector("LI"))
					this.RemoveTVSel(Node),(Child:=Sel.querySelector("LI")).setAttribute("Sel",1),this.CenterTV(Child)
			}
		}else if(LV){
			Row:=Node.getAttribute("Row"),Col:=Node.getAttribute("Col")
			if(A_ThisHotkey~="i)\b(Up|Down)\b")
				(NN:=this.LVTestXY(LV,Row+(A_ThisHotkey="Up"?-1:1),Col))?(NN.Focus(),(NN.nodeName="Input"?NN.Select():"")):(A_ThisHotkey="Up"?this.TabShift():this.Tab()),(NN?this.LastLV[LV]:=NN:0)
			else{
				if(Type="Text")
					Len:=StrPut(Node.Value,"UTF-8")-1,Start:=Node.selectionStart,End:=Node.selectionEnd
				if(Start=Len&&A_ThisHotkey="Right")
					return ((NN:=this.LVTestXY(LV,Row,Col+1))?(NN.Focus(),NN.getAttribute("Type")="Text"?NN.Select():""):((NN:=this.LVTestXY(LV,Row+1,1))?(NN.Focus(),(NN.getAttribute("Type")="Text"?NN.Select():"")):this.Tab())),(NN?this.LastLV[LV]:=NN:0)
				else if(!Start&&A_ThisHotkey="Left")
					return ((NN:=this.LVTestXY(LV,Row,Col-1))?(NN.Focus(),NN.getAttribute("Type")="Text"?NN.Select():""):((NN:=this.LVTestXY(LV,Row-1,this.ListViewControls[LV,Row-1].MaxIndex()))?(NN.Focus(),NN.getAttribute("Type")="Text"?NN.Select():""):this.TabShift())),(NN?this.LastLV[LV]:=NN:0)
				Send,{%A_ThisHotkey%}
			}
		}else if(Node.nodeName="Input"&&(Type="Text"||!Type)){
			Row:=Node.getAttribute("Row"),Col:=Node.getAttribute("Col")
			Len:=StrPut(Node.Value,"UTF-8")-1,Start:=Node.selectionStart,End:=Node.selectionEnd
			if(A_ThisHotkey~="i)\b(Up|Down)\b")
				return (A_ThisHotkey="Up"?this.TabShift():this.Tab())
			if(Start=Len&&A_ThisHotkey="Right")
				return this.Tab()
			else if(Start=0&&A_ThisHotkey="Left")
				return this.TabShift()
			Send,{%A_ThisHotkey%}
		}else if(Node.nodeName="Div"&&Type="MediaGrid"){
			this.MediaGrid[Node.ID].Directions(A_ThisHotkey)
		}else if(Node.nodeName="Select"&&A_ThisHotkey~="i)\b(Up|Down)\b"){
			Send,{%A_ThisHotkey%}
		}else if(A_ThisHotkey~="i)\b(Right|Down)\b")
			this.Tab()
		else
			this.TabShift()
	}DropFiles(Files,_,x,y){
		Mouse:=A_CoordModeMouse
		TT:=HTMLGUI.Keep[this]
		WinActivate,% TT.ID
		WinWaitActive,% TT.ID
		CoordMode,Mouse,Client
		MouseGetPos,x,y
		CoordMode,Mouse,%Mouse%
		element:=TT.Doc.elementFromPoint(x,y)
		Type:=element.getAttribute("Type")
		if(Type="MediaGrid"){
			Node:=TT.querySelector("Div[ID='"(element.ID)"']"),Drop:=Node.getAttribute("Drop")
			TT.GetFunc(Drop).Call(Files)
		}else if(Listview:=element.getAttribute("Listview")){
			if(Drop:=element.getAttribute("Drop"))
				TT.GetFunc(Drop).Call(Files)
			else
				Node:=TT.querySelector("Div[ID='"(Listview)"']"),Drop:=Node.getAttribute("Drop"),TT.GetFunc(Drop).Call(Files)
		}else if(Drop:=element.getAttribute("Drop"))
			TT.GetFunc(Drop).Call(Files)
		else if(IsFunc("DropFiles"))
			TT.GetFunc("DropFiles").Call(Files)
	}ea(Node){
		All:=Node.Attributes,ea:=[]
		while(aa:=All.Item[A_Index-1])
			ea[aa.nodeName]:=aa.Text
		return ea
	}Escape(){
		this:=HTMLGUI.Keep
		this.GetLast()
		if(this.Changed.MinIndex()){
			if((Result:=this.m("Saving changes?","btn:ync","def:3"))="Cancel")
				return
			if(Result="No")
				ExitApp
			if(Result="Yes")
				this.m("Save the changes!")
		}else if(Func:=Func((A_Gui)"Escape")){
			Func.Call()
		}else if(IsLabel(Label:=(A_Gui)"Escape")){
			KeyWait,Escape,U
			SetTimer,%Label%,-1
		}else if(Func:=Func((A_Gui)"Close")){
			Func.Call()
		}else if(IsLabel(Label:=(A_Gui)"Close")){
			KeyWait,Escape,U
			SetTimer,%Label%,-1
		}
	}EvenCSS(Color,ListView:="",Extra:=""){
		this.AddCSS((ListView?"Div[ListView='"(ListView)"'] ":"")"TBody tr:nth-child(odd){Background-Color:"(Color)";"(Extra)"}")
	}FindParent(Node,nodeName){
		while(Node.nodeName!=nodeName&&Node)
			Node:=Node.parentNode
		return Node
	}FixColumnHeaders(){
		All:=this.Doc.GetElementsByClassName("Outer"),AllObj:=[]
		while(aa:=All.Item[A_Index-1]){
			All1:=aa.GetElementsByTagName("Div"),AllObj.Push(OO:=[])
			while(aa1:=All1.Item[A_Index-1])
				if(InStr(aa1.ID,"Container"))
					OO[RegExReplace(aa1.ID,"\D")]:=aa1
		}for a,b in AllObj{
			Start:=2,All:=b.2.GetElementsByTagName("TH"),Fix:=b.1.GetElementsByTagName("Span"),Max:=[],ComObjError(0)
			while(aa:=All.Item[A_Index-1])
				Rect:=aa.GetBoundingClientRect(),Width:=Rect.Right-Rect.Left,Fix[A_Index-1].Style.Left:=Start,Fix[A_Index-1].Style.Width:=Width,Start+=Width
			ComObjError(1)
		}All:=this.Doc.querySelectorAll(".FixedHeader Span"),Max:=[]
		while(aa:=All.Item[A_Index-1])
			Rect:=aa.GetBoundingClientRect(),Max[aa.getAttribute("ListView"),Round(Rect.Bottom-Rect.Top)]:=1
		for a,b in Max
			this.ListViewStyles[a].innerText:=".Inner[ListView='"(a)"']{Margin-Top:"(b.MaxIndex())"px}"
	}FixIE(Version=0){
		static Key:="Software\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION",Versions:={7:7000,8:8888,9:9999,10:10001,11:11001}
		Version:=Versions[Version]?Versions[Version]:Version
		if(A_IsCompiled)
			ExeName:=A_ScriptName
		else
			SplitPath,A_AhkPath,ExeName
		RegRead,PreviousValue,HKCU,%Key%,%ExeName%
		if(!Version)
			RegDelete,HKCU,%Key%,%ExeName%
		else
			RegWrite,REG_DWORD,HKCU,%Key%,%ExeName%,%Version%
		return PreviousValue
	}Focus(Control){
		this.querySelector("*[ID='"(Control)"']").Focus()
	}FocusTree(Node){
		if(Node.getAttribute("Type")="TreeView"&&!this.querySelector("Div[ID='"(Node.ID)"'] *[Sel]"))
			this.querySelector("Div[ID='"(Node.ID)"'] LI").setAttribute("Sel",1)
	}GetBody(ExtraBodyStyle:=""){
		return (ExtraBodyStyle?Body:=RegExReplace(this.BodyHTML,"'>",";"(ExtraBodyStyle)"'>"):this.BodyHTML)
	}GetControl(Node){
		if(Node.getAttribute("Tree")||Node.getAttribute("ListView")||Node.getAttribute("Type")="MediaGrid"){
			while(!Node.getAttribute("Control")&&Node)
				Node:=Node.parentNode
		}
		return Node
	}GetDiv(Node){
		while(Node.nodeName!="Div"&&Node)
			Node:=Node.parentNode
		return Node
	}GetFunc(Function){
		if(Fun:=this.FunctionObj[Function])
			return Fun
		else if(IsFunc(Function))
			this.FunctionObj[Function]:=Func(Function)
		return this.FunctionObj[Function]
	}GetLI(Node){
		while(Node&&Node.nodeName!="LI")
			Node:=Node.parentNode
		return Node
	}GetLast(){
		Settings:=[]
		for a,b in v.Keys{
			if(this.Doc.querySelector("#Box #"(a)).Checked){
				Settings.Push({Key:"LastType",Value:a})
				Break
			}
		}
		Settings.Push({Key:"LastClip",Value:this.Current.1.getAttribute("OID")})
		if(Settings.1)
			DB.Insert("Settings",Settings,"Key")
	}GetParentFolder(Control,HTML:=1){
		Parent:=this.GetTV(Control).parentNode
		while(Parent.getAttribute("Type")!="Folder"&&Parent)
			Parent:=Parent.parentNode
		return HTML?Parent:Parent.getAttribute("OID")
	}GetParentTV(Control,HTML:=1){
		Parent:=this.GetTV(Control).parentNode
		while(Parent.nodeName!="LI"&&Parent)
			Parent:=Parent.parentNode
		return Parent
	}GetText(Screen,Value){
		return this.LanguageObj[Screen,Value,this.CurrentLanguage]
	}GetTV(Control,HTML:=1){
		Node:=this.querySelector("Div[ID='"(Control)"']").querySelector("LI[Sel]")
		return HTML?Node:Node.getAttribute("OID")
	}Hotkeys(Keys:=""){
		Keys:=IsObject(Keys)?Keys:[]
		Dir:=this.DirectionsObj
		for a,b in {Delete:this.Delete.Bind(this),"+Delete":this.Del.Bind(this),Tab:this.Tab.Bind(this),"+Tab":this.TabShift.Bind(this),Left:Dir,Right:Dir,Up:Dir,Down:Dir,"^WheelUp":"DeadEnd","^WheelDown":"DeadEnd"}
			Keys[a]:=b
		Hotkey,IfWinActive,% this.ID
		for a,b in this.HotkeyList{
			if(RegExMatch(a,"i)(\+Delete|\+Tab|Delete|Tab)"))
				Continue
			Hotkey,%a%,Off
		}this.HotkeyList:=[]
		for a,b in Keys{
			Hotkey,%a%,%b%,On
			this.HotkeyList[a]:=b
		}
	}IsLV(Node){
		return Node.getAttribute("ListView")
	}LabelOrder(){
		;~ All:=this.Doc.All
		this.TabOrder:=[],Row:=0,Column:=0,All:=this.QuerySelectorAll("Button,Input,Select,Div[Control='ListView'],Div[Type='TreeView'],Div[Type='MediaGrid'][Class='Main']"),this.ListViewControls:=[]
		while(aa:=All.Item[A_Index-1]){
			ListView:=aa.getAttribute("ListView")
			if(ListView&&aa.nodeName!="Div"){
				OID:=aa.getAttribute("OID")
				if(LastOID)
					(OID=LastOID?(LVCol++):(LVRow++,LVCol:=1))
				this.ListViewControls[ListView,LVRow,LVCol]:=aa
				aa.setAttribute("Row",LVRow)
				aa.setAttribute("Col",LVCol)
				LastOID:=OID
				Continue
			}else if(Listview&&aa.getAttribute("Control")){
				LVRow:=LVCol:=1,aa.setAttribute("Row",Row),aa.setAttribute("Col",Column),this.TabOrder[Row,Column]:=aa,Row++
				Continue
			}if(ListView&&Row)
				OID:=aa.querySelector("*[OID]").getAttribute("OID")
			if(aa.nodeName="Button"){
				aa.setAttribute("Row",Row)
				aa.setAttribute("Col",Column)
				this.TabOrder[Row,Column]:=aa
				(Listview?Col++:Row++)
			}if(aa.nodeName="TR")
				aa.setAttribute("Row",Row)
			if(aa.nodeName="Input"||aa.nodeName="Select"){
				if(aa.getAttribute("Name")&&aa.getAttribute("Name")=LastName){
					aa.setAttribute("Row",Row),aa.setAttribute("Column",Column)
					Continue
				}if(!(LP:=(ListView?this.FindParent(aa,"TR"):aa.parentNode)).IsSameNode(LastParent))
					Row++,Column:=1
				aa.setAttribute("Row",Row)
				this.TabOrder[Row,Column]:=aa
				aa.setAttribute("Col",Column++)
				LastParent:=LP
				LastName:=aa.getAttribute("Name")
				ID:=aa.getAttribute("OID")
				if(Value:=this.Changed[Row,ID])
					aa.Value:=Value,aa.parentNode.Style.BackgroundColor:="Red"
			}if(aa.nodeName="Div"&&aa.getAttribute("Type")="TreeView"){
				Row++,Column:=1
				aa.setAttribute("Row",Row)
				this.TabOrder[Row,Column]:=aa
				aa.setAttribute("Col",Column),Column++
			}if(aa.nodeName="Div"&&aa.getAttribute("Type")="MediaGrid"){
				Row++,Column:=1
				aa.setAttribute("Row",Row)
				this.TabOrder[Row,Column]:=aa
				aa.setAttribute("Col",Column),Column++
			}
		}
	}LVDelete(ListView,Items:=""){
		if(!Items)
			return Node:=this.Doc.querySelector("Div[ListView='"(ListView)"'] TBody"),Parent:=Node.parentNode,Parent.RemoveChild(Node),this.createElement("TBody",Parent)
	}LVHTML(ListView,Width:="calc(100% - 2px)",Height:="calc(100% - 2px)",Function:=""){
		Total.="<Div Class='Outer' ID='" ListView "' ListView='"(ListView)"' Style='Width:"(Width)";Height:"(Height)"'><Div ID='Container1' Class='Container1'></Div><Div Class='Inner' onscroll='scroll(event)' ID='Inner' Ident='Inner' ListView='"(ListView)"' Style='Width:100%'><Div ID='Container2' Class='Container2' Style='Margin-Left:2px;Margin-Right:2px;Margin-Top:0px' onscroll='scroll(event)'></Div></Div></Div>"
		return Total
	}m(x*){
		static List:={Btn:{OC:1,ARI:2,YNC:3,YN:4,RC:5,CTC:6},Ico:{"x":16,"?":32,"!":48,"i":64}},Msg:=[],Title
		List.Title:=this.ProgramName,List.Def:=0,List.Time:=0,Value:=0,Txt:=""
		WinGetTitle,Title,A
		for a,b in x
			Obj:=StrSplit(b,":"),(VV:=List[Obj.1,Obj.2])?(Value+=VV):(List[Obj.1]!="")?(List[Obj.1]:=Obj.2):TXT.=(b.XML?b.XML:IsObject(b)?this.Obj2String(b):b) "`n"
		Msg:={Option:Value+262144+(List.Def?(List.Def-1)*256:0),Title:List.Title,Time:List.Time,Txt:Txt}
		Sleep,120
		MsgBox,% Msg.Option,% Msg.Title,% Msg.Txt,% Msg.Time
		for a,b in {OK:value?"OK":"",Yes:"YES",No:"NO",Cancel:"CANCEL",Retry:"RETRY"}
			IfMsgBox,%a%
				return b
		return
	}Menu(Node){
		if(!IsObject(Node)){
			this.BuildMenu(this.AllMenus[Node])
		}else{
			Node:=this.GetControl(Node)
			m(Node)
		}
	}Menus(MenuName,Menu){
		this.AllMenus[MenuName]:=Menu
	}MinSize(W:=100,H:=100){
		Gui,% this.Win ":+MinSize"(W)(H?"x"(H):"")
		Pos:=this.WinPos()
		if(Pos.W&&(Pos.W<W||Pos.H<H))
			WinMove,% this.ID,,,,1
	}Obj2String(Obj,FullPath:=1,BottomBlank:=0){
		static String,Blank
		if(FullPath=1)
			String:=FullPath:=Blank:=""
		Try{
			if(Obj.XML){
				String.=FullPath Obj.XML "`n",Current:=1
			}
		}
		Try{
			if(Obj.outerHtml){
				String.=FullPath Obj.outerHtml "`n",Current:=1
			}
		}if(!Current){
			if(IsObject(Obj)){
				for a,b in Obj{
					if(IsObject(b)&&b.outerHtml)
						String.=FullPath "." a " = " b.outerHtml "`n"
					else if(IsObject(b)&&!b.XML)
						this.Obj2String(b,FullPath "." a,BottomBlank)
					else{
						if(BottomBlank=0)
							String.=FullPath "." a " = " (b.XML?b.XML:b) "`n"
						else if(b!="")
							String.=FullPath "." a " = " (b.XML?b.XML:b) "`n"
						else
							Blank.=FullPath "." a " =`n"
					}
				}
			}
		}
		return String Blank
	}OddCSS(Color,ListView:="",Extra:=""){
		this.AddCSS((ListView?"Div[ListView='"(ListView)"'] ":"")"TBody tr:nth-child(even){Background-Color:"(Color)";"(Extra)"}")
	}querySelector(Query){
		return this.Doc.querySelector(Query)
	}querySelectorAll(Query){
		return this.Doc.QuerySelectorAll(Query)
	}RemoveTVSel(Node){
		All:=Node.querySelectorAll("*[Sel]")
		while(aa:=All.Item[A_Index-1])
			aa.removeAttribute("Sel")
	}Reset(HTML:=""){
		this.WB.Navigate("about:blank")
		while(this.WB.ReadyState!=4)
			Sleep,10
		Font:="Color:"(this.HeaderColor)";Font-Size:" this.Size "px;Background:"(this.Background)
		this.Doc.Body.outerHTML:="<Head></Head><Body Style='Width:calc(100% - 4);Margin:0px;' ondrop='return false;'>",this.Doc.Body.innerHTML:=HTML
		for a,b in ["Body{"(Font)"}",".Container1 TH{Visibility:Hidden}",".Outer{Border:1px Solid Grey;OverFlow:Hidden;Display:Block}","TH Span{White-Space:NoWrap;Visibility:Visible;Position:Absolute;Text-Align:Center;"(Font)"}"
				 ,".Inner{OverFlow:Auto;Width:100%;Height:calc(100% - "(this.Size)"px)}",".Container2 TD{White-Space:NoWrap}",".Container2 TH{White-Space:NoWrap;Visibility:Hidden;Line-Height:0px;"(Font)"}"
				 ,"UL,LI{list-style-type:None}","Div[Type='TreeView']:focus LI[Sel='1']>Span[ID='Label']{Background:"(this.TreeViewSelectColor)";Border:0px}","Div[Type='TreeView'] LI[Sel='1']>Span[ID='Label']{Background:'';Border:1px Solid "(this.TreeViewUnFocusedBorderColor)"}"
				 ,"LI[Expand='1'][Type='Folder']>UL,LI{Display:Block}","LI[Expand='']>Span[ID='Icon'].Open{Display:None}","LI[Expand='1']>Span[ID='Icon'].Closed{Display:None}","LI[Expand='']>UL{Display:None;Visibility:Hidden}"
				 ,"td{Border:1px Solid Grey;Padding:8px}","Body{Background-Color:"(this.Background)";Color:"(this.Color)";-MS-User-Select:None;-MS-Content-Zooming:none;-ms-touch-action: none}","Table{Border-Collapse:Collapse;Border-Spacing:0;Width:100%}","Input:Focus{Background:#444;Color:#FFF;Border:2px Solid Orange}","Input{Background:"(this.Background)";Color:"(this.Color)"}",".Title{Color:"(this.TitleColor)"}"
				 ,"HTML{-ms-touch-action: none}"
				 ,"Div[Type='RCM'] LI,UL{Margin:0px}"
				 ,"Div[Type='RCM'] LI:Hover>UL{Display:Block}"
				 ,"Div[Type='RCM'] LI{Display:Block;Float:Left;Clear:Left}"
				 ,"Div[Type='RCM'] LI{ font-weight: bold; float: left; zoom: 1; background:"(this.Background)"; }"
				 ,"Div[Type='RCM'] UL{Display:None}"]
			this.AddCSS(b)
		for a,b in {onclick:"Click",ondblclick:"DoubleClick",scroll:"scroll",OnInput:"OnInput",Change:"Change",Search:"Search",oncontextmenu:"Mouse",onmouseleave:"Leave"}
			this.createElement("Script").innerText:=a "=function(" a "){ahk_event('" b "',event)};"
		this.createElement("Script").innerText:="clickIcon=function(clickIcon){ahk_event('clickIcon',event)};"
		this.Columns:=[],this.Data:=[],this.LastSelected:=[],this.Styles:=[],this.StylesObj:=[],this.SelectedCSS:=[]
		return this.Doc.ParentWindow.ahk_event:=this._Event.Bind(this)
	}Revert(){
		All:=this.querySelectorAll("Input[OValue],Select[OValue]")
		while(aa:=All.Item[A_Index-1]){
			if(!aa.getAttribute("IgnoreState")){
				Value:=((Type:=aa.getAttribute("Type"))="Checkbox"?aa.Checked:aa.nodeName="Input"?aa.Value:aa.getAttribute("Value")),OValue:=aa.getAttribute("OValue")
				if(Type="Checkbox")
					aa.Checked:=(OValue?-1:0)
				else if(aa.nodeName="Input")
					aa.Value:=OValue
				else if(aa.nodeName="Select"){
					aa.querySelector("Option[OID='"this.cleanHTML(OValue)"']").setAttribute("Selected")
				}
				this.CheckUpdated(aa)
			}
		}
	}SetSel(LV,OID){
		static LastSel:=[]
		if(!LV)
			return
		for a,b in this.Selected[LV]
			Sel.="TR[ListView='"(LV)"'] TD[OID='"(a)"']{Background-Color:"(this.Highlight)"}`n"
		this.SelectedCSS[LV].innerText:=Sel,this.LastSelected[LV]:=OID,LastSel[LV]:=this.Selected[LV].Clone()
	}SetAllOValues(){
		this.Window.Eval("var all=document.querySelectorAll('Option');for(let i=0; i<all.length; i++){let node=all[i];node.setAttribute('OValue',node.innerText)}all=document.querySelectorAll('Select,Input,Span');for(let i=0; i<all.length; i++){let aa=all[i];if(!aa.getAttribute('Tree')){var Value=aa.nodeName=='SPAN'?aa.innerText:aa.nodeName=='INPUT'&&aa.getAttribute('Type')=='Checkbox'?(aa.checked?'-1':'0'):aa.nodeName=='SELECT'?aa.querySelector('Option[Selected]').getAttribute('OID'):aa.value;aa.setAttribute('OValue',(Value?Value:'')); }}")
	}SetCSS(Selector){
		for a,b in this.Styles[Selector]
			String.=a ":" b ";"
		if(!Node:=this.StylesObj[Selector])
			Node:=this.createElement("Style"),this.StylesObj[Selector]:=Node
		Node.innerText:=Selector "{"(String)"}"
		return Node
	}SetCurrentLanguage(Language){
		this.CurrentLanguage:=Language
	}SetLanguageObj(Obj){
		this.LanguageObj:=Obj
	}SetScreen(Screen){
		this.CurrentScreen:=Screen
	}Show(xOrHWND:="Center",y:="Center",w:=200,h:=200,Pos:=0){
		if(WinExist("ahk_id"xOrHWND)&&Pos=0){
			WinGetPos,X,Y,WW,HH,ahk_id%xOrHWND%
			X:=Floor((WW-W)/2)+X,Y:=Floor((HH-H)/2)+Y
			Gui,% this.Win ":Show",x%x% y%y% w%w% h%h%,% this.ProgramName
		}else{
			Gui,% this.Win ":Show",x%xOrHWND% y%y% w%w% h%h%,% this.ProgramName
			Gui,% this.Win ":+MinSize"(W)"x"(H)
		}
		this.Size(),this.LabelOrder() ;,this.Tab()
	}Size(Info:="",W:="",H:=""){
		static WW,HH
		this:=IsObject(this)?this:(HTMLGUI.Keep[A_Gui]),(W&&H)?(WW:=W,HH:=H):!W||!H?(W:=WW,H:=HH):"",DllCall("SetWindowPos",UPtr,this.Controls.Main.HWND,Int,0,"Int",0,"Int",0,"Int",W,"Int",H,"UInt",0x0020),this.FixColumnHeaders()
		for a,b in this.MediaGrid
			b.Size(W,H)
	}Tab(UpDown:=0){
		NN:=this.Doc.ActiveElement,Row:=NN.getAttribute("Row"),Col:=NN.getAttribute("Col"),Type:=NN.getAttribute("Type"),Listview:=NN.getAttribute("Listview")
		if(ListView)
			NN:=this.querySelector("Div[Type='ListView'][ID='"(ListView)"']"),Row:=NN.getAttribute("Row"),Col:=NN.getAttribute("Col")
		if(Type="MediaGrid")
			NN:=this.querySelector("Div[ID='"(NN.ID)"'][Type='MediaGrid']"),Row:=NN.getAttribute("Row"),Col:=NN.getAttribute("Col")
		if((!Row||!Col)&&(this.Row&&this.Col))
			Row:=this.Row,Col:=this.Col
		if(Row=""&&Col="")
			Node:=this.querySelector("*[Row='"(Row:=this.TabOrder.MinIndex())"'][Col='"(this.TabOrder[Row].MinIndex())"']")
		else{
			for a,b in this.TabOrder[Row]
				if(a>Col){
					Node:=b
					Break
				}
			if(!Node){
				for a,b in this.TabOrder{
					if(a>Row){
						Node:=this.TabOrder[a,this.TabOrder[a].MinIndex()]
						Break
					}
				}
			}
			if(!Node)
				Node:=this.querySelector("*[Row='"(Row:=this.TabOrder.MinIndex())"'][Col='"(this.TabOrder[Row].MinIndex())"']")
			this.Row:=Node.getAttribute("Row"),this.Col:=Node.getAttribute("Col")
		}(Node.getAttribute("Type")="Listview")?(this.LastLV[(ListView:=Node.getAttribute("ListView"))]?(this.LastLV[ListView].Focus()):((this.LastLV[ListView]:=NN:=Node.querySelector("Input,Select")).Focus(),(NN.getAttribute("Type")="Text"?NN.Select():""))):(Node.Focus(),(Node.nodeName="Input"?Node.Select():""),this.FocusTree(Node))
	}TabShift(){
		Node:=this.Doc.ActiveElement,Row:=Node.getAttribute("Row"),Col:=Node.getAttribute("Col"),ListView:=Node.getAttribute("ListView")
		if(ListView)
			Node:=this.querySelector("Div[Type='ListView'][ID='"(ListView)"']"),Row:=Node.getAttribute("Row"),Col:=Node.getAttribute("Col")
		if(Node.getAttribute("Type")="MediaGrid"&&!Row)
			Node:=this.querySelector("Div[ID='"(Node.ID)"'][Type='MediaGrid']"),Row:=Node.getAttribute("Row"),Col:=Node.getAttribute("Col")
		if(Row=""&&Col="")
			Node:=this.querySelector("*[Row='"(this.TabOrder.MaxIndex())"'][Col='"(this.TabOrder[this.TabOrder.MaxIndex()].MaxIndex())"']")
		else{
			if(!Node:=this.querySelector("*[Row='"(Row)"'][Col='"(Col-1)"']")){
				while(!this.TabOrder[--Row]&&Row>=0)
					Col:=this.TabOrder[Row].MaxIndex()
				Node:=this.querySelector("*[Row='"(Row)"'][Col='"this.TabOrder[Row].MaxIndex()"']")
			}if(!Node)
				Node:=this.querySelector("*[Row='"(this.TabOrder.MaxIndex())"'][Col='"(this.TabOrder[this.TabOrder.MaxIndex()].MaxIndex())"']")
		}(Node.getAttribute("Type")="Listview")?(this.LastLV[(ListView:=Node.getAttribute("ListView"))]?(this.LastLV[ListView].Focus()):((this.LastLV[ListView]:=NN:=this.ListViewControls[ListView,(Max:=this.ListViewControls[ListView].MaxIndex()),this.ListViewControls[ListView,Max].MaxIndex()]).Focus(),(NN.getAttribute("Type")="Text"?NN.Select():""))):(Node.Focus(),(Node.nodeName="Input"?Node.Select():""),this.FocusTree(Node))
	}LVTestXY(ListView,Row,Col){
		return this.querySelector("Div[ListView='"(ListView)"'] *[Row='"(Row)"'][Col='"(Col)"']")
	}TriggerFunction(Node,Action:=""){
		static Functions:=[]
		if(Function:=Node.getAttribute("Function")){
			if(!Obj:=Functions[Function])
				Obj:=Functions[Function]:=Func(Function)
			ea:=[],All:=Node.attributes
			while(aa:=All.Item[A_Index-1])
				ea[aa.nodeName]:=aa.Value
			Obj.Call(Action,"",ea)
		}
	}TVFocus(Control){
		this.querySelector("Div[ID='"(Control)"']").Focus()
	}TVSetSel(Control,OID){
		All:=this.querySelectorAll("Div[ID='"(Control)"'] LI[Sel]")
		while(aa:=All.Item[A_Index-1])
			aa.removeAttribute("Sel",0)
		this.querySelector("Div[ID='"(Control)"'] LI[OID='"(OID)"']").setAttribute("Sel",1)
	}UpdateLanguage(){
		while(aa:=this.QuerySelectorAll("*[Language]").Item[A_Index-1])
			if(Language:=aa.getAttribute("Language"))
				(Node:=aa.querySelector("Span[ID='Label']"))?Node.innerHTML:=this.LanguageObj[this.CurrentScreen,Language,this.CurrentLanguage]:aa.nodeName="Input"?"":aa.innerHTML:=this.LanguageObj[this.CurrentScreen,Language,this.CurrentLanguage]
	}Values(){
		All:=GG.querySelectorAll("Input,Select"),Values:=[]
		while(aa:=All.Item[A_Index-1]){
			OID:=aa.getAttribute("OID")
			if(LV:=aa.getAttribute("ListView")){
				if(!Obj:=Values[LV])
					Obj:=Values[LV]:=[]
				Obj[OID,aa.ID]:=(aa.getAttribute("Type")="Checkbox"?aa.Checked:aa.Value)
			}else if(aa.nodeName="Select")
				Values[aa.ID,aa.querySelector("Option[Selected]").getAttribute("OID")]:=aa.Value
			else if(aa.nodeName="Input")
				Values[aa.ID]:=(aa.getAttribute("Type")="Checkbox"?aa.Checked:aa.Value)
		}All:=GG.querySelectorAll("Div[Type='Treeview']")
		while(aa:=All.Item[A_Index-1])
			Node:=aa.querySelector("LI[Sel]"),Values[aa.ID,Node.getAttribute("OID")]:=Node.querySelector("#Label").innerText
		for a,b in this.Mediagrid{
			while(aa:=b.Div.querySelectorAll("Div[Selected]").Item[A_Index-1])
				Values[a].=(Values[a]?",":"")(aa.getAttribute("OID"))
		}
		return Values
	}WinPos(HWND:=""){
		HWND:=HWND?HWND:this.HWND,VarSetCapacity(Rect,16)
		WinGetPos,X,Y,,,ahk_id%HWND%
		DllCall("GetClientRect",Ptr,HWND,Ptr,&Rect),W:=NumGet(Rect,8,"Int"),H:=NumGet(Rect,12,"Int"),Text:="X" X " Y" Y " W" W " H" H
		return {X:X,Y:Y,W:W,H:H,Text:Text}
	}
	Class MediaGridClass{
		__New(HGUI,DivID:="Grid",Border:=8,Options:=""){
			for a,b in {Count:9,VideoBackground:"#CC00CC",Volume:.2}
				this[a]:=(Options[a]?Options[a]:b)
			for a,b in Options
				this[a]:=b
			this.HGUI:=HGUI,this.DivID:=DivID,this.Doc:=HGUI.Doc,HGUI.IG:=this,this.AddColor:=0x303030,this.Border:=Border,this.Div:=this.Doc.querySelector("#"(DivID)),this.Div.setAttribute("Type","MediaGrid"),this.Div.setAttribute("Class","Main"),this.Selected:=[],this.ChangeSel:=this.SetSelect.Bind(this)
			for a,b in {OverAll:".Div{OverFlow:Hidden;Float:Left;Background-Color:"(HGUI.Background)";Text-Align:Center;Position:Relative;Border:6px Solid Grey;Border-Radius:6px} .Div:After{Content:'';Display:Inline-Block;Vertical-Align:Middle}"
				 ,Division:".Div{Width:calc(33.333333`% - 16px);Height:calc(33.33333`% - 16px)}",DivAfter:"Img{Margin-Top:50`%;Margin-Bottom:Auto}",Labels:"Div[Type='MediaGrid'] Span{Display:Block;Text-Align:Center;Width:100%;Background-Color:"(this.HGUI.Background)";Bottom:0px;Font-Size:20px;Position:Absolute;Opacity:.7}"
				 ,Focus:"Div[Type='MediaGrid']:Focus Span{Background:#303030}"}
				this.cElement("Style",a).innerText:=b
			this.SetStates()
		}Click(Node){
			this.Playing.Pause(),this.NoCurrent(),Node:=this.GetDiv(Node),(GetKeyState("Shift")||GetKeyState("Ctrl"))?(Node.hasAttribute("Selected")?Node.removeAttribute("Selected"):Node.setAttribute("Selected")):0,Node.setAttribute("Current"),this.Highlight(),(this.HGUI.GetControl(Node).getAttribute("AutoPlay")?((Vid:=Node.querySelector("Video")).SRC?(this.Playing:=Vid,(Vid.Paused?Vid.Play():Vid.Pause())):0):0)
		}cElement(Type,ID:=""){
			return New:=this.Doc.createElement(Type),this.Doc.Body.AppendChild(New),(ID?New.ID:=ID:"")
		}CurrentMedia(){
			return this.querySelector("Div[ID='"(this.DivID)"'] Div[Current]")
		}DirectionHotkeys(Keys:=""){
			Keys:=IsObject(Keys)?Keys:[]
			for a,b in ["Left","Right","Up","Down"]
				if(!Keys[b])
					Keys[b]:=b
			Hotkey,IfWinActive,% this.HGUI.ID
			this.HotkeyDirections:=[],Dir:=this.DirectionBind
			for a,b in Keys{
				Hotkey,%a%,%Dir%,On
				this.HotkeyDirections[a]:=b
			}
		}Directions(a*){
			static Functions:=[]
			Key:=(a.1&&!a.2?a.1:A_ThisHotkey)
			if(!Node:=this.Div.querySelector("*[Current]"))
				return (Node:=this.Div.querySelector("*[X='1'][Y='1']")).setAttribute("Current"),Node.Focus(),this.Highlight()
			if(!(PN:=Node.querySelector("Video")).Paused&&this.HGUI.GetControl(PN).getAttribute("AutoPlay"))
				PN.Pause()
			if(Node.ID!=this.DivID){
				Fun:=this.HotkeyDirections[Key]
				if(!Functions[Fun]&&IsFunc(Fun))
					Functions[Fun]:=Func(Fun)
				if(FF:=Functions[Fun])
					FF.Call(Key)
				return
			}if(NN:=Doc.querySelector("Div[ID='"(this.DivID)"'] Div[Selected]"))
				NN.removeAttribute("Current")
			if(a.1&&a.2){
				(this.TestXY(a.1,a.2))?(X:=a.1,Y:=a.2):(X:=Y:=1),Node:=this.Doc.querySelector(Foo:="Div[ID='"(this.DivID)"'] Div[X='"(X)"'][Y='"(Y)"']")
			}else if(!(X:=Node.getAttribute("X"))||!(Y:=Node.getAttribute("Y"))){
				X:=Y:=1,Node:=this.Doc.querySelector(Foo:="Div[ID='"(this.DivID)"'] Div[X='"(X)"'][Y='"(Y)"']")
			}else{
				Node:=this.Doc.querySelector(Foo:="Div[ID='"(this.DivID)"'] Div[X='"(X)"'][Y='"(Y)"']").Style.Border:=(this.Border)"px Solid "(this.NoSelectedColor)
				if(Key="Down")
					Y:=(this.Doc.querySelector(Foo:="Div[ID='"(this.DivID)"'] Div[X='"(X)"'][Y='"(Y+1)"']")?Y+1:1)
				else if(Key="Right"){
					(this.TestXY(X+1,Y)?(X++):(Y<this.Y?(Y++,X:=1):(X:=1,Y:=1)))
				}else if(Key="Up"){
					if(this.Doc.querySelector(Foo:="Div[ID='"(this.DivID)"'] Div[X='"(X)"'][Y='"(Y-1)"']"))
						Y:=Y-=1
					else if((YY:=this.Y)>1){
						while(!this.TestXY(X,YY))
							YY--
						Y:=YY
					}
				}else if(Key="Left"){
					(this.TestXY(X-1,Y)?(X--):(Y>1?(Y--,X:=this.X):X:=""))
					if(X=""){
						Y:=this.Y,XX:=this.X
						while(!this.TestXY(XX,Y))
							XX--
						X:=XX
					}
				}Node:=this.Doc.querySelector(Foo:="Div[ID='"(this.DivID)"'] Div[X='"(X)"'][Y='"(Y)"']")
			}this.querySelector("Div[Current]").removeAttribute("Current"),Node.setAttribute("Current"),Node.Focus(),this.Highlight(),((PN:=Node.querySelector("Video"))&&this.HGUI.GetControl(PN).getAttribute("AutoPlay")?PN.Play():0)
		}DoubleClick(Node){
			Node:=this.GetDiv(Node)
			this.NoCurrent(),Node.setAttribute("Current"),(Node.hasAttribute("Selected")?Node.removeAttribute("Selected"):Node.setAttribute("Selected")),this.Highlight()
		}GetDiv(Node){
			while(Node.nodeName!="Div"&&Node)
				Node:=Node.parentNode
			return Node
		}GetSelected(Selected:=0){
			All:=this.Doc.querySelectorAll("Div[ID='"(this.DivID)"'] Div"),Selected:=[]
			while(aa:=All.Item[A_Index-1]){
				if(aa.hasAttribute("Selected"))
					Selected.Push(aa.getAttribute("OID"))
			}
			if(Selected.Count()=0&&!Selected){
				if(OID:=this.Doc.querySelector(Foo:="Div[ID='"(this.DivID)"'] Div[Current]").getAttribute("OID"))
					Selected.Push(OID)
			}
			return Selected
		}Highlight(){
			All:=this.Doc.querySelectorAll("Div[ID='"(this.DivID)"'] Div"),CC:="0x"(this.States.Normal),Sel:="0x"(this.States.Selected)
			while(aa:=All.Item[A_Index-1]){
				Current:=aa.hasAttribute("Current"),Selected:=aa.hasAttribute("Selected")
				Obj:=this.Media[aa.getAttribute("OID")],State:=""
				for a,b in this.States{
					if(Obj[a]){
						State:="0x"this.States[a]
						Break
					}
				}
				if(Selected)
					aa.Style.Border:=(this.Border)"px Solid "("#"SubStr(Format("{:X}",(Selected?Sel:CC)+(Current?this.AddColor:0)),1,6))
				else if(State)
					aa.Style.Border:=(this.Border)"px Solid "("#"(Current?SubStr(Format("{:X}",State+0x303030),1,6):Format("{:X}",State)))
				else
					aa.Style.Border:=(this.Border)"px Solid "("#"SubStr(Format("{:X}",(Selected?Sel:CC)+(Current?this.AddColor:0)),1,6))
			}
		}NoCurrent(){
			All:=this.Div.querySelectorAll("Div[Current]")
			while(aa:=All.Item[A_Index-1])
				aa.removeAttribute("Current")
		}Populate(Media,Current:=1){
			this.X:=Ceil(Sqrt(Media.Count())),this.Y:=Round(Sqrt(Media.Count())),this.Media:=[]
			X:=Y:=1
			for a,b in Media{
				this.Media[b.OID]:=b
				List.="<Div Menu='"(b.Menu)"' "(b.Current||A_Index=Current?"Current":"")" OID='"(b.OID)"' X='"(X)"' Y='"(Y)"' Class='Div' Type='MediaGrid' ID='"(this.DivID)"' Style='Border-Radius:"(this.Border)"px;Border:"(this.Border)"px Solid Grey;Float:Left'>"
				List.="<Video OID='"(b.OID)"' X='"(X)"' Y='"(Y)"' ID='"(this.DivID)"' Type='MediaGrid' Style='Display:None;vertical-align: middle;Max-Width:100%;Max-Height:100%;Background:"(this.VideoBackground)"'></Video>"
				List.="<Img OID='"(b.OID)"' X='"(X)"' Y='"(Y)"' ID='"(this.DivID)"' Type='MediaGrid' Style='vertical-align: middle;Max-Width:100%;Max-Height:100%'></Img>"
				List.="<Span Type='MediaGrid' Language='"(b.Language)"' ID='"(this.DivID)"' X='"(X)"' Y='"(Y)"'>"(b.Text)"</Span></Div>"
				X++,(X>this.X)?(X:=1,Y++):""
			}this.querySelector("Div[ID='"(this.DivID)"']").innerHTML:=List
			for a,b in Media{
				Node:=this.querySelector(Foo:="Div[ID='"(this.DivID)"'] Div:nth-of-type("(A_Index)")")
				(SubStr(b.SRC,-2)="mp4")?((Vid:=Node.querySelector("Video")).SRC:=b.SRC,Vid.Style.Display:="Inline-Block",Node.querySelector("Img").Style.Display:="None",Node.Style.Background:=this.VideoBackground,Node.querySelector("Video").Volume:=this.Volume):((Img:=Node.querySelector("Img")).SRC:=b.SRC,Img.Style.Display:="Inline-Block",Node.querySelector("Video").Style.Display:="None",Node.Style.Background:=this.HGUI.Background)
			}this.querySelector("#Division").innerText:=".Div{Width:calc("(100/this.X)"% - "(this.Border*2)"px);Height:calc("(100/this.Y)"% - "(this.Border*2)"px)}",this.Highlight(),(this.Div.getAttribute("AutoPlay")?((Vid:=this.Div.querySelector("Div[Current] Video")).SRC?Vid.Play():0):0)
		}querySelector(Query){
			return this.Doc.querySelector(Query)
		}querySelectorAll(Query){
			return this.Doc.querySelectorAll(Query)
		}RemoveMediaState(OID:=""){
			this.querySelector((OID?"Div[OID='"(OID)"']":"Div[Current]")).removeAttribute("State"),this.Highlight()
		}Select(a,b,c){
			Node:=c.nodeName="Div"?c:c.parentNode
			if(a="DoubleClick"){
				if(Node.querySelector("Video").Style.Display="None")
					return (Node.hasAttribute("Selected")?Node.removeAttribute("Selected"):Node.setAttribute("Selected")),this.Highlight()
				(Node:=Node.querySelector("Video")?((!Node.Paused)?Node.Play():Node.Pause()):0)
			}else if(a="Click"){
				if(GetKeyState("Shift")||GetKeyState("Control"))
					(Node.hasAttribute("Selected")?Node.removeAttribute("Selected"):Node.setAttribute("Selected"))
				else{
					while(aa:=this.querySelectorAll("Div[ID='"(this.DivID)"'] Div").Item[A_Index-1])
						aa.removeAttribute("Selected"),aa.removeAttribute("Current")
					Node.setAttribute("Current")
				}this.Highlight()
		}}SelectHotkeys(Keys:=""){
			this.MediaKeys:=IsObject(Keys)?Keys:[]
			for a,b in {Space:"Select","+Left":"All_Left","+Up":"All_Up","+Right":"All_Right","+Down":"All_Down","^a":"Select_All",p:"Play_Pause"}
				this.MediaKeys[a]:=b
			Hotkey,IfWinActive,% this.HGUI.ID
			Sel:=this.ChangeSel
			for a,b in this.MediaKeys
				Hotkey,%a%,%Sel%,On
		}SetMediaState(State,OID:=""){
			(State?(Node:=this.querySelector((OID?"Div[OID='"(OID)"']":"Div[Current]")),Node.setAttribute("State",State),this.Highlight()):0)
		}SetStates(Colors:=""){
			this.States:=[]
			for a,b in {Selected:"AA0088",Normal:"CCCCCC"}
				Color:=Trim(b,"#"),this.States[a]:=Color
			for a,b in Colors
				Color:=Trim(b,"#"),this.States[a]:=Color
		}SetSelect(a*){
			if(this.Doc.activeElement.getAttribute("Type")!="MediaGrid"){
				Send,{%A_ThisHotkey%}
				return
			}Node:=this.Div.querySelector("Div[Current]"),X:=Node.getAttribute("X"),Y:=Node.getAttribute("Y"),Key:=SubStr(A_ThisHotkey,2),Action:=this.MediaKeys[A_ThisHotkey]
			if(Action="Select")
				(Node.hasAttribute("Selected")?Node.removeAttribute("Selected"):Node.setAttribute("Selected"))
			else if(Action="Play_Pause"){
				if((Vid:=Node.querySelector("Video")).SRC)
					(Vid.Paused?Vid.Play():Vid.Pause())
			}else if(Action="Select_All"){
				while(aa:=this.Div.querySelectorAll("Div").Item[A_Index-1])
					(aa.hasAttribute("Selected")?aa.removeAttribute("Selected"):aa.setAttribute("Selected"))
			}else{
				(Action="All_Left"?(Direction:="X",Add:=-1,Start:=X):(Action="All_Right")?(Direction:="X",Add:=1,Start:=X):(Action="All_Up")?(Direction:="Y",Add:=-1,Start:=Y):(Direction:="Y",Add:=1,Start:=Y))
				while(Start<=this[Direction]&&Start>0)
					Node:=this.Div.querySelector((Direction="X"?"Div[X='"(Start)"'][Y='"(Y)"']":"Div[X='"(X)"'][Y='"(Start)"']")),(Node.hasAttribute("Selected")?Node.removeAttribute("Selected"):Node.setAttribute("Selected")),Start+=Add
			}this.Highlight()
		}Size(W:="",H:=""){
			this.querySelector("#DivAfter").innerText:=".Div:After{Height:"((this.Div.offsetHeight/this.Y)-(this.Border*2)-2)"px}"
		}TestXY(X,Y){
			return this.querySelector(Foo:="Div[ID='"(this.DivID)"'] Div[X='"(X)"'][Y='"(Y)"']")
		}
	}
}
mHTML(HTML:=""){
	m(Clipboard:=RegExReplace((HTML?HTML:GG.Doc.Body.outerHtml),"<","`n<"))
}