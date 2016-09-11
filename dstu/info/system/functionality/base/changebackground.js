	var previous="";
	function getObject(id) 
    {
        if (document.getElementById) return document.getElementById(id);
        if (document.all) return document.all[id];
        if (document.layers) return document.layers[id];
    }
	function getStyle(id) 
    {
        return (document.layers ? getObject(id) : getObject(id).style);
    } 
	function setLayerBackground(layername,color)
    {
            if (document.layers) getStyle(layername).bgColor = color;
            else getStyle(layername).backgroundColor = color;
    } 
	function SavePreviousColor(C)
	{
		 if (document.layers) previous=getStyle(C).bgColor;
         else previous=getStyle(C).backgroundColor;
	}
	function FBP(C)
	{
		setLayerBackground(C,previous);
	}
	function FBA(C)
	{
		SavePreviousColor(C);
		setLayerBackground(C,'#00ccFF');
	}