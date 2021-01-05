HTMLGUI(Win:=1,ProgramName:="",Style:="",Options:=""){
	return New HTMLGUI(Win,ProgramName,Style,Options)
}
Class HTMLGUI{
	static Keep:=[]
	_Event(Name,Event){
		static Events:=[],Last:=[]
		Node:=Event.SrcElement,Ident:=Node.getAttribute("Ident")
		;~ t("Function: " A_ThisFunc,"Label: " A_ThisLabel,"Line: " A_LineNumber,"HERE!",Name,Node.parentNode)
		if(Node.nodeName="Option")
			Node:=Node.parentNode
		if(A_ComputerName="main-computer"&&0)
			t("Function: " A_ThisFunc,"Label: " A_ThisLabel,"Line: " A_LineNumber,"",Node.OuterHTML,Name,Event.X,Event.Y)
		if(Ident="Inner")
			return ID:=Node.parentNode.ID,NN:=this.MainGUI[ID],NN.InnerText:="#" ID " Div.Container1{transform:translate(-" Node.ScrollLeft "px)}"
		Events.Push({Name:Name,Node:Node,this:this,Which:(Name="Mouse"?Event.Which:"")})
		SetTimer,MasterGUIEvent,-10
		return
		MasterGUIEvent:
		ComObjError(0)
		while(Obj:=Events.Pop()){
			Node:=Obj.Node,Name:=Obj.Name,this:=Obj.this,OID:=Node.getAttribute("OID"),LV:=Node.getAttribute("ListView"),Type:=Node.getAttribute("Type"),AutoCommit:=Node.getAttribute("AutoCommit"),ID:=(Lookup:=Node.getAttribute("Lookup"))?Lookup:Node.ID
			VV:=Node.getAttribute("OValue")
			Value:=Node.getAttribute("Value")
			if(Node.getAttribute("IgnoreClick")&&Name="Click")
				return
			if(Node.nodeName="Select")
				Value:=Node.QuerySelector("Option[OValue='"(Node.Value)"']").getAttribute("OID")
			else if(Node.nodeName="Span")
				Value:=Node.InnerText
			else
				Value:=Node.Value
			if(Type~="i)\b(Checkbox)\b"||Node.nodeName~="i)\b(Input)\b")
				Value:=Type="Checkbox"?(Node.Checked?-1:0):Node.Value
			if(Node.parentNode.getAttribute("Tree")||Node.getAttribute("Tree")){
				/*
					Clipboard:=Obj2String(Obj)
				*/
				if(Node.ID="Icon"){
					PN:=Node.parentNode
					if(PN.querySelector("LI"))
						PN.SetAttribute("Expand",(PN.getAttribute("Expand")?"":1))
					return
				}
				if(Node.parentNode.querySelector("LI")&&Obj.Name="DoubleClick"){
					Node:=Node.nodeName="LI"?Node:Node.parentNode
					if(NN:=Node.parentNode.querySelector("UL").parentNode)
						NN.SetAttribute("Expand",NN.getAttribute("Expand")?"":1)
					return
				}Node:=Node.nodeName="Span"?Node.parentNode:Node
				this.TVSetSel(Node.getAttribute("Tree"),Node.getAttribute("OID"))
			}if(Node.nodeName="Input"&&Name="Click"&&Type!="Checkbox")
				return ComObjError(1)
			if(Name="OnInput"||(Name="Click"&&Type~="i)(Checkbox|Select|Date)"))
				this.CheckUpdated(Node)
			if((Method:=Node.getAttribute("IG"))&&IsObject(IG:=this.IG))
				return IG[Method](Name,Value,Node)
			if(Function:=Node.getAttribute("Function")){
				if(IsLabel(Function))
					SetTimer,%Function%,-1
				return Func(Function).Call(Name,Value,Node,Obj.Which) ;,t("Function: " A_ThisFunc,"Label: " A_ThisLabel,"Line: " A_LineNumber,Function)
			}else if(IsFunc("Actions"))
				return Func("Actions").Call(Name,Value,Node)
			if((Label:=Node.getAttribute("Label"))&&IsLabel(Label))
				SetTimer,%Label%,-1
			if(Timer:=Node.getAttribute("Timer"))
				SetTimer,% Obj.this.Timers[Timer].Name,% Obj.this.Timers[Timer].Period
			if(Name="Click"){
				if(LV:=this.IsLV(Node)){
					LV:=LV.getAttribute("ListView")
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
					;~ m("Function: " A_ThisFunc,"Line: " A_LineNumber,"",Node)
					this.SetSel(LV,OID)
				}
			}
		}return ComObjError(1)
	}_HTML(Node:=""){
		this.m(Clipboard:=RegExReplace(Node?Node.OuterHtml:Master.Doc.Body.OuterHTML,"<","`n<"))
	}__New(Win:=1,ProgramName:="",Style:="",Options:=""){
		static
		SetWinDelay,-1
		for a,b in {Background:"Black",Highlight:"#333",SelectedColor:"#999",Color:"Grey",Changed:"Red",HeaderColor:"Orange",Size:15}
			this[a]:=b
		for a,b in Style
			this[a]:=b
		Gui,%Win%:Destroy
		Gui,%Win%:Default
		Gui,Margin,0,0
		Gui,Color,0,0
		this.BodyHTML:="<Body Style='Background-Color:Black;Color:Grey;Margin:0px'>"
		Gui,% Foo:="+HWNDMHWND "(Options.Resize!=0?"+Resize":"")(Options.ToolWindow?" +ToolWindow":"")(Options.Owner?" +Owner"(Options.Owner):"")(Options.Caption=0?" -Caption":"")
		for a,b in Options
			if(a="GUI")
				Gui,%b%
		this.MainGUI:=[],this.FixIE(11)
		Gui,Add,ActiveX,vMain HWNDMainHWND w500 h300,about:blank
		this.FixIE(),this.Win:=Win
		Gui,+LabelHTMLGUI.
		this.Doc:=Main.Document,this.HWND:=MHWND,this.ID:="ahk_id"MHWND,this.WB:=Main,this.MediaGrid:=[]
		this.Functions:=[],this.ChangedObj:=[],this.ChangedNode:=[],this.Columns:=[],this.Data:=[],this.ProgramName:=ProgramName,this.Selected:=[],this.SelectedCSS:=[],this.Styles:=[],this.StylesObj:=[],this.Timers:=[],this.Controls:={Main:{HWND:MainHWND,ID:"ahk_id"MainHWND}}
		HTMLGUI.Keep[Win]:=this
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
		this.SetCSS(Selector)
	}AutoCommit(OnOff:=0){
		this.ACommit:=OnOff
	}BuildBody(Data,ListView,AutoAdd:=""){
		New:=this.Data[ListView]:=[],this.LastSelected[ListView]:="",this.SelectedCSS[ListView].InnerText:="",Function:=this.Functions[ListView]
		for a,b in Data{
			BodyHTML.="<TR ListView='"(ListView)"' Row='"(A_Index)"'>",this.PadID:=StrLen(Data.Count()),ID:=New.Push(OO:=[]),OO.OID:=b.OID
			for c,d in this.Columns[ListView]{
				OO[d.ID]:=(d.Type="Checkbox"?(b[d.ID]?-1:0):b[d.ID]),Value:=((Val:=this.ChangedObj[ListView,b.ID,d.ID])!="")?Val:b[d.ID],Value:=d.ID="Hotkey"?this.Convert_Hotkey(Value):Value,Style:=Val!=""?"Background-Color:Red":"",Style.=Style?";Text-Align:Center":"Text-Align:Center"
				if(d.Type="Input")
					BodyHTML.="<TD OID='"(b.OID)"' ID='"(d.ID)"' "(Style?"Style='"(Style)"'":"")"><Input ListView='"(ListView)"' OID='"(b.OID)"' Function='"(Function)"' ID='"(d.ID)"' Value='"RegExReplace(Value,"'","&apos;")"' Type='Text' oninput='OnInput(event)'"(Val?" Style='"(d.Style)"'":"")"></Input>"this.BuildExtra(d.Extra,b.OID)"</TD>"
				else if(d.Type="Checkbox")
					BodyHTML.="<TD OID='"(b.OID)"' ID='"(d.ID)"' "(Style?"Style='"(Style)"'":"")"><Input ListView='"(ListView)"' OID='"(b.OID)"' Function='"(Function)"' ID='"(d.ID)"' Type='Checkbox'"(Value?"Checked":"")"></Input>"this.BuildExtra(d.Extra,b.OID)"</TD>"
				else if(d.Type="DDL"){
					Item:="<Select Value='"RegExReplace(b[d.ID],"'","&apos;")"' ListView='"(ListView)"' OID='"(b.OID)"' ID='"(d.ID)"' Label='" d.Label "' onchange='OnInput(Event)' Column='" Column++ "' " AddAtt ""(d.Style?" Style='"(d.Style)"'":"")">"
					for g,h in d.Obj{
						;~ m(h.Value,b,d.ID,b[d.ID]"=" h.Value,"",h)
						Item.="<Option OValue='"RegExReplace(h.Value,"'","&apos;")"' OID='"(h.OID)"' " (h.OID=b[d.ID]?" selected='selected'":"")">" h.Value "</Option>"
						;~ m("Function: " A_ThisFunc,"Line: " A_LineNumber,"",g,h,Item)
					}
					BodyHTML.=Foo:="<TD OID='"(b.OID)"' ID='" b.Equipment "_Condition' oninput='OnInput(Event)' Value='"RegExReplace(d.Text,"'","&apos;")"'><Div Style='Flex-Wrap:NoWrap;Display:Flex'>" Item "</Select>"this.BuildExtra(d.Extra,b.OID)"</Div></TD>"
				}else if(d.Type="Date")
					BodyHTML.="<TD ID='"(d.ID)"' "(Style?"Style='"(Style)"'":"")"><Div Function='"(Function)"' ListView='"(ListView)"' OID='"(b.OID)"' ID='"(d.ID)"' Style='Flex-Wrap:NoWrap;Display:Flex;"(d.Style)"'><Input Type='Date' ListView='"(ListView)"' OID='"(b.OID)"' Function='"(Function)"' ID='"(d.ID)"' Value='"RegExReplace(Value,"'","&apos;")"' oninput='OnInput(event)'"(d.Style?" Style='"(d.Style)"'":"")"></Input>"this.BuildExtra(d.Extra,b.OID,b.OID)"</Div></TD>"
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
			this.Doc.QuerySelector("#"(ListView)" .Container2").GetElementsByTagName("TBody").Item[0].InnerHTML:=BodyHTML
			this.LabelOrder(),this.SetAllOValues()
			;~ this.FixColumnHeaders()
		}else
			return BodyHTML
	}BuildBody2(Data,ListView){
		New:=this.Data[ListView]:=[]
		for a,b in Data{
			Total.="<TR ListView='"(ListView)"'>"
			ID:=New.Push(OO:=[])
			for c,d in this.Columns[ListView]{
				Info:=b[d.ID],Value:=Info.Value?Info.Value:Info.Name,Function:=Info.Function
				OO[d.ID]:=(Info.Type="Checkbox"?(b[d.ID]?-1:0):Value)
				OO.OID:=Info.OID
				Style:=Info.Style
				ID:=Info.ID?Info.ID:d.ID
				Type:=Info.Type?Info.Type:d.Type
				if(Type="Text")
					Total.=Foo:="<TD Function='"(Function)"' ListView='"(ListView)"' OID='"(Info.OID)"' ID='"(ID)"' "(Style?"Style='"(Style)"'":"")"><Div Function='"(Function)"' ListView='"(ListView)"' OID='"(Info.OID)"' ID='"(ID)"' Style='Flex-Wrap:NoWrap;Display:Flex;"(d.Style)"'><Span Function='"(Function)"' ListView='"(ListView)"' Lookup='"(Info.Lookup)"' OID='"(Info.OID)"' ID='"(ID)"' Value='"RegExReplace(Value,"'","&apos;")"' Style='"(d.Style)"'>"(Value)"</Span>"this.BuildExtra(d.Extra,Info.OID)"</Div></TD>"
				else if(Type="Button")
					Total.=Foo:="<TD Function='"(Function)"' ListView='"(ListView)"' OID='"(Info.OID)"' ID='"(ID)"' "(Style?"Style='"(Style)"'":"")"><Div Function='"(Function)"' ListView='"(ListView)"' OID='"(Info.OID)"' ID='"(ID)"' Style='Flex-Wrap:NoWrap;Display:Flex;"(d.Style)"'><Button Function='"(Function)"' ListView='"(ListView)"' Lookup='"(Info.Lookup)"' OID='"(Info.OID)"' ID='"(ID)"' Value='"RegExReplace(Value,"'","&apos;")"' Style='"(d.Style)"'>"(Value)"</Span>"this.BuildExtra(d.Extra,Info.OID)"</Div></TD>"
				else if(type="Checkbox"){
					Total.=Foo:="<TD Function='"(Function)"' ListView='"(ListView)"' OID='"(Info.OID)"' ID='"(ID)"' "(Style?"Style='"(Style)"'":"")"><Div Function='"(Function)"' ListView='"(ListView)"' OID='"(Info.OID)"' ID='"(ID)"' Style='Flex-Wrap:NoWrap;Display:Flex;"(d.Style)"'><Input Type='Checkbox' Function='"(Function)"' ListView='"(ListView)"' Lookup='"(Info.Lookup)"' OID='"(Info.OID)"' ID='"(ID)"' Value='"RegExReplace(Value,"'","&apos;")"' Style='"(d.Style)"'>"(Value)"</Span>"this.BuildExtra(d.Extra,Info.OID)"</Div></TD>"
				}else if(Type="Input"){
					Total.=Foo:="<TD OID='"(Info.OID)"' ID='"(ID)"'><Input IgnoreState='"(Info.IgnoreState)"' ListView='"(ListView)"' OID='"(Info.OID)"' Function='"(Function)"' ID='"(ID)"' Value='"RegExReplace(Value,"'","&apos;")"' Type='Text' Lookup='"(Info.Lookup)"' oninput='OnInput(event)'"(Style?" Style='"(Style)"'":"")"></Input>"this.BuildExtra(d.Extra,Info.OID)"</TD>"
				}else if(Type="Password"){
					Total.=Foo:="<TD OID='"(Info.OID)"' ID='"(ID)"'><Input IgnoreState='"(Info.IgnoreState)"' Type='Password' ListView='"(ListView)"' OID='"(Info.OID)"' Function='"(Function)"' ID='"(ID)"' Value='"RegExReplace(Value,"'","&apos;")"' Type='Text' Lookup='"(Info.Lookup)"' oninput='OnInput(event)'"(Style?" Style='"(Style)"'":"")"></Input>"this.BuildExtra(d.Extra,Info.OID)"</TD>"
				}else if(Type="Date")
					Total.="<TD OID='"(Info.OID)"' ID='"(ID)"' "(Style?"Style='"(Style)"'":"")"><Span ListView='"(ListView)"' Type='Date' Lookup='"(Info.Lookup)"' Function='"(Function)"' ID='"(ID)"' OID='"(Info.OID)"' Value='"RegExReplace(Value,"'","&apos;")"' Style='Cursor:Hand;Color:#3333FF' "(d.IgnoreState?"IgnoreState='1'":"")">"(Value)"</Span></TD>"
				else if(Type="DDL"){
					Item:="<Select IgnoreState='"(Info.IgnoreState)"' Value='"RegExReplace(Value,"'","&apos;")"' ListView='"(ListView)"' OID='"(Info.OID)"' ID='"(ID)"' Label='" d.Label "' onchange='OnInput(Event)' Lookup='"(Info.Lookup)"' Column='" Column++ "' " AddAtt ""(b[d.ID].Style?" Style='"(b[d.ID].Style)"'":"")">"
					for e,f in b.Value.DDL
						Item.="<Option OID='"(f.OID)"' Value='"RegExReplace(f.Name,"'","&apos;")"' OValue='"RegExReplace(f.Name,"'","&apos;")"' "(f.Style?"Style='"(f.Style)"'":"")" "(f.Selected?" selected='selected'":"")">"(f.Name)"</Option>"
					Total.=Foo:="<TD OID='"(b.OID)"' ID='" b.Equipment "_Condition' oninput='OnInput(Event)' Value='"RegExReplace(d.Text,"'","&apos;")"'><Div Style='Flex-Wrap:NoWrap;Display:Flex'>" Item "</Select>"this.BuildExtra(d.Extra,b.OID)"</Div></TD>"
				}else if(IsFunc((Type)"_Column")){
					Total.=Foo:=Func((Type)"_Column").Call(b,Info,Listview)
				}else{
					m("Function: " A_ThisFunc,"Line: " A_LineNumber,"Build for type |"(Type)"|","",Info)
				}
				;~ m("Function: " A_ThisFunc,"Line: " A_LineNumber,"",c,d)
			}
			Total.="</TR>"
		}
		this.Doc.QuerySelector("#"(ListView)" .Container2").GetElementsByTagName("TBody").Item[0].InnerHTML:=Total
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
		}Header:=this.Doc.QuerySelector("#"(ListView)" .Container1"),Body:=this.Doc.QuerySelector("#"(ListView)" .Container2")
		if(Build){
			Second:=Head:="<Table Name='"(ListView)"'><THead Class='FixedHeader'><TR Class='Header'>"
			for a,b in this.Columns[ListView]
				Spans.="<TH><Span Class='Header' ListView='"(ListView)"' Function='SortHDR' OText='"(b.ID)"' ID='"(b.ID)"'>"(b.Name)"</Span></TH>",Second.="<TH>"(b.Name)"</TH>"
			Head.="</TR></thead></Table>",Second.="</TR></THead><TBody></TBody>",Header.InnerHTML:=Head,Header.QuerySelector("TR").InnerHTML:=Spans,Body.InnerHTML:=Second,ComObjError(0)
			if(!this.SelectedCSS[ListView])
				this.SelectedCSS[ListView]:=this.createElement("Style")
			ComObjError(1)
		}if(!Columns.Count())
			Header.InnerHTML:="",Body.InnerHTML:=""
		if(Data)
			this.BuildBody(Data,ListView,1)
		if(!this.SuspendHeaderUpdate)
			this.FixColumnHeaders()
		this.Columns[ListView]:=Columns
		return Data
	}BuildTree(Data,Tree){
		Obj:=[],Selected:=[],Expand:=[]
		for a,b in Data
			for c,d in b{
				Selected[d.OID]:=d.Sel
				Expand[d.OID]:=d.Expand
				Info.="<LI ID='"(d.OID)"' Value='"this.FixHTML(d.Value)"' Tree='"(Tree)"' OID='"(d.OID)"' Function='"(this.MainGUI[Tree].Function)"' Type='"(d.Type)"' Style='Cursor:Hand' Parent='"(d.Parent)"'>"
				if(d.Type="Folder")
					Info.="<Span ID='Icon' Class='Open' Style='Color:Yellow'>"(this.OpenFolder)"</Span><Span ID='Icon' Class='Closed' Style='Color:Yellow'>"(this.ClosedFolder)"</Span><Span ID='Label' Style='"(d.Style)"'>"(d.Value)"</Span>"
				else
					Info.=Row:="<Span ID='Icon' Class='Open' Style='"(d.OpenIconStyle?d.OpenIconStyle:d.IconStyle)"'>"(d.OpenIcon?d.OpenIcon:d.Icon)"</Span><Span ID='Icon' Class='Closed' Style='"(d.ClosedIconStyle?d.ClosedIconStyle:d.IconStyle)"'>"(d.ClosedIcon?d.ClosedIcon:d.Icon)"</Span><Span ID='Label' Style='"(d.Style)"'>"(d.Value)"</Span>"
				/*
					Info.="<Span ID='Icon' Style='"(d.IconStyle)"'>"(d.Icon?d.Icon:"")"</Span><Span ID='Label' Style='"(d.Style)"'>"(d.Value)"</Span>"
				*/
				Info.="<UL Function='"(d.Function)"' Style='Margin:0px;Margin-Left:"(this.SubFolderIndent)"' ID='"(d.OID)"'></UL></LI>"
			}
		Parent:=this.querySelector("Div[ID='"(Tree)"']")
		Parent.Style.Visibility:="Hidden"
		Parent.InnerHTML:=Info
		All:=this.querySelectorAll("Div[ID='"(Tree)"'] LI")
		while(aa:=All.Item[A_Index-1]){
			PID:=aa.getAttribute("Parent")
			if(Selected[aa.ID])
				aa.SetAttribute("Sel",1)
			aa.SetAttribute("Expand",Expand[aa.ID])
			if(PID){
				Parent.querySelector("UL[ID='"(PID)"']").AppendChild(aa)
			}
		}
		if(){
			mHTML()
			ExitApp
		}
		Parent.Style.Visibility:="Visible"
		/*
			mHTML()
		*/
		/*
			m("Function: " A_ThisFunc,"Line: " A_LineNumber,"Here!",Data,Tree)
		*/
	}CheckUpdated(Node){
		/*
			Value:=Node.Value?Node.Value:Node.getAttribute("Value")
		*/
		LV:=Node.getAttribute("ListView")
		OID:=Node.getAttribute("OID")
		ID:=(II:=Node.getAttribute("Lookup"))?II:Node.getAttribute("ID")
		Ignore:=Node.getAttribute("IgnoreState")
		VV:=Node.getAttribute("OValue")
		Value:=Node.getAttribute("Value")
		;~ m("Function: " A_ThisFunc,"Line: " A_LineNumber,"",Node,"","LV: " LV,"OID: " OID,"ID: " ID)
		;~ if(!Ignore&&(Node.ID~="i)(EMail|First_Name|Middle_Name|Last_Name|Phone_Number|Birthday|Hire_Date|Termination_Date|Retire_Date)"=0))
		;~ m("Function: " A_ThisFunc,"Line: " A_LineNumber,"",Node)
		;~ m("Function: " A_ThisFunc,"Line: " A_LineNumber,"",VV,Value)
		;~ m(Node.Value,Node.QuerySelector("Option[OValue='"(Node.Value)"']").getAttribute("OID"),"",Node)
		if(Node.nodeName="Select")
			Value:=Node.QuerySelector("Option[OValue='"(Node.Value)"']").getAttribute("OID")
		else if(Node.nodeName="Span")
			Value:=Node.InnerText
		else
			Value:=Node.Value
		if(Type~="i)\b(Checkbox)\b"||Node.nodeName~="i)\b(Input)\b")
			Value:=Type="Checkbox"?(Node.Checked?-1:0):Node.Value
		if(Function:=Func("Commit"))
			return Function.Call(Name,Node),ComObjError(1)
		if(this.ACommit||AutoCommit)
			this.Data[LV,OID,ID]:=Value
		if(!Ignore){
			if(!IsObject(OO:=this.ChangedObj[LV])&&ID)
				OO:=this.ChangedObj[LV]:=[],this.ChangedNode[LV]:=[]
			if(VV=Value){
				if(this.IsLV(Node))
					this.FindParent(Node,"TD").Style.BackgroundColor:="",this.ChangedObj[LV,OID].Delete(ID),this.ChangedNode[LV,OID,ID]:=Node
				else
					Node.Style.BackgroundColor:="",this.ChangedObj[LV,OID].Delete(ID),this.ChangedNode[LV,OID,ID]:=Node
			}else{
				if(this.IsLV(Node))
					this.FindParent(Node,"TD").Style.Background:=this.Changed,OO[OID,ID]:=Value,this.ChangedNode[LV,OID,ID]:=Node
				else
					Node.Style.Background:=this.Changed,OO[OID,ID]:=Value,this.ChangedNode[LV,OID,ID]:=Node
	}}}Close(){
		HTMLGUI.Keep[A_Gui].Escape()
	}Convert_Hotkey(Key){
		StringUpper,Key,Key
		for a,b in [{Ctrl:"^"},{Win:"#"},{Alt:"!"},{Shift:"+"}]
			for c,d in b
				if(InStr(Key,d))
					Build.=c "+",Key:=RegExReplace(Key,"\" d)
		return Build Key
	}createElement(Type,Parent:="",Atts:="",Style:="",Text:="",HTML:=""){
		local
		global MediaGrid
		if(Type="ListView"){
			New:=this.createElement("Div",Parent)
			New.InnerHTML:=this.LVHTML(Text)
			this.MainGUI[Text]:=this.createElement("Style")
			this.MainGUI[Text].InnerText:="#"(Text)" Div.Container1{transform:translate(0px)}"
			this.Functions[Text]:=Atts.Function
		}else if(Type="TreeView"){
			New:=this.createElement("Div",Parent),New.ID:=Text
			this.MainGUI[Text]:=Atts
			if(!Style.Border)
				New.Style.Border:="1px Solid Grey"
			New.Style.OverFlow:="Auto",New.SetAttribute("Type","TreeView")
		}else if(Type="DDL"){
			New:=this.Doc.createElement("Select")
			(Parent?Parent.AppendChild(New):this.Doc.AppendChild(New))
			for a,b in HTML
				New.AppendChild(Option:=this.Doc.createElement("Option")),Option.Value:=b,Option.InnerText:=b
		}else if(Type="MediaGrid"){
			New:=this.createElement("Div",Parent),New.ID:=Text
			MG:=this.MediaGrid[Text]:=New MediaGrid(this,Text,(Atts.Border?Atts.Border:8),Style),New.setAttribute("Type","MediaGrid")
		}else
			New:=this.Doc.createElement(Type),(Parent?Parent:this.Doc.Body).AppendChild(New),(Text)?New.InnerText:=Text:HTML?New.InnerHTML:=HTML:""
		for a,b in Atts
			(a="Timer")?(this.Timers[b.ID]:={Name:b.Name,Period:b.Period},New.SetAttribute("Timer",b.ID)):New.SetAttribute(a,b)
		for a,b in Style
			Style:=New.Style,Style[a]:=b
		if(Type="Input")
			New.SetAttribute("oninput","OnInput(event)")
		if(Type="DDL")
			New.SetAttribute("onchange","OnInput(event)")
		if(Atts.Type="Checkbox")
			Parent.AppendChild(NN:=this.createElement("Label")),NN.SetAttribute("Function",Atts.Function),NN.Style.Cursor:="Hand",NN.InnerText:=Text
		return MG?MG:New
	}CurrentNode(){
		return this.Doc.activeElement
	}Del(Items:=""){
		Remove:=[]
		for a,b in (Items?Items:this.DelBuild())
			LV:=b.LV,b.Node.parentNode.RemoveChild(b.Node),OID:=b.Node.QuerySelector("*[OID]").getAttribute("OID"),Remove[OID]:=1
		Associate:=[]
		for a,b in this.Data[LV]
			if(Remove[b.OID])
				Associate[a]:=1
		for a,b in Associate
			this.Data[LV].Delete(a)
		this.LabelOrder(),this.SelectedCSS[LV].InnerText:=""
		if(Func:=Func((LV)"_Delete"))
			Func.Call(Remove)
	}DelBuild(){
		Node:=this.Doc.ActiveElement,Delete:=[]
		if(LV:=this.IsLV(Node).getAttribute("ListView")){
			for a,b in this.Selected[LV]{
				Delete.Push({LV:LV,OID:a,Node:this.Doc.QuerySelector("Div[ListView='"(LV)"'] TD[OID='"(a)"']").parentNode})
			}
		}return Delete
	}Delete(){
		if((Active:=this.Doc.ActiveElement).nodeName="Input"){
			if(Active.SelectionStart=Active.SelectionEnd)
				Active.SetSelectionRange(Active.SelectionStart,Active.SelectionEnd+1)
			Send,{Backspace}
			return
		}
		if(Func:=Func("Delete"))
			return Func.Call(Obj)
		if(!(Obj:=this.DelBuild()).Count()){
			return
		}
		if(this.m("Delete "(Obj.Count())" item"(Obj.Count()=1?"":"s"),"Are you sure?","Btn:yn","Def:2")="YES")
			this.Del(Obj)
	}DeleteObj(LV){
		Delete:=[]
		for a,b in this.Selected[LV]
			Delete.Push({LV:LV,OID:a,Node:this.Doc.QuerySelector("Div[ListView='"(LV)"'] TD[OID='"(a)"']").parentNode})
		return Delete
	}DeleteCSS(Selector,Declaration){
		if(!this.Styles[Selector,Declaration])
			return
		this.Styles[Selector].Delete(Declaration)
		this.SetCSS(Selector)
	}Destroy(){
		Gui,% this.Win ":Destroy"
	}Directions(){
		Node:=this.CurrentNode()
		if(Node.getAttribute("Type")="TreeView"){
			Sel:=Node.querySelector("*[Sel='1']")
			if(A_ThisHotkey="Down"){
				All:=Node.querySelectorAll("LI")
				while(aa:=All.Item[A_Index-1]){
					if(Start&&this.Doc.ParentWindow.getComputedStyle(aa).Visibility="Visible")
						return this.RemoveTVSel(Node),aa.setAttribute("Sel",1),this.TriggerFunction(aa)
					if(aa.isSameNode(Sel))
						Start:=1
				}
				this.Tab()
			}else if(A_ThisHotkey="Up"){
				All:=Sel.previousSibling.querySelectorAll("LI")
				while(aa:=All.Item[All.Length-A_Index])
					if(this.Doc.ParentWindow.getComputedStyle(aa).Visibility="Visible")
						return this.RemoveTVSel(Node),aa.setAttribute("Sel",1),this.TriggerFunction(aa)
				if(Prev:=Sel.previousSibling)
					return this.RemoveTVSel(Node),Prev.setAttribute("Sel",1),this.TriggerFunction(Prev)
				else if((Prev:=Sel.parentNode.parentNode).nodeName="LI")
					return this.RemoveTVSel(Node),Prev.setAttribute("Sel",1),this.TriggerFunction(Prev)
				this.TabShift()
			}else if(A_ThisHotkey="Left"){
				if(Sel.getAttribute("Expand"))
					Sel.setAttribute("Expand",""),this.TriggerFunction(Sel,"Contract")
				else if((Parent:=Sel.parentNode.parentNode).nodeName="LI")
					this.RemoveTVSel(Node),Parent.setAttribute("Sel",1),this.TriggerFunction(Parent)
			}else if(A_ThisHotkey="Right"){
				if(!Sel.getAttribute("Expand")&&Sel.querySelector("LI"))
					Sel.setAttribute("Expand",1),this.TriggerFunction(Sel)
				else if(Sel.querySelector("LI"))
					this.RemoveTVSel(Node),(Child:=Sel.querySelector("LI")).setAttribute("Sel",1),this.TriggerFunction(Child)
			}
		}else if(Node.nodeName="Input"&&Node.getAttribute("Type")="Text"){
			Len:=StrPut(Node.Value,"UTF-8")-1,Start:=Node.selectionStart,End:=Node.selectionEnd
			if(A_ThisHotkey~="i)\b(Up|Down)\b"){
				return (A_ThisHotkey="Up"?this.TabShift():this.Tab())
			}
			if(Start!=End){
				Send,{%A_ThisHotkey%}
				return
			}else if(Start=Len&&A_ThisHotkey="Right")
				return this.Tab()
			else if(Start=0&&A_ThisHotkey="Left")
				return this.TabShift()
			Send,{%A_ThisHotkey%}
		}else if(Node.nodeName="Div"&&Node.getAttribute("Type")="MediaGrid"){
			this.MediaGrid[Node.ID].Directions(A_ThisHotkey)
		}else if(A_ThisHotkey~="i)\b(Right|Down)\b")
			this.Tab()
		else
			this.TabShift()
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
		All:=this.Doc.GetElementsByClassName("Outer")
		AllObj:=[]
		while(aa:=All.Item[A_Index-1]){
			All1:=aa.GetElementsByTagName("Div"),AllObj.Push(OO:=[])
			while(aa1:=All1.Item[A_Index-1])
				if(InStr(aa1.ID,"Container"))
					OO[RegExReplace(aa1.ID,"\D")]:=aa1
		}
		for a,b in AllObj{
			Start:=2,All:=b.2.GetElementsByTagName("TH"),Fix:=b.1.GetElementsByTagName("Span")
			ComObjError(0)
			while(aa:=All.Item[A_Index-1]){
				Rect:=aa.GetBoundingClientRect()
				Width:=Rect.Right-Rect.Left
				Fix[A_Index-1].Style.Left:=Start
				Fix[A_Index-1].Style.Width:=Width
				Start+=Width
			}
			ComObjError(1)
		}
	}fixHTML(Text){
		return RegExReplace(Text,"'","&apos;")
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
	}GetLast(){
		Settings:=[]
		for a,b in v.Keys{
			if(this.Doc.QuerySelector("#Box #"(a)).Checked){
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
		for a,b in {Delete:this.Delete.Bind(this),"+Delete":this.Del.Bind(this),Tab:this.Tab.Bind(this),"+Tab":this.TabShift.Bind(this),Left:Dir,Right:Dir,Up:Dir,Down:Dir}
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
		while(Node){
			if(Node.nodeName="TR")
				return Node
			Node:=Node.parentNode
		}
	}LabelOrder(){
		;~ All:=this.Doc.All
		this.TabOrder:=[],Row:=0,Column:=0,All:=this.QuerySelectorAll("Button,Input,TR,Select,Div[Type='TreeView'],Div[Type='MediaGrid']")
		while(aa:=All.Item[A_Index-1]){
			ListView:=aa.getAttribute("ListView")
			if(ListView&&Row)
				OID:=aa.QuerySelector("*[OID]").getAttribute("OID")
			if(aa.nodeName="Button"){
				aa.SetAttribute("Row",Row)
				aa.SetAttribute("Col",Column)
				this.TabOrder[Row,Column]:=aa
				(Listview?Col++:Row++)
			}if(aa.nodeName="TR")
				aa.SetAttribute("Row",Row)
			if(aa.nodeName="Input"||aa.nodeName="Select"){
				if(aa.getAttribute("Name")&&aa.getAttribute("Name")=LastName){
					aa.SetAttribute("Row",Row),aa.SetAttribute("Column",Column)
					Continue
				}if(!(LP:=(ListView?this.FindParent(aa,"TR"):aa.parentNode)).IsSameNode(LastParent))
					Row++,Column:=1
				aa.SetAttribute("Row",Row)
				this.TabOrder[Row,Column]:=aa
				aa.SetAttribute("Col",Column++)
				LastParent:=LP
				LastName:=aa.getAttribute("Name")
				ID:=aa.getAttribute("OID")
				if(Value:=this.Changed[Row,ID])
					aa.Value:=Value,aa.parentNode.Style.BackgroundColor:="Red"
			}if(aa.nodeName="Div"&&aa.getAttribute("Type")="TreeView"){
				Row++,Column:=1
				aa.SetAttribute("Row",Row)
				this.TabOrder[Row,Column]:=aa
				aa.SetAttribute("Col",Column),Column++
			}if(aa.nodeName="Div"&&aa.getAttribute("Type")="MediaGrid"){
				Row++,Column:=1
				aa.SetAttribute("Row",Row)
				this.TabOrder[Row,Column]:=aa
				aa.SetAttribute("Col",Column),Column++
			}
		}
	}LVDelete(ListView,Items:=""){
		if(!Items)
			return Node:=this.Doc.QuerySelector("Div[ListView='"(ListView)"'] TBody"),Parent:=Node.parentNode,Parent.RemoveChild(Node),this.createElement("TBody",Parent)
	}LVHTML(ListView,Width:="calc(100% - 2px)",Height:="calc(100% - 2px)",Function:=""){
		Total.="<Div Class='Outer' ID='" ListView "' ListView='"(ListView)"' Style='Width:"(Width)";Height:"(Height)"'><Div ID='Container1' Class='Container1'></Div><Div Class='Inner' onscroll='scroll(event)' ID='Inner' Ident='Inner' Style='Width:100%'><Div ID='Container2' Class='Container2' Style='Margin-Left:2px;Margin-Right:2px;Margin-Top:0px' onscroll='scroll(event)'></Div></Div></Div>"
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
			if(Obj.OuterHtml){
				String.=FullPath Obj.OuterHtml "`n",Current:=1
			}
		}if(!Current){
			if(IsObject(Obj)){
				for a,b in Obj{
					if(IsObject(b)&&b.OuterHtml)
						String.=FullPath "." a " = " b.OuterHtml "`n"
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
		return this.Doc.QuerySelector(Query)
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
		Font:="Color:"(this.HeaderColor)";Font-Size:" this.Size "px"
		this.Doc.Body.OuterHTML:="<Body Style='Width:calc(100% - 4);Margin:0px;' ondrop='return false;'>"
		this.Doc.Body.InnerHTML:=HTML
		this.AddCSS("Body{"(Font)"}")
		this.AddCSS(".Container1 TH{Visibility:Hidden}")
		this.AddCSS(".Outer{Border:1px Solid Grey;OverFlow:Hidden;Display:Block}")
		this.AddCSS("TH Span{White-Space:NoWrap;Visibility:Visible;Position:Absolute;Text-Align:Center;"(Font)"}")
		this.AddCSS(".Inner{OverFlow:Auto;Width:100%;Height:calc(100% - "(this.Size)"px);Margin-Top:"(this.Size)"px}")
		this.AddCSS(".Container2 TD{White-Space:NoWrap}")
		this.AddCSS(".Container2 TH{White-Space:NoWrap;Visibility:Hidden;Line-Height:0px;"(Font)"}")
		this.AddCSS("UL,LI{list-style-type:None}")
		this.AddCSS("Div[Type='TreeView']:focus LI[Sel='1']>Span[ID='Label']{Background:"(this.TreeViewSelectColor)";Border:0px}")
		this.AddCSS("Div[Type='TreeView'] LI[Sel='1']>Span[ID='Label']{Background:'';Border:1px Solid "(this.TreeViewUnFocusedBorderColor)"}")
		this.AddCSS("LI[Expand='1'][Type='Folder']>UL,LI{Display:Block}")
		this.AddCSS("LI[Expand='']>Span[ID='Icon'].Open{Display:None}")
		this.AddCSS("LI[Expand='1']>Span[ID='Icon'].Closed{Display:None}")
		this.AddCSS("LI[Expand='']>UL{Display:None;Visibility:Hidden}")
		for a,b in {onclick:"Click",ondblclick:"DoubleClick",scroll:"scroll",OnInput:"OnInput",Change:"Change",Search:"Search",oncontextmenu:"Mouse"}
			this.createElement("Script").InnerText:=a "=function(" a "){ahk_event('" b "',event)};"
		for a,b in ["td{Border:1px Solid Grey;Padding:8px}","Body{Background-Color:"(this.Background)";Color:"(this.Color)";-MS-User-Select:None}","Table{Border-Collapse:Collapse;Border-Spacing:0;Width:100%}","Input:Focus{Background:#444;Color:#FFF;Border:2px Solid Orange}","Input{Background:"(this.Background)";Color:"(this.Color)"}",".Title{Color:"(this.TitleColor)"}"]
			this.AddCSS(b)
		this.createElement("Script").innerText:="clickIcon=function(clickIcon){ahk_event('clickIcon',event)};"
		this.Columns:=[],this.Data:=[],this.LastSelected:=[],this.Styles:=[],this.StylesObj:=[],this.SelectedCSS:=[]
		return this.Doc.ParentWindow.ahk_event:=this._Event.Bind(this)
	}SetSel(LV,OID){
		static LastSel:=[]
		if(!LV)
			return
		for a,b in this.Selected[LV]{
			Sel.="TR[ListView='"(LV)"'] TD[OID='"(a)"']{Background-Color:"(this.Highlight)"}`n"
		}
		/*
			m(Clipboard:=Sel "`n`n" this.Doc.Body.OuterHTML)
		*/
		this.SelectedCSS[LV].InnerText:=Sel
		/*
			TR[ListView='Errors'] TD[OID='4']{Background-Color:#cccccc}
		*/
		/*
			m("Function: " A_ThisFunc,"Line: " A_LineNumber,"Here!",this.QuerySelector("*[ListView='Errors'] TD[OID='4']").parentNode.OuterHTML,Sel)
		*/
		this.LastSelected[LV]:=OID
		;~ t("Function: " A_ThisFunc,"Label: " A_ThisLabel,"Line: " A_LineNumber,"",Sel)
		LastSel[LV]:=this.Selected[LV].Clone()
	}SetAllOValues(){
		All:=this.Doc.QuerySelectorAll("Option")
		while(aa:=All.Item[A_Index-1]){
			aa.SetAttribute("OValue",aa.InnerText)
		}
		All:=this.Doc.QuerySelectorAll("Select,Input,Span")
		while(aa:=All.Item[A_Index-1]){
			Value:=aa.nodeName="Span"?aa.InnerText:aa.Value
			if(aa.nodeName="Select"){
				if(aa.Value)
					Value:=aa.QuerySelector("Option[OValue='"(aa.Value)"']").getAttribute("OID")
				else
					Value:=""
				/*
					m("Function: " A_ThisFunc,"Line: " A_LineNumber,"Here!",Value,aa.OuterHTML,aa.Value,aa.QuerySelector("Option[OValue='"(aa.Value)"']").OuterHTML)
				*/
			}
			aa.SetAttribute("OValue",Value)
		}
	}SetCSS(Selector){
		for a,b in this.Styles[Selector]
			String.=a ":" b ";"
		if(!Node:=this.StylesObj[Selector])
			Node:=this.createElement("Style"),this.StylesObj[Selector]:=Node
		Node.InnerText:=Selector "{"(String)"}"
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
		this.Size() ;,this.Tab()
	}Size(Info:="",W:="",H:=""){
		static WW,HH
		this:=IsObject(this)?this:(HTMLGUI.Keep[A_Gui]),(W&&H)?(WW:=W,HH:=H):!W||!H?(W:=WW,H:=HH):"",DllCall("SetWindowPos",UPtr,this.Controls.Main.HWND,Int,0,"Int",0,"Int",0,"Int",W,"Int",H,"UInt",0x0020),this.FixColumnHeaders()
		for a,b in this.MediaGrid
			b.Size(W,H)
	}Tab(Add:=1){
		Node:=this.Doc.ActiveElement,Row:=Node.getAttribute("Row"),Col:=Node.getAttribute("Col"),Node:=""
		if((!Row||!Col)&&(this.Row&&this.Col)){
			Row:=this.Row,Col:=this.Col
		}
		if(Row=""&&Col=""){
			Node:=this.QuerySelector("*[Row='"(Row:=this.TabOrder.MinIndex())"'][Col='"(this.TabOrder[Row].MinIndex())"']")
		}else{
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
				Node:=this.QuerySelector("*[Row='"(Row:=this.TabOrder.MinIndex())"'][Col='"(this.TabOrder[Row].MinIndex())"']")
			this.Row:=Node.getAttribute("Row"),this.Col:=Node.getAttribute("Col")
		}Node.Focus(),(Node.nodeName="Input"?Node.Select():""),this.FocusTree(Node)
	}TabShift(){
		Node:=this.Doc.ActiveElement,Row:=Node.getAttribute("Row"),Col:=Node.getAttribute("Col")
		if(Row=""&&Col=""){
			Node:=this.QuerySelector("*[Row='"(this.TabOrder.MaxIndex())"'][Col='"(this.TabOrder[this.TabOrder.MaxIndex()].MaxIndex())"']")
		}else{
			if(!Node:=this.QuerySelector("*[Row='"(Row)"'][Col='"(Col-1)"']")){
				while(!this.TabOrder[--Row]&&Row>=0)
					Col:=this.TabOrder[Row].MaxIndex()
				Node:=this.QuerySelector("*[Row='"(Row)"'][Col='"this.TabOrder[Row].MaxIndex()"']")
			}if(!Node)
				Node:=this.QuerySelector("*[Row='"(this.TabOrder.MaxIndex())"'][Col='"(this.TabOrder[this.TabOrder.MaxIndex()].MaxIndex())"']")
		}Node.Focus(),(Node.nodeName="Input"?Node.Select():""),this.FocusTree(Node)
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
		/*
			m("Function: " A_ThisFunc,"Line: " A_LineNumber,"Here!",this.querySelector(Fuck:="Div[ID='"(Control)"'] LI[OID='"(OID)"']"),Fuck)
		*/
	}UpdateLanguage(){
		All:=this.QuerySelectorAll("*[Language]")
		while(aa:=All.Item[A_Index-1]){
			/*
				if(v.Testing)
					m(aa.getAttribute("Language"),this.CurrentScreen,this.Current)
			*/
			aa.InnerHTML:=this.LanguageObj[this.CurrentScreen,aa.getAttribute("Language"),this.CurrentLanguage]
		}
	}WinPos(HWND:=""){
		HWND:=HWND?HWND:this.HWND,VarSetCapacity(Rect,16)
		WinGetPos,X,Y,,,ahk_id%HWND%
		DllCall("GetClientRect",Ptr,HWND,Ptr,&Rect),W:=NumGet(Rect,8,"Int"),H:=NumGet(Rect,12,"Int"),Text:="X" X " Y" Y " W" W " H" H
		return {X:X,Y:Y,W:W,H:H,Text:Text}
	}
}
mHTML(HTML:=""){
	m(Clipboard:=RegExReplace((HTML?HTML:GG.Doc.Body.OuterHtml),"<","`n<"))
}
Class MediaGrid{
	__New(Master,DivID:="Grid",Border:=8,Options:=""){
		for a,b in {Count:9,VideoBackground:"#CC00CC",Volume:.2}
			this[a]:=(Options[a]?Options[a]:b)
		for a,b in Options
			this[a]:=b
		this.Master:=Master
		this.DivID:=DivID
		this.Doc:=Master.Doc
		/*
			mHTML(this.Doc.Body.OuterHtml)
		*/
		Master.IG:=this
		this.AddColor:=0x303030
		this.Border:=Border
		this.Div:=this.Doc.querySelector("#"(DivID))
		this.Selected:=[]
		/*
			this.DirectionBind:=this.Directions.Bind(this)
		*/
		this.ChangeSel:=this.SetSelect.Bind(this)
		this.createElement("Style").innerText:=".Div{OverFlow:Hidden;Float:Left;Background-Color:"(Master.Background)";Text-Align:Center;Position:Relative;Border:6px Solid Grey;Border-Radius:6px} .Div:After{Content:'';Display:Inline-Block;Vertical-Align:Middle}"
		this.createElement("Style","Division").innerText:=".Div{Width:calc(33.333333`% - 16px);Height:calc(33.33333`% - 16px)}"
		this.createElement("Style","DivAfter").innerText:="Img{Margin-Top:50`%;Margin-Bottom:Auto}"
		this.createElement("Style","Labels").innerText:="P{Display:Block;Bottom:-16px;Position:Absolute;Text-Align:Center;Width:100%;Background-Color:Black;Opacity:.7}"
		this.SetStates()
		/*
			m(RegExReplace(this.querySelector("*").outerHTML,"<","`n<"))
		*/
	}createElement(Type,ID:=""){
		New:=this.Doc.createElement(Type),this.Doc.Body.AppendChild(New),(ID?New.ID:=ID:"")
		return New
	}CurrentMedia(){
		return this.querySelector("Div[ID='"(this.DivID)"'] Div[Current]")
	}DirectionHotkeys(Keys:=""){
		Keys:=IsObject(Keys)?Keys:[]
		for a,b in ["Left","Right","Up","Down"]
			if(!Keys[b])
				Keys[b]:=b
		Hotkey,IfWinActive,% this.Master.ID
		this.HotkeyDirections:=[],Dir:=this.DirectionBind
		for a,b in Keys{
			Hotkey,%a%,%Dir%,On
			this.HotkeyDirections[a]:=b
		}
	}Directions(a*){
		static Functions:=[]
		if(a.1&&!a.2)
			Key:=a.1
		else
			Key:=A_ThisHotkey
		Node:=(Doc:=this.Master.Doc).activeElement
		PN:=Node.querySelector("Video")
		if(PN.SRC)
			PN.Pause()
		if(Node.ID!=this.DivID){
			Fun:=this.HotkeyDirections[Key]
			if(!Functions[Fun]&&IsFunc(Fun))
				Functions[Fun]:=Func(Fun)
			if(FF:=Functions[Fun])
				FF.Call(Key)
			return t("Function: " A_ThisFunc,"Label: " A_ThisLabel,"Line: " A_LineNumber,"HERE!",Node)
		}
		if(NN:=Doc.QuerySelector("Div[ID='"(this.DivID)"'] Div[Selected]"))
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
		}this.querySelector("Div[Current]").removeAttribute("Current"),Node.SetAttribute("Current"),Node.Focus(),this.Highlight()
		PN:=Node.querySelector("Video")
		if(PN)
			PN.Play()
	}GetSelected(Selected:=0){
		All:=this.Doc.querySelectorAll("Div[ID='"(this.DivID)"'] Div"),Selected:=[]
		while(aa:=All.Item[A_Index-1]){
			if(aa.hasAttribute("Selected"))
				Selected.Push(aa.getAttribute("OID"))
		}
		if(Selected.Count()=0&&!Selected){
			if(OID:=this.Doc.QuerySelector(Foo:="Div[ID='"(this.DivID)"'] Div[Current]").getAttribute("OID"))
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
			else if(State){
				aa.Style.Border:=(this.Border)"px Solid "("#"(Current?SubStr(Format("{:X}",State+0x303030),1,6):Format("{:X}",State)))
			}else
				aa.Style.Border:=(this.Border)"px Solid "("#"SubStr(Format("{:X}",(Selected?Sel:CC)+(Current?this.AddColor:0)),1,6))
		}
	}Populate(Media,Current:=1){
		this.X:=Ceil(Sqrt(Media.Count())),this.Y:=Round(Sqrt(Media.Count())),this.Media:=[]
		X:=Y:=1
		/*
			m(RegExReplace(this.querySelector("*").outerHTML,"<","`n<"))
		*/
		for a,b in Media{
			this.Media[b.OID]:=b
			List.="<Div "(b.Current?"Current":"")" OID='"(b.OID)"' X='"(X)"' Y='"(Y)"' IG='Select' Class='Div' Type='MediaGrid' ID='"(this.DivID)"' Style='Border-Radius:"(this.Border)"px;Border:"(this.Border)"px Solid Grey;Float:Left'>"
			List.="<Video OID='"(b.OID)"' X='"(X)"' Y='"(Y)"' ID='"(this.DivID)"' IG='Select' Style='Display:None;vertical-align: middle;Max-Width:100%;Max-Height:100%;Background:"(this.VideoBackground)"'></Video>"
			List.="<Img OID='"(b.OID)"' X='"(X)"' Y='"(Y)"' ID='"(this.DivID)"' IG='Select' Style='vertical-align: middle;Max-Width:100%;Max-Height:100%'></Img>"
			List.="<P ID='"(this.DivID)"' X='"(X)"' Y='"(Y)"'>"(b.Text)"</P></Div>"
			X++
			if(X>this.X)
				X:=1,Y++
		}this.querySelector("Div[ID='"(this.DivID)"']").innerHTML:=List
		for a,b in Media{
			Node:=this.querySelector(Foo:="Div[ID='"(this.DivID)"'] Div:nth-of-type("(A_Index)")")
			if(SubStr(b.SRC,-2)="mp4")
				(Vid:=Node.querySelector("Video")).SRC:=b.SRC,Vid.Style.Display:="Inline-Block",Node.querySelector("Img").Style.Display:="None",Node.Style.Background:=this.VideoBackground,Node.querySelector("Video").Volume:=this.Volume
			else
				(Img:=Node.querySelector("Img")).SRC:=b.SRC,Img.Style.Display:="Inline-Block",Node.querySelector("Video").Style.Display:="None",Node.Style.Background:=this.Master.Background
		}this.Doc.QuerySelector("#Division").innerText:=".Div{Width:calc("(100/this.X)"% - "(this.Border*2)"px);Height:calc("(100/this.Y)"% - "(this.Border*2)"px)}",this.Size()
		this.querySelector("Div[ID='"(this.DivID)"'] Div[Current]").Focus()
		/*
			mHTML(this.Doc.Body.OuterHTML)
		*/
	}querySelector(Query){
		return this.Doc.querySelector(Query)
	}querySelectorAll(Query){
		return this.Doc.querySelectorAll(Query)
	}RemoveMediaState(OID:=""){
		Node:=this.querySelector((OID?"Div[OID='"(OID)"']":"Div[Current]"))
		Node.removeAttribute("State")
		this.Highlight()
	}Select(a,b,c){
		Node:=c.nodeName="Div"?c:c.parentNode
		if(a="DoubleClick"){
			if(Node.querySelector("Video").Style.Display="None")
				return
			Node:=Node.querySelector("Video")
			if(Node.Paused)
				Node.Play()
			else
				Node.Pause()
		}else if(a="Click"){
			if(GetKeyState("Shift")||GetKeyState("Control")){
				(Node.hasAttribute("Selected")?Node.removeAttribute("Selected"):Node.SetAttribute("Selected"))
			}else{
				All:=this.Doc.querySelectorAll("Div[ID='"(this.DivID)"'] Div")
				while(aa:=All.Item[A_Index-1]){
					aa.removeAttribute("Selected")
					aa.removeAttribute("Current")
				}
				Node.SetAttribute("Current")
			}
			/*
				this.Selected[OID:=Node.getAttribute("OID")]:={Node:this.Doc.querySelector("Div[ID='"(this.DivID)"'] *[OID='"(OID)"']"),SRC:Node.querySelector("Img[SRC],Video[SRC]").getAttribute("SRC")}
			*/
			this.Highlight()
		}
	}SelectHotkeys(Keys:=""){
		Keys:=IsObject(Keys)?Keys:[]
		for a,b in ["Space"]
			Keys[b]:=b
		Hotkey,IfWinActive,% this.Master.ID
		Sel:=this.ChangeSel,this.SelectionHotkeys:=[]
		for a,b in Keys{
			Hotkey,%a%,%Sel%,On
			this.SelectionHotkeys[a]:=b
		}
	}SetMediaState(State,OID:=""){
		if(State="")
			return
		Node:=this.querySelector((OID?"Div[OID='"(OID)"']":"Div[Current]"))
		Node.setAttribute("State",State)
		this.Highlight()
	}SetStates(Colors:=""){
		this.States:=[]
		for a,b in {Selected:"AA0088",Normal:"CCCCCC"}{
			Color:=Trim(b,"#")
			this.States[a]:=Color
		}
		for a,b in Colors{
			Color:=Trim(b,"#")
			this.States[a]:=Color
		}
	}SetSelect(a*){
		Node:=this.querySelector("Div[Current]")
		(Node.hasAttribute("Selected")?Node.removeAttribute("Selected"):Node.SetAttribute("Selected"))
		this.Highlight()
	}Size(W:="",H:=""){
		(W)?(this.W:=W,this.H:=H):(W:=this.W,H:=this.H),this.Doc.QuerySelector("#DivAfter").innerText:=".Div:After{Height:"((H/this.Y)-(this.Border*2)-2)"px}"
	}TestXY(X,Y){
		return this.querySelector(Foo:="Div[ID='"(this.DivID)"'] Div[X='"(X)"'][Y='"(Y)"']")
	}
}