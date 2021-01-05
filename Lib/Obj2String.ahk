Obj2String(Obj,FullPath:=1,BottomBlank:=0){
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
					Obj2String(b,FullPath "." a,BottomBlank)
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
}