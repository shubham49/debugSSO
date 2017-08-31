package spnegocheck;

import java.io.File;

import sun.security.krb5.internal.ktab.KeyTab;
import sun.security.krb5.internal.ktab.KeyTabEntry;

public class KeytabCheck
{
  private static final int MAX_ALLOWED_FILE_LENGTH = 1048576;
  private String fileName = null;
  private File file = null;
  

  public KeytabCheck()
  {
    try
    {
      locateFile();
    } catch (Exception e) {
      System.out.println("Exception caught during location and loading of config file");
      e.printStackTrace();
    }
  }
  
  private void locateFile() throws java.io.IOException, Exception
  {
    fileName = EnvironmentInfo.getEnvironmentInfo().getKeytab();
    
    if (null == fileName) {
      System.out.println("No keytab filename in Environment Info.");
      return;
    }
    
    file = new File(fileName);
    if (file.exists()) {
      System.out.println("Found file using '" + fileName + "'");
      return;
    }
    
    fileName = (System.getenv("DOMAIN_HOME") + "/" + EnvironmentInfo.getEnvironmentInfo().getKeytab());
    
    file = new File(fileName);
    if (file.exists()) {
      System.out.println("Found file using '" + fileName + "'");
      return;
    }
    
    fileName = EnvironmentInfo.getEnvironmentInfo().getKeytab();
    file = null;
  }
  
  public String getFileName() {
    return fileName;
  }
  
  public boolean isKeytabFound() {
    if (null == file) {
      return false;
    }
    if (file.exists()) {
      return true;
    }
    if (file.canRead()) {
      System.out.println("File is not readable");
      return false;
    }
    
    return false;
  }
  
  public boolean isKeytabOK()
  {
    KeyTab kt = KeyTab.getInstance(file);
    //KeyTab.refresh();
    
    KeyTabEntry[] entries = kt.getEntries();
    for (KeyTabEntry entry : entries) {
      System.out.println("Keytab entry:");
      System.out.println("  Service: " + entry.getService());
      System.out.println("    EType: " + entry.getKey().getEType());
      System.out.println("     Time: " + entry.getTimeStamp().toGeneralizedTimeString());
      System.out.println();
    }
    
    return true;
  }
}