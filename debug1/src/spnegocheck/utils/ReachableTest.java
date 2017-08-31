package spnegocheck.utils;

import java.io.PrintStream;

public class ReachableTest {
  public ReachableTest() {}
  
  public static boolean isReachable(String hostname) {
    boolean bReturn = false;
    try {
      java.net.InetAddress address = java.net.InetAddress.getByName(hostname);
      


      bReturn = address.isReachable(3000);
      System.out.println("Reachable? " + bReturn);
    } catch (java.net.UnknownHostException e) {
      System.err.println("Unable to lookup " + hostname);
    } catch (java.io.IOException e) {
      System.err.println("Unable to reach " + hostname);
    }
    
    return bReturn;
  }
  
  public static boolean isReachable(String hostname, int port)
  {
    try {
      java.net.Socket t = new java.net.Socket(hostname, port);
      
      java.io.DataInputStream dis = new java.io.DataInputStream(t.getInputStream());
      PrintStream ps = new PrintStream(t.getOutputStream());
      


      ps.println("Hello");
      
      t.close();
      System.out.println("Connection seems to have succeeded.");
      return true;
    }
    catch (java.io.IOException e) {
      e.printStackTrace();
    }
    
    return false;
  }
}