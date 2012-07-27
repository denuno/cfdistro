import java.lang.reflect.*;
import java.io.*;
import java.net.*;
 
public class ClassPathHacker{
	private static final Class[] parameters = new Class[]{URL.class};
	 
	public static void addFile(String s) {
		File f = new File(s);
		addFile(f);
	}
	
	/* File.toURL() was deprecated, so use File.toURI().toURL() */
	public static void addFile(File f) {
		try {
			addURL(f.toURI().toURL());
		}
		catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	public static void addURL(URL u) {	
		URLClassLoader sysloader = (URLClassLoader)ClassLoader.getSystemClassLoader();
		try {
			/* Class was uncheched, so used URLClassLoader.class instead */
			Method method = URLClassLoader.class.getDeclaredMethod("addURL",parameters);
			method.setAccessible(true);
			method.invoke(sysloader,new Object[]{u});
			System.out.println("Dynamically added " + u.toString() + " to classLoader");
		} 
		catch (Exception e) {
			e.printStackTrace();
		}
	}
}
