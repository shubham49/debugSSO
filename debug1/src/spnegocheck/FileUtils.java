package spnegocheck;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;


public class FileUtils
{
  private static final int MAX_ALLOWED_FILE_LENGTH = 1048576;
  
  public FileUtils() {}
  
  public static String getFileContents(File f)
    throws IOException, Exception
  {
    byte[] bytes = getFileAsBytes(f);
    return new String(bytes);
  }
  
  public static String getFileContents(String fileName) throws IOException, Exception
  {
    File f = new File(fileName);
    byte[] bytes = getFileAsBytes(f);
    return new String(bytes);
  }
  
  private static byte[] getFileAsBytes(File file) throws IOException, Exception
  {
    BufferedInputStream bis = new BufferedInputStream(new FileInputStream(file));
    
    if (file.length() > 1048576L) {
      throw new Exception("File is " + file.length() + " bytes and is larger than allowed length of  " + 1048576);
    }
    byte[] bytes = new byte[(int)file.length()];
    bis.read(bytes);
    bis.close();
    return bytes;
  }
}