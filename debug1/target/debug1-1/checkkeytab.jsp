<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<%@ page contentType="text/html;charset=windows-1252"%>
<%@page import="spnegocheck.*" %>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=windows-1252"/>
    <title>checkkeytab</title>
  </head>
<body>
<%
    String forwardURL = "checkdebugflags.jsp";
    String forwardText = "Check your Kerberos debug flags";

    String keytabFile = EnvironmentInfo.getEnvironmentInfo().getKeytab();

    if ( ( null == keytabFile ) || (keytabFile.trim().equals("") ) ) {
        out.println( "keytab file is unknown. Please click back in your browser." );
    }
    else {
      out.println( "keytab file name specified in config file: '" + keytabFile + "'<BR/>" );

      KeytabCheck ktc = new KeytabCheck();
  
      
      if ( ! ktc.isKeytabFound() ) {
          ErrorReporter.reportError(out, "keytab file NOT located. Please rerun your kinit and other command line utilities.",
                                    request.getRequestURI(), "reload this page after fixing the error.",
                                    forwardURL, forwardText);
                                    
          out.println( "for reference I recommend bringing up a command prompt and performing the following:" );
          out.println( "<PRE>" );
          out.println( "cd " + System.getenv("DOMAIN_HOME") );
          out.println( "java.exe -Dsun.security.krb5.debug=true sun.security.krb5.internal.tools.Ktab -k " + keytabFile + " -a " + EnvironmentInfo.getEnvironmentInfo().getUserSPN() );
          out.println( "</PRE>" );
      }
      else
      {
        out.println( "keytab file name as located on filesystem as '" + ktc.getFileName() + "'<BR/>" );
        
        if ( ! ktc.isKeytabOK() ) {
            ErrorReporter.reportError(out, "keytab file does not appear to be OK.",
                                      request.getRequestURI(), "reload this page after fixing the error.",
                                      forwardURL, forwardText);
        }
        else {
            ErrorReporter.reportError(out, "keytab looks OK.",
                              forwardURL, forwardText);
        }
      }
    }
%>
</body>
</html>