<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<%@ page contentType="text/html;charset=windows-1252"%>
<%@page import="spnegocheck.*" %>
<%@page import="spnegocheck.utils.*" %>
<!-- I'm going to hell for this! -->
<%@page import="sun.security.krb5.*" %>

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=windows-1252"/>
    <title>checkkrb5ini</title>
  </head>
<body>
<%
    String forwardURL = "checkkrbloginconf.jsp";
    
    // TODO: check for the two properties
    String kdcProp = System.getProperty("java.security.krb5.kdc");
    String realmProp = System.getProperty("java.security.krb5.realm");
    String dontUseDashDs = "Generally it is recommended that you use a krb5.ini file instead.";
    if ( ( kdcProp != null ) &&
         ( realmProp != null ) ) {
      out.println( "System properties for KDC and default realm are set.<BR/>");
      out.println( dontUseDashDs );
    }
    else
    if ( ( kdcProp != null ) || ( realmProp != null ) ) {
        if ( null != kdcProp )
          out.println( "System property java.security.krb5.kdc is set but java.security.krb5.realm is not set." );
        if ( null != realmProp )
          out.println( "System property java.security.krb5.realm is set but java.security.krb5.kdc is not set." );
        out.println( "<BR/>You cannot set just one of those properties - you must either set BOTH properties or don't set either one.<BR/>" );
        out.println( dontUseDashDs );
    }
    else
    {        
        KrbIniCheck kic = new KrbIniCheck();
        
        if ( !kic.DoesFileExist() ) {
            out.println( kic.getFileName() + " does not exist." );
        }
        else
        {
            out.println( "Found ini file at " + kic.getFileName() + "<P/>" );
            out.println( "File appears to parse OK? " + ( kic.getFileParsedOK() ? "Yes" : "<B>NO</B>" ) + "<BR/>" );
            out.println( "Note that this is a very simple parse check and doesn't mean that the file is actually correct." );
            //out.println( "<BR/><form><textarea cols=\"80\" rows=\"50\">" + kic.GetFileContents() + "</textarea></form><BR/>" );
        }
    }
    
    // in either case try to use the baked in file parser
    try {
        out.println( "Trying to initialize the JDK's internal kerberos config...<BR/>" );
        Config.refresh();
        Config cfg = Config.getInstance();
        
        out.println( "Default realm in krb config file is " + cfg.getDefaultRealm() + "<P/>" );

        // USERDOMAIN and USERDNSDOMAIN should be set
        String userdomain = System.getenv("USERDOMAIN");
        String userdnsdomain = System.getenv("USERDNSDOMAIN");
        
        out.println( "USERDOMAIN environment variable: " + userdomain + "<BR/>" );
        out.println( "USERDNSDOMAIN environment variable: " + userdnsdomain + "<BR/>" );
        
        // compare the environment variable to the default domain in the config file
        if ( ( null == userdnsdomain ) || ( userdnsdomain.trim().equals("") ) )
            out.println( "Environment variable USERDNSDOMAIN is not set." );
        else if ( !userdnsdomain.equalsIgnoreCase(cfg.getDefaultRealm()) )
            out.println( "Environment variable USERDNSDOMAIN doesn't match the default realm. Double check your krb5.ini file to make sure it's correct." );
        else
            out.println( "USERDNSDOMAIN environment variable matches the default_realm in krb5.ini." );
        
        out.println( "<P/>" );


        // Then get into the config file some more.            
        String kdcList = cfg.getKDCList( cfg.getDefaultRealm() );
        out.println( "KDC list is " + kdcList + "<P/>" );
        
        if ( ( null == kdcList ) || ( kdcList.trim().equals("") ) ) {
            //out.println( "KDC list is empty. This is an error in your configuration file!" );
            ErrorReporter.reportError(out,
                                      "KDC list is empty. This is an error in your configuration file!",
                                      request.getRequestURI(), "Try again after updating config file",
                                      "", "ignore and continue" );
        }
        else
        {
            // if there are multiple KDCs in the list they should be separated by spaces
            String kdcListArray[] = null;
            if ( kdcList.contains(" ") )
                kdcListArray = kdcList.split(" ");
            else {
                kdcListArray = new String[1];
                kdcListArray[0] = kdcList;
            }
            
            int WorkingKDCs = 0;
            int nonWorkingKDCs = 0;
            
            for ( String thisKDC : kdcListArray ) {
              boolean bReachable =  ReachableTest.isReachable( thisKDC );
              out.println( "KDC " + thisKDC + " is reachable by basic ICMP Ping or TCP echo service: " + bReachable + "<BR/>" );
              if ( !bReachable ) {
                out.println( "<B>Warning:</B> The JVM thinks that the host " + thisKDC + " specified for the KDC may not be reachable by low level ping or TCP Echo service." );
                out.println( "I will attempt another test but you should double check this setting!<BR/>" );
              }
              
              // Kerberos is on port 88 for both TCP and UDP
              bReachable = ReachableTest.isReachable( thisKDC, 88 );
              out.println( "KDC " + thisKDC + " is reachable on Kerberos TCP port 88: " + bReachable + "<BR/>" );
              if ( bReachable )
                WorkingKDCs++;
              else {
                nonWorkingKDCs++;
                out.println( "<B>Error:</B> Unable to reach Kerberos KDC service on host " + thisKDC + " TCP port 88." );
              }
              out.println("<P/>");
            }
          
            if ( WorkingKDCs == 0 ) {
                out.println( "<B>NO KDCs appear to be reachable on TCP port 88!</B><BR/>" );
                out.println( "Kerberos authentication is unlikely to work!<BR/>" );
            }
            else {
                out.print( "Found " + WorkingKDCs + " KDCs reachable" );
                if ( nonWorkingKDCs > 0 )
                  out.print( " and " + nonWorkingKDCs + " not responding");
                out.println( " on TCP port 88.<BR/>" );
                
                if ( nonWorkingKDCs > 0 )
                    out.println( "Please check to make sure that all of the KDCs listed in your configuration file are correct." );                
            }
            out.println( "<P/>" );
  
            // Other checks go here.
            
            ErrorReporter.reportError(out, "If no errors are shown above you can continue to next check.",
                                      forwardURL, "Continue on to check your krb5login.conf" );
          }
    }
    catch (Exception e ) {
        out.println( "Exception caught - " + e.getMessage() );
    }
%>
</body>
</html>