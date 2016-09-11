function Require(form,input,flag)
	{
		var value=eval('document.'+form+'.'+input+'.value');
		if (value)
		{
			eval('document.'+form+'.'+flag+'.src=IRP.src;');
		}
		else
		{
			eval('document.'+form+'.'+flag+'.src=IRA.src;');
		}
	}
var IRA=new Image();
var IRP=new Image();
