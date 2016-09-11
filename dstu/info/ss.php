<html>
<body>
<title>КОСТИ КОСТИ ОЛОЛО</title>
<form name=data>
<a>Number 1: </a><input type="text" size="2" name="a1" />
<a>Number 2: </a><input type="text" size="2" name="a2" />
<a>Количество кубиков: </a><input type="text" size="1"name="n1" /><br>
<input type="button" value="Go!" onclick="paradox()"><br>
</form>
<script type="text/javascript">
var i; var cnt11 = 0; var cnt12=0; var s = 0;var v = 0;
function paradox(a1,a2) {
for (i=0;i<2000;i++)
    {
    function Rand(min, max){
        return Math.round(Math.random()*(max-min))+min;
	    }
	    z=(Rand(1,6));
	    s=(Rand(1,6));
	    for (v=1;v<document.forms["data"].n1.value;v++){   
	s = s+z;
	}
if (s==document.forms["data"].a1.value)
{
	cnt11++;
}
if (s==document.forms["data"].a2.value)
{
	cnt12++;
}
     }
if (cnt11>cnt12)
{
document.write('It\'s working'+'<br>'+'11: '+cnt11+'<br>'+'12: '+cnt12);
}
else 
{
document.write('It\'s not working'+'<br>'+'11: '+cnt11+'<br>'+'12: '+cnt12);
}
}
</script>
</body>
</html>


