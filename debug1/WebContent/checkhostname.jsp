<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<%@ page contentType="text/html;charset=windows-1252"%>
<%@page import="spnegocheck.*" %>
<% EnvironmentInfo ei = EnvironmentInfo.getEnvironmentInfo(); %>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=windows-1252"/>
    <title>checkspnregistration</title>
  </head>
<body>

<P/>
This host name: <%=ei.getHostname()%><BR/>
This hosts canonical name: <%=ei.getCanonicalHostname()%><BR/>
Host name entered in browser: <script language="javascipt" type="text/javascript">document.write(location.hostname);</script><BR/>

<P/>

<script language="javascript" type="text/javascript">
if ( ( "<%=ei.getHostname()%>" != location.hostname ) &&
     ( "<%=ei.getCanonicalHostname()%>" != location.hostname ) ) {
  document.write("The value in the address bar doesn't match up with the value I expected.<BR/>" );
  document.write("I expected <%=ei.getHostname()%> but instead got " + location.hostname + "<BR/>" );
  document.write("This MAY be normal if you are accessing via a web server front end of some sort.");
  document.write("BUT this will likely cause issues when your browser tries to present a Kerberos ticket to the WebLogic server.");
}
else
{
  document.write("Host name appears to match browser URL hostname.");
}
</script>

<P/>
<a href="getadinfo.jsp">Continue to next check</a>

</body>
</html>