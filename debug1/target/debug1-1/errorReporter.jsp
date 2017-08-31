<%!
  public void reportError( javax.servlet.jsp.JspWriter out,
                           String text,
                           String backURL,
                           String backLinkText,
                           String forwardURL,
                           String forwardText ) {
    try {                       
    out.println( text );
    out.println( "<BR/>" );
    out.println( "<a href=" + backURL + ">" + backLinkText + "</a><BR./>" );
    out.println( "or<BR/>" );
    out.println( "<a href=" + forwardText + ">ignore the error</a><BR>" );
    }
    catch ( Exception e ) {}
    
}
%>
