package spnegocheck;

import java.io.IOException;
import javax.servlet.http.HttpServletRequest;
import sun.misc.BASE64Decoder;

public class AuthorizationHeaderProcessor
{
  private String header = null;
  private String authType = null;
  private byte[] decodedHeader = null;
  


  public AuthorizationHeaderProcessor() {}
  

  public AuthorizationHeaderProcessor(HttpServletRequest request)
  {
    header = request.getHeader("Authorization");
    
    if (null != header)
    {

      if (header.contains(" ")) {
        authType = header.substring(0, header.indexOf(" "));
        System.out.println("Auth type: " + authType);
        


        String decodablePart = header.substring(header.indexOf(" ") + 1);
        try
        {
          BASE64Decoder decoder = new BASE64Decoder();
          System.out.println("Decoding " + decodablePart);
          decodedHeader = decoder.decodeBuffer(decodablePart);
        }
        catch (IOException e) {}
      }
    }
  }
  
  public boolean containsHeader() {
    return header != null;
  }
  
  public boolean isNTLM() {
    String s = new String(decodedHeader, 0, 7);
    

    return s.equals("NTLMSSP");
  }
  
  public boolean isKerberos() {
    if (header.startsWith("Negotiate YII")) {
      return true;
    }
    return false;
  }
  
  public String getAuthType() {
    return authType;
  }
}