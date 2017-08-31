<%@page import="spnegocheck.*" %>
<%
    AuthorizationHeaderProcessor ahp = new AuthorizationHeaderProcessor( request );
    
    if ( ! ahp.containsHeader() )
        out.println( "No Authorization header." );
    else
    if ( ahp.getAuthType().equals("Basic") )
        out.println( "Basic authentication header presented." );
    else
    if ( ahp.getAuthType().equals("Negotiate") )
    {
        // get the inbound authorization header
        out.println( "Authorization header is Negotiate type with contents" );
        out.println( "<PRE>" + request.getHeader("Authorization") + "</PRE>" );
        
        out.println( "<BR/>" );
      
        if ( ahp.isNTLM() )
            out.println( "Authorization header is an NTLM header, not Kerberos." );
        else
        if ( ahp.isKerberos() )
            out.println( "Authorization header seems to be Kerberos." );    
        else
            out.println( "Unknown authorization header content." );
    }

    out.println( "<P/>" );
%>
