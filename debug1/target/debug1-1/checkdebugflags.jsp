<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<%@ page contentType="text/html;charset=windows-1252"%>
<%@page import="spnegocheck.*" %>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=windows-1252"/>
    <title>checkdebugflags</title>
  </head>
<body>

Here are the current values of the relevant -D flags:<P/>
sun.security.krb5.debug="<%=System.getProperty("sun.security.krb5.debug")%>" (should be true)
<BR/>
javax.security.auth.useSubjectCredsOnly="<%=System.getProperty("javax.security.auth.useSubjectCredsOnly")%>" (should be false)
<BR/>
java.security.auth.login.config=<%=System.getProperty( "java.security.auth.login.config" ) %> (should be '<%= EnvironmentInfo.getEnvironmentInfo().getKrb5loginconf()%>' to match your environment)
<%
    //  <BR/>
    //  java.security.krb5.realm=TESTDOMAIN.COM
    //  <BR/>
    //  java.security.krb5.kdc=testmachine.testdomain.com
    //  <BR/>
%>
<P/>

If you need help getting those settings right you can just update your startWebLogic.bat to include the following:
<blockquote>
<PRE>
echo starting weblogic with Java version:

%JAVA_HOME%\bin\java %JAVA_VM% -version

set JAVA_OPTIONS=%JAVA_OPTIONS% -Dsun.security.krb5.debug=true -Djavax.security.auth.useSubjectCredsOnly=false -Djava.security.auth.login.config=<%= EnvironmentInfo.getEnvironmentInfo().getKrb5loginconf()%>
</PRE>
</blockquote>

<a href="<%= request.getContextPath() %>">Go back to the beginning of the test app</a>


</body>
</html>