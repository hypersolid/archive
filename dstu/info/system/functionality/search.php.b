<?php 
$name = $_POST['name'];
$slink = mysql_connect("127.0.0.1", "root", "vbhjndjhtw")
      or die ("EPIC FAIL COULD NOT CONNECT MYSQL:" . mysql_error());
mysql_select_db("mdoc") or die ("EPIC FAIL COULD NOT SELECT DATABASE");
$fname = "SELECT fname FROM ddm_files WHERE fname LIKE '%{$name}%'";
//$flocate = "SELECT flocate FROM ddm_files WHERE fname LIKE '%{$username}%'";
$result1 = mysql_query($fname);
$result = mysql_query($flocate);
$line2 = mysql_fetch_array($result1, MYSQL_ASSOC);
	  print "<table>\n";
	      while ($line = mysql_fetch_array($result, MYSQL_ASSOC)) {
	              print "\t<tr>\n";
	              foreach ($line as $col_value) {
                  print "\t\t<td>$col_value</td>\n";
				          }
			          print "\t</tr>\n";
					      }
			          print "</table>\n";
				  
				  echo "<a href =\"$col_value\">$col_value</a>";
		          mysql_free_result($result);
			          mysql_close($link); 
