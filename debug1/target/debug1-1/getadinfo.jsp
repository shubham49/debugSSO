<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<%@ page contentType="text/html;charset=windows-1252"%>
<%@page import="spnegocheck.*" %>
<% EnvironmentInfo ei = EnvironmentInfo.getEnvironmentInfo(); %>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=windows-1252"/>
    <title>GET AD Info</title>
  </head>
<body>
In order to check your SPN registration I need info on your Active Directory
Server. You may <a href="">skip this check</a>
<P/>
<form action="checkspn.jsp" method="POST">
<table>

<tr>
<td>DN of the root DN of your AD</td>
<td><input name="adbasedn" size="50" value="<%=ei.getADBaseDN()%>"></td>
</tr>

<tr>
<td>AD Hostname</td>
<td><input name="adhostname" size="50" value="<%=ei.getADHostname()%>"></td>
</tr>

<tr>
<td>User DN I can use to search AD</td>
<td><input name="aduserdn" size="50" value="<%=ei.getADUserDN()%>"></td>
</tr>

<tr>
<td>AD user's password</td>
<!-- this should be type="password" -->
<td><input name="adpassword" value="<%=ei.getADPassword()%>" type="password"></td>
</tr>

</table>

<input type="submit" value=" Submit "/>
</form>

</body>
</html>