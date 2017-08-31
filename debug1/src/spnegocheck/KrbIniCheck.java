package spnegocheck;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintStream;
import java.util.Map;
import java.util.Properties;
import sun.security.krb5.Config;
import sun.security.krb5.KrbException;


















public class KrbIniCheck
{
  private static final String fileName = "c:/windows/krb5.ini";
  private File file = null;
  String fileContents = "";
  
  Map<String, Properties> iniContents = null;
  
  String error = null;
  
  public KrbIniCheck()
  {
    try
    {
      file = new File("c:/windows/krb5.ini");
      
      if (file.exists()) {
        fileContents = FileUtils.getFileContents(file);
        
        ParseFileContents();
      }
      

    }
    catch (FileNotFoundException e) {}catch (IOException e) {}catch (Exception e)
    {
      error = e.getMessage();
    }
  }
  

  private void CheckConfig()
    throws KrbException
  {
    Config cfg = Config.getInstance();
    
    String defaultRealm = cfg.getDefaultRealm();
    
    String kdcList = cfg.getKDCList(cfg.getDefaultRealm());
  }
  

  public String getFileName()
  {
    return "c:/windows/krb5.ini";
  }
  
  public boolean DoesFileExist() {
    return file.exists();
  }
  
  public String GetFileContents() {
    return fileContents;
  }
  
  public boolean getFileParsedOK() {
    return null == error;
  }
  
  private void ParseFileContents()
    throws Exception
  {
    if ((null == fileContents) || (fileContents.trim().equals("")))
    {
      return;
    }
    

    String[] lines = fileContents.split("\\r?\\n");
    
    String section = "";
    String realmName = "";
    
    boolean bInCurly = false;
    
    for (String line : lines)
    {
      line = line.trim();
      if ((!line.trim().equals("")) && (!line.startsWith("#")))
      {


        if ((line.startsWith("[")) && (line.endsWith("]")))
        {

          section = line.substring(1, line.length() - 1);
          System.out.println("In section '" + section + "'");
        }
        else if ((section.equals("libdefaults")) || (section.equals("domain_realm")) || (section.equals("appdefaults")))
        {

          if (iniContents.get(section) == null) {
            iniContents.put(section, new Properties());
          }
          

          String[] splits = line.split("=", 1);
          String key = splits[0].trim();
          String value = splits[1].trim();
          ((Properties)iniContents.get(section)).put(key, value);
        }
        else if (section.equals("realms"))
        {






          if (line.contains("}")) {
            bInCurly = false;
          }
          else if (!bInCurly)
          {


            if (line.contentEquals("{")) {
              realmName = line.substring(line.indexOf("=")).trim();
              System.out.println("Realm name '" + realmName + "' found");
            }
            
          }
          
        }
        else
        {
          throw new Exception("Found a setting line in an unexpected section - " + section);
        }
      }
    }
  }
}