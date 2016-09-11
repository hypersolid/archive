<?php
$srchrq = addslashes(stripslashes(htmlspecialchars(strip_tags(mysql_real_escape_string ($_POST["name"])))));
if (strlen($srchrq) <= 3){
	echo "Слишком короткий запрос!"; 
	die;
}
$deleline = "ии|ия|ью|ею|ей|ой|ою|ем|ом|а|я|о|е|ы|и|у|ю";
$ALARM = "EPIC FAIL";
$dbn = "ddm_files";
$mhst = "127.0.0.1";     $muser = "info";     $mpass = "infopasskoir";
$slink = mysql_connect($mhst,$muser,$mpass)
      or die ($ALARM . mysql_error());
mysql_select_db("info") or die ($ALARM);
$tmp2 = explode(' ', $srchrq);
$tmp = array();
while($ttt = array_shift($tmp2)){
	if(strlen($ttt) > 5 && preg_match("/^(.+)($deleline)$/i", $ttt, $m)){
		array_push($tmp, $m[1]);
	}else{
		$ttt = str_replace("+", '\\+', $ttt);
		$ttt = str_replace("-", '\\-', $ttt);
		
		array_push($tmp, $ttt);
	}
}
$fname = "SELECT fname FROM {$dbn} WHERE fname REGEXP '".array_shift($tmp)."'";
$result = mysql_query($fname);
	  print "<table>\n";
	  print "\t\t<td><b>Найденные файлы </b></td>\n";
	      while ($line = mysql_fetch_array($result, MYSQL_ASSOC)) {
	              foreach ($line as $col_value) {
			      foreach ($tmp as $it){
				      
				      if(!preg_match("/$it/", $col_value)){
					      continue 3;
				      }
			      }
	              print "\t<tr>\n";
		      $flocate = "SELECT flocate FROM {$dbn} WHERE fname LIKE '%{$col_value}%'";
		      #$flocate = "SELECT flocate FROM {$dbn} WHERE fname LIKE '".implode(" ", $tmp)."'";
if($result_loc = mysql_query($flocate)){
	      while ($line1 = mysql_fetch_array($result_loc, MYSQL_ASSOC)) {
	              foreach ($line1 as $col_value1) {
		      } //Вот это вася мегагавнокод!!1111адин ЛОЛ!!!
		      # mysql_free_result($result_loc);
		      }
		      }
		      $URL = str_replace('%2F', '/', rawurlencode($col_value1));
		      print "\t\t<td><a href=\"/$URL\"> $col_value<a></td>\n";
				          }
		      print "\t</tr>\n";
					      }
		      print "</table>\n";
              		          mysql_free_result($result);
