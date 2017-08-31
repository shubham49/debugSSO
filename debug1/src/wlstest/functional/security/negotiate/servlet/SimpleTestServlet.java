package wlstest.functional.security.negotiate.servlet;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Enumeration;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpUtils;

public class SimpleTestServlet extends HttpServlet
{
    public void service(HttpServletRequest req, HttpServletResponse res)
        throws ServletException, IOException
    {System.out.println("in");
        res.setContentType("text/html");
        PrintWriter out = res.getWriter();

        out.println("<html>");
        out.println("<head><title>Simple Test Servlet</title></head>");
        out.println("<body>");
        out.println("<h3>Requested URL:</h3>");
        out.println("<pre>");
        out.println(HttpUtils.getRequestURL(req).toString());
        out.println("</pre>");
    
        Enumeration theEnum = getServletConfig().getInitParameterNames();
        if (theEnum != null)
        {
            boolean first = true;
            while (theEnum.hasMoreElements())
            {
                if (first)
                {
                    out.println("<h3>Init Parameters</h3>");
                    out.println("<pre>");
                    first = false;
                }
                String param = (String) theEnum.nextElement();
                out.println(" "+param+": "+getInitParameter(param));
            }
            out.println("</pre>");
        }

        out.println("<h3>Request information:</h3>");
        out.println("<pre>");

        print(out, "Request method", req.getMethod());
        print(out, "Request URI", req.getRequestURI());
        print(out, "Request protocol", req.getProtocol());
        print(out, "Servlet path",     req.getServletPath());
        print(out, "Path info",        req.getPathInfo());
        print(out, "Path translated",  req.getPathTranslated());
        print(out, "Query string",     req.getQueryString());
        print(out, "Content length",   req.getContentLength());
        print(out, "Content type",     req.getContentType());
        print(out, "Server name",      req.getServerName());
        print(out, "Server port",      req.getServerPort());
        print(out, "Remote user",      req.getRemoteUser());
        print(out, "Remote address",   req.getRemoteAddr());
        print(out, "Remote host",      req.getRemoteHost());
        print(out, "Scheme",           req.getScheme());
        print(out, "Authorization scheme", req.getAuthType());
        print(out, "Request scheme", req.getScheme());
        out.println("</pre>");

        Enumeration e = req.getHeaderNames();
        if (e.hasMoreElements())
        {
            out.println("<h3>Request headers:</h3>");
            out.println("<pre>");
            while (e.hasMoreElements())
            {
                String name = (String)e.nextElement();
                out.println(" " + name + ": " + req.getHeader(name));
            }
            out.println("</pre>");
        }

        e = req.getParameterNames();
        if (e.hasMoreElements())
        {
            out.println("<h3>Servlet parameters (Single Value style):</h3>");
            out.println("<pre>");
            while (e.hasMoreElements())
            {
                String name = (String)e.nextElement();
                out.println(" " + name + " = " + req.getParameter(name));
            }
            out.println("</pre>");
        }
    
        e = req.getParameterNames();
        if (e.hasMoreElements())
        {
            out.println("<h3>Servlet parameters (Multiple Value style):</h3>");
            out.println("<pre>");
            while (e.hasMoreElements())
            {
                String name = (String)e.nextElement();
                String vals[] = (String []) req.getParameterValues(name);
                if (vals != null)
                {
                    out.print("<b> " + name + " = </b>"); 
                    out.println(vals[0]);
                    for (int i = 1; i<vals.length; i++)
                        out.println("           " + vals[i]);
                }
                out.println("<p>");
            }
            out.println("</pre>");
        }

        out.println("<h3>Request Attributes:</h3>");
        e = req.getAttributeNames();
        if (e.hasMoreElements())
        {
            out.println("<pre>");
            while (e.hasMoreElements())
            {
                String name = (String)e.nextElement();
                Object o = req.getAttribute(name);
                if (o == null) continue;
                out.println(" " + name + ": type=" + o.getClass().getName() + " str='" + o.toString() + "'");
            }
            out.println("</pre>");
        }
        out.println("</body></html>");
    }

    private void print (PrintWriter out, String name, String value)
    {
        out.print(" " + name + ": ");
        out.println(value == null ? "&lt;none&gt;" : value);
    }

    private void print (PrintWriter out, String name, int value)
    {
        out.print(" " + name + ": ");
        if (value == -1)
            out.println("&lt;none&gt;");
        else
            out.println(value);
    }
}