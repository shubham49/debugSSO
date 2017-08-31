package spnegocheck;

import java.net.InetAddress;

public class EnvironmentInfo
{
  private static EnvironmentInfo environmentInfo = null;
  
  public static EnvironmentInfo getEnvironmentInfo() {
    if (null == environmentInfo) {
      environmentInfo = new EnvironmentInfo();
    }
    
    return environmentInfo;
  }
  

  private String hostname = "";
  private String canonicalhostname = "";
  

  private String adHostname = "";
  private String adUserDN = "";
  private String adPassword = "";
  private String adBaseDN = "";
  private String userDNAssociatedWithSPN = "";
  

  private String userSPN = "";
  private String keytab = "";
  
  private String krb5loginconf = "";
  
  private EnvironmentInfo() {
    try {
      InetAddress addr = InetAddress.getLocalHost();
      



      canonicalhostname = addr.getCanonicalHostName();
      hostname = addr.getHostName();
    }
    catch (java.net.UnknownHostException e) {}
    
    if (null != hostname) {
      adBaseDN = canonicalhostname.replaceAll("\\.", ",dc=");
      adBaseDN = adBaseDN.substring(adBaseDN.indexOf(",") + 1);
    }
    
    adUserDN = ("cn=administrator,CN=Users," + adBaseDN);
  }
  
  public void setHostname(String hostname) {
    this.hostname = hostname;
  }
  
  public String getHostname() {
    return hostname;
  }
  
  public void setADHostname(String adHostname) {
    this.adHostname = adHostname;
  }
  
  public String getADHostname() {
    return adHostname;
  }
  
  public void setADPassword(String adPassword) {
    this.adPassword = adPassword;
  }
  
  public String getADPassword() {
    return adPassword;
  }
  
  public void setADBaseDN(String adBaseDN) {
    this.adBaseDN = adBaseDN;
  }
  
  public String getADBaseDN() {
    return adBaseDN;
  }
  
  public void setADUserDN(String adUserDN) {
    this.adUserDN = adUserDN;
  }
  
  public String getADUserDN() {
    return adUserDN;
  }
  
  public void setCanonicalHostname(String canonicalhostname) {
    this.canonicalhostname = canonicalhostname;
  }
  
  public String getCanonicalHostname() {
    return canonicalhostname;
  }
  
  public String getUserDNAssociatedWithSPN() {
    return userDNAssociatedWithSPN;
  }
  
  public void setUserDNAssociatedWithSPN(String userDNAssociatedWithSPN) {
    this.userDNAssociatedWithSPN = userDNAssociatedWithSPN;
  }
  
  public void setUserSPN(String userSPN) {
    this.userSPN = userSPN;
  }
  
  public String getUserSPN() {
    return userSPN;
  }
  
  public void setKeytab(String keytab) {
    this.keytab = keytab;
  }
  
  public String getKeytab() {
    return keytab;
  }
  
  public void setKrb5loginconf(String krb5loginconf) {
    this.krb5loginconf = krb5loginconf;
  }
  
  public String getKrb5loginconf() {
    return krb5loginconf;
  }
}