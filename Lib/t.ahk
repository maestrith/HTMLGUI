t(x*){
	for a,b in x{
		if(RegExMatch(b,"time:(\d+(\.\d+)?)$",Found)){
			SetTimer,CTT,% - Found1*1000
		}else
			Msg.=(IsObject(b)?Obj2String(b):b) "`n"
	}
	Tooltip,%Msg%
	return
	CTT:
	Tooltip
	return
}