package spnegocheck;

import java.io.PrintStream;
import java.util.Hashtable;
import java.util.LinkedList;
import java.util.List;
import javax.naming.AuthenticationException;
import javax.naming.NamingEnumeration;
import javax.naming.NamingException;
import javax.naming.directory.Attribute;
import javax.naming.directory.Attributes;
import javax.naming.directory.DirContext;
import javax.naming.directory.InitialDirContext;
import javax.naming.directory.SearchControls;
import javax.naming.directory.SearchResult;

public class SearchLDAPForSPNMapping
{
  EnvironmentInfo ei = null;
  
  public SearchLDAPForSPNMapping()
  {
    this.ei = EnvironmentInfo.getEnvironmentInfo();
  }
  
  DirContext dctx = null;
  
  public void doBind()
  {
    DirContext dctx = null;
    
    Hashtable env = new Hashtable();
    
    String sp = "com.sun.jndi.ldap.LdapCtxFactory";
    env.put("java.naming.factory.initial", sp);
    
    String ldapUrl = "ldap://" + this.ei.getADHostname() + "/" + this.ei.getADBaseDN();
    
    System.out.println("LDAP URL is " + ldapUrl);
    env.put("java.naming.provider.url", ldapUrl);
    
    env.put("java.naming.security.authentication", "simple");
    System.out.println("username is " + this.ei.getADUserDN());
    env.put("java.naming.security.principal", this.ei.getADUserDN());
    
    env.put("java.naming.security.credentials", this.ei.getADPassword());
    try
    {
      dctx = new InitialDirContext(env);
      
      System.out.println("Bind succeeded.");
      this.dctx = dctx;
    }
    catch (AuthenticationException nae)
    {
      System.out.println("Authentication failure.");
      nae.printStackTrace();
      dctx = null;
    }
    catch (NamingException ne)
    {
      System.out.println("Naming exception.");
      ne.printStackTrace();
      dctx = null;
    }
  }
  
  public boolean getBindSuccess()
  {
    return null != this.dctx;
  }
  
  public class SPNSearchResults
  {
    String dn = null;
    String cn = null;
    String userPrincipalName = null;
    LinkedList<String> servicePrincipalNames = null;
    
    private SPNSearchResults() {}
    
    private void reset()
    {
      this.dn = null;
      this.cn = null;
      this.userPrincipalName = null;
      this.servicePrincipalNames = null;
    }
    
    private void setCn(String cn)
    {
      this.cn = cn;
    }
    
    public String getCn()
    {
      return this.cn;
    }
    
    private void setUserPrincipalName(String userPrincipalName)
    {
      this.userPrincipalName = userPrincipalName;
    }
    
    public String getUserPrincipalName()
    {
      return this.userPrincipalName;
    }
    
    private void setServicePrincipalNames(LinkedList<String> servicePrincipalNames)
    {
      this.servicePrincipalNames = servicePrincipalNames;
    }
    
    public List<String> getServicePrincipalNames()
    {
      return this.servicePrincipalNames;
    }
    
    public String getDn()
    {
      return this.dn;
    }
    
    private void setDn(String dn)
    {
      this.dn = dn;
    }
    
    private void addServicePrincipalName(String servicePrincipalName)
    {
      if (null == this.servicePrincipalNames) {
        this.servicePrincipalNames = new LinkedList();
      }
      this.servicePrincipalNames.add(servicePrincipalName);
    }
  }
  
  public List<SPNSearchResults> doSearch(String spn, String branch)
    throws NamingException
  {
    LinkedList<SPNSearchResults> searchResults = new LinkedList();
    if (null == this.dctx) {
      doBind();
    }
    SearchControls sc = new SearchControls();
    String[] attributeFilter = { "cn", "servicePrincipalName", "userPrincipalName" };
    sc.setReturningAttributes(attributeFilter);
    sc.setSearchScope(2);
    
    String filter = "servicePrincipalName=" + spn;
    System.out.println("Executing search for " + filter);
    NamingEnumeration results = this.dctx.search(branch, filter, sc);
    while (results.hasMore())
    {
      SPNSearchResults thisResult = new SPNSearchResults();
      
      SearchResult sr = (SearchResult)results.next();
      Attributes attrs = sr.getAttributes();
      
      String dn = sr.getNameInNamespace();
      System.out.println("Found DN " + dn);
      thisResult.setDn(dn);
      
      Attribute attr = attrs.get("cn");
      String cn = (String)attr.get();
      System.out.println("cn: " + cn);
      thisResult.setCn(cn);
      
      attr = attrs.get("userPrincipalName");
      if (null != attr)
      {
        String userPrincipalName = (String)attr.get();
        System.out.println("userPrincipalName:" + userPrincipalName);
        thisResult.setUserPrincipalName(userPrincipalName);
      }
      attr = attrs.get("servicePrincipalName");
      
      NamingEnumeration vals = attr.getAll();
      while (vals.hasMoreElements())
      {
        String val = (String)vals.next();
        System.out.println("servicePrincipalName: " + val);
        
        boolean bUseVal = false;
        if (spn.toLowerCase().startsWith("http/"))
        {
          if (spn.equals(val)) {
            bUseVal = true;
          }
        }
        else if (spn.equalsIgnoreCase(val)) {
          bUseVal = true;
        }
        if (bUseVal) {
          thisResult.addServicePrincipalName(val);
        }
      }
      if (null != thisResult.getServicePrincipalNames()) {
        searchResults.add(thisResult);
      }
      System.out.println();
    }
    if (searchResults.size() > 0) {
      return searchResults;
    }
    return null;
  }
  
  public void doUnbind()
  {
    if (null != this.dctx)
    {
      try
      {
        this.dctx.close();
      }
      catch (NamingException e) {}
      this.dctx = null;
    }
  }
}
