<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<%@ page contentType="text/html;charset=windows-1252"%>
<%@ page import="java.util.List" %>
<%@ page import="spnegocheck.*" %>
<% EnvironmentInfo ei = EnvironmentInfo.getEnvironmentInfo(); %>
<%!

    public boolean doSearch( javax.servlet.jsp.JspWriter out,
                             SearchLDAPForSPNMapping search,
                             String tree,
                             String searches[]
                     ) throws Exception {
                     
      out.println( "Search results under " + tree );
      out.println( "<table border=1>" );
      boolean bErrorDetected = false; // assume the best.
      String textNotFound    = "not found";
      String textMultiple    = "Only one mapping should be present. <B>Delete one of these!</B>";
      String textUnexpected  = "<B>UNEXPECTED!</B>";
      String textDelete      = "<B>(delete this mapping)</B>";
      String textOK          = "(this is generally OK)";
      String textGood        = "(this is correct)";

      for ( String thisSearch : searches ) {
        List<SearchLDAPForSPNMapping.SPNSearchResults> res = search.doSearch( thisSearch, tree );

        //String res = search.doSearch( thisSearch, tree );
        out.println( "<tr><td>" + thisSearch + "</td><td>" );
        // Logic here:
        // cn=Users - must have HTTP/
        //          - must NOT have http/
        //          - may have host/
        // cn=Computers - must NOT have HTTP/
        //              - must not have http/
        //              - may have host/
  
        if ( thisSearch.startsWith("http/" ) ) {
          if ( null == res )
            out.println( textNotFound + " " + textGood );
          else {
            for ( int i=0;i<res.size(); i++ )
              out.println( "Found, DN " + res.get(i).getDn() + "<BR/>");
            bErrorDetected = true;
            out.println( textUnexpected );
            out.println( textDelete );
          }
        }
        else
        if ( null == res ) {
            out.println( textNotFound );
            if ( thisSearch.startsWith( "HTTP/" ) ) {
              if ( tree.equalsIgnoreCase("cn=users") )
              {
                bErrorDetected = true;
                out.println( textUnexpected );
              }
              else { // ( tree.equalsIgnoreCase("cn=Computers") )
                out.println( textGood );
              }
            }
        }
        else {
            for ( int i=0;i<res.size(); i++ )
              out.println( "Found, DN " + res.get(i).getDn() + "<BR/>");
            if (( thisSearch.startsWith( "HTTP/" ) ) &&
                ( tree.equalsIgnoreCase("cn=computers") ) ) {
              bErrorDetected = true;
              out.println( textDelete );
            }
            else
            if ( res.size() > 1 ) {
              bErrorDetected = true;
              out.println( textMultiple );
            }
            else {
              out.println( textGood );
              EnvironmentInfo.getEnvironmentInfo().setUserDNAssociatedWithSPN( res.get(0).getDn() );
              EnvironmentInfo.getEnvironmentInfo().setUserSPN( res.get(0).getUserPrincipalName() );
            }
        }
        out.println( "</td></tr>" );
      }
      out.println( "</table>" );

      return bErrorDetected;
    }
%>

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=windows-1252"/>
    <title>Check SPN</title>
  </head>
<body>
<%
  // update the EnvironmentInfo to contain the values we just collected
  if ( request.getMethod().equals("POST" ) )
  {
    System.out.println( "processing POST to " + request.getPathInfo() );
    ei.setADBaseDN( request.getParameter("adbasedn") );    
    ei.setADHostname( request.getParameter("adhostname") );
    ei.setADUserDN( request.getParameter("aduserdn") );
    ei.setADPassword( request.getParameter("adpassword") );
  }

  // update this with the URL of the next page
  String nextPage = "checkkrb5ini.jsp";
                   
  try
  {
      SearchLDAPForSPNMapping search = new SearchLDAPForSPNMapping();
      search.doBind();
      if ( !search.getBindSuccess() ) {
          ErrorReporter.reportError( out,
                     "Bind to directory failed",
                     "getadinfo.jsp",
                     "Go back to correct your settings",
                     nextPage,
                     "ignore the error and skip ahead" );
          throw new Exception("abort");
      }

      // Now we do a search to see if there are any entries mapping the SPN
      // HTTP/<machine host name in lowecase>
      // HTTP/<machine canonical hostname in lowercase>
      out.println( "Bind was successful.<P/>" );
  
      String searches[] = {
          "host/" + ei.getCanonicalHostname(),
          "host/" + ei.getHostname(),
          "HTTP/" + ei.getCanonicalHostname(),
          "HTTP/" + ei.getHostname(),
          // a couple of mappings that SHOULDN'T be there
          "http/" + ei.getCanonicalHostname(),
          "http/" + ei.getHostname(),
          
      };
  
//      out.println( "Search results under cn=Computers:<table>" );
//      boolean bErrorDetected = false; // assume the best.
//      for ( String thisSearch : searches ) {
//        String res = search.doSearch( thisSearch );
//        out.println( "<tr><td>" + thisSearch + "</td><td>" );
//        if ( null == res )
//            out.println( "not found (this is generally OK)" );
//        else {
//            out.println( "Found, DN " + res );
//            if ( thisSearch.startsWith( "HTTP/" ) ) {
//              bErrorDetected = true;
//              out.println( "<B>UNEXPECTED!</B>" );
//            }
//        }
//        out.println( "</td></tr>" );
//      }
//      out.println( "</table>" );
      boolean bErrorDetected = doSearch(out, search, "cn=Computers", searches);
      if ( bErrorDetected ) {
          ErrorReporter.reportError( out,
                "There should not be a mapping from HTTP/ to a computer entry in Active Directory." + 
                "<BR/>Use setspn to remove this mapping before continuing.",
                request.getRequestURI(), "reload this page after fixing the error.",
                nextPage, "ignore the error and skip ahead" );
          throw new Exception("abort"); 
      }
      
      out.println( "<P/>" );
      
      // then do it again for under cn=Users
      bErrorDetected = doSearch(out, search, "cn=Users", searches);
      if ( bErrorDetected ) {
          ErrorReporter.reportError( out,
                "There should be a mapping from HTTP/" + ei.getHostname() +
                " and HTTP/" + ei.getCanonicalHostname() +
                " to a User entry in Active Directory.<BR>" + 
                "<B>*** remember that HTTP should be capital letters and the host name should be lowercase. ***</B><BR/>" +
                "Use setspn to add an appropriate mapping before continuing.",
                request.getRequestURI(), "reload this page after fixing the error.",
                nextPage, "ignore the error and skip ahead" );
          throw new Exception("abort"); 
      }

      
      // and now provide a link onward
      out.println( "<P/>SPN mappings look good.<BR>" );
      out.println( "<a href=\"" + nextPage + "\">Continue on to next step.</a>" );
  }
  catch (Exception e ) {
      if ( e.getMessage().equals("abort") ) {
          // do nothing.
      }
      else
      {
          System.out.println( "Exception caught." );
          e.printStackTrace();
      }
  }

%>
</body>
</html>
