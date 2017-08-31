<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<%@ page contentType="text/html;charset=windows-1252"%>
<%@page import="spnegocheck.*" %>
<%@page import="spnegocheck.utils.*" %>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=windows-1252"/>
    <title>checkkrbloginconf</title>
  </head>
<body>
<%
    String forwardURL = "checkkeytab.jsp";
    String forwardText = "Check keytab file";
    
    Krb5loginconfCheck confcheck = new Krb5loginconfCheck();
    
    EnvironmentInfo.getEnvironmentInfo().setKrb5loginconf(confcheck.getFilename());
%>

Trying to locate KRB login config file with name '<%=confcheck.getFilename()%>'<BR/>
File <%=(confcheck.isFileFound() ? "WAS" : "<B>was NOT</B>")%> found.<BR/>
<P/>
<%
try {
  confcheck.parseFileContents();
  out.println( "Config file contents:<BR/>" );
  out.println( "User principal " + confcheck.getPrincipalName() + "<BR/>" );
  out.println( "Keytab file " + confcheck.getKeytab() + "<BR/>" );
  
  // store them back in the environment info
  // EnvironmentInfo.getEnvironmentInfo().setUserSPN( confcheck.getPrincipalName() );
  EnvironmentInfo.getEnvironmentInfo().setKeytab( confcheck.getKeytab() );
  
  // additional checks:
  // make sure that the user principal is one with the SPN mapping
  
  out.println("<P/>");
  
  String expectedSPN = EnvironmentInfo.getEnvironmentInfo().getUserSPN();
  if ( null != expectedSPN )
      out.println( "Username associated with SPN in AD is " + expectedSPN  + "<BR/>");
  
  if ( null == expectedSPN )
      ErrorReporter.reportError(out, "<B>Can't check whether the SPN specified in krblogin config file is correct because you skipped the SPN mapping check.</B>",
                                forwardURL, "Continue anyway" );
  else
  if ( !expectedSPN.equalsIgnoreCase( confcheck.getPrincipalName() ) ) {
      ErrorReporter.reportError( out, "<B>The SPN specified in krblogin config file does NOT match the user used for the SPN mapping.</B>Recheck your setspn step!",
                      request.getRequestURI(), "reload this page after fixing the error.",
                      forwardURL, "ignore the error and skip ahead" );
  }
  else {
      out.println( "User principal used in krblogin config file and SPN mappings in AD match.<BR/>" );
      String pn = confcheck.getPrincipalName();
      String dompart = pn.substring( pn.indexOf('@') + 1 );
      
      if ( ! dompart.toUpperCase().equals(dompart) ) {
          String userpart = pn.substring(0,pn.indexOf('@'));
          ErrorReporter.reportError( out, "<B>The SPN specified in krblogin config file should have the domain portion in UPPERCASE.<BR/>" +
                    "Please change the principal in " + confcheck.getFilename() + " to " + userpart + "@" + dompart.toUpperCase() + "</B>",
                      request.getRequestURI(), "reload this page after fixing the error.",
                      forwardURL, "ignore the error and skip ahead" );
      }
      else {
          ErrorReporter.reportError(out, "Settings seem OK", forwardURL, forwardText);
      }
  }
}
catch (Exception e ) {
    out.println( "Error detected parsing file contents!<BR/>" + e.getMessage() + "<BR/>" );
    System.out.println( "Exception details:" );
    e.printStackTrace();
}
%>


</body>
</html>