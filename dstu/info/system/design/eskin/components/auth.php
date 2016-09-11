<?php 
require_once($_SERVER['DOCUMENT_ROOT'].'/resources/settings/directories.php');
require_once($DirectoryAdmin.'design/eskin/components/upperaview.php');
?>
<script language="javascript" type="text/javascript" src="<?php echo $RootAdmin?>functionality/base/require.js"></script>
<script type="text/javascript" language="javascript">
function Checker()
    {
        var MSG='';
        if (document.Auth.login.value=='')
        {
                MSG+='Введите логин.\n';
        }
        if (document.Auth.password.value=='')
        {
                MSG+='Введите пароль.\n';
        }
        if (!MSG)
        {
                document.Auth.submit();
        }
        else
        {
                alert(MSG);
        }
    }
	IRA.src='<?php echo $RootAdmin;?>design/eskin/images/requireda.gif';
	IRP.src='<?php echo $RootAdmin;?>design/eskin/images/requiredp.gif';
    </script>
  <body bgcolor="#cccccc">
    <form method="post" name="Auth" action="<?php echo $RootAdmin.$_REQUEST['action'];?>">
      <table width="100%" height="100%" cellpadding="0" cellspacing="0" valign="top">
        <tr height="50">
          <td colspan="3"></td>
        </tr>
        <tr>
          <td></td>
          <td>
            <table valign="top" align="center" class="AuthMTable" width="522" height="399" cellpadding="0" cellspacing="0">
              <tr>
                <td>
                  <table  valign="top" width="380" height="300" align="center" valign="center" cellpadding="0" cellspacing="0">
                    <!--authentification-->
                    <tr>
                      <td colspan="2" align="center" style="padding-top:120px">
                        <p class="AuthMessage">ЦИТ ДГТУ<br>
			  Система предоставления информации<br>
                          <b><?php echo $AMessage.'<br>';?></b>
						  <br>
                        </p>
                      </td>
                    </tr>
                    <tr>
                      <td class="AuthLP" width="15%">
                        <b>Логин:</b>
                        <br>
                      </td>
                      <td align="left" valign="middle">
                        <input name="login" type="text" class="AuthInput" onkeyup="Require('Auth','login','RQ1');"> 
						<img name="RQ1" src="<?php echo $RootAdmin;?>design/eskin/images/requireda.gif" alt="Обязательное поле" >
					
                      </td>
                    </tr>
                    <tr>
                      <td class="AuthLP">
                        <b>Пароль:</b>
                      </td>
                      <td align="left">
                        <input name="password" type="password" class="AuthInput" onkeyup="Require('Auth','password','RQ2');"> 
						<img name="RQ2" src="<?php echo $RootAdmin;?>design/eskin/images/requireda.gif" alt="Обязательное поле">
                      </td>
                    </tr>
					<tr height="0">
					</tr>
                    <tr>
                      <td colspan="2" align="center" style="padding-bottom:20px">
<br>
				<input type="button" onclick="javascript:Checker();" value="Войти" style="width:200px">
                      </td>
                    </tr>
					<tr height="50">
					</tr><!--/authentification-->
                  </table>
                </td>
              </tr>
            </table>
          </td>
        </tr>
        <tr>
          <td colspan="3"></td>
        </tr>
      </table>
    </form><?php require_once($DirectoryAdmin.'design/eskin/components/loweraview.php');
    ?>
  </body>
</html>
