package runwar;

import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;
import java.util.Map;
import org.eclipse.jetty.server.handler.ContextHandlerCollection;
import org.eclipse.jetty.util.resource.Resource;
import org.eclipse.jetty.webapp.WebAppContext;

public class ExternalContext extends WebAppContext {
	private Map<String,Object> attributes;
	private Map<String, String> parameters;
	private int majorVersion;
	private int minorVersion;
	private File root;
	private File webInf;
	
	public ExternalContext(ContextHandlerCollection contexts, String war, String contextPath, File root, File webInf) {
		super(contexts, war, contextPath);
		this.root=root;
		this.webInf=webInf;
	}
	
	public Resource getResource(String contextPath) {
		try {
			 //System.out.println("requested:"+contextPath);
			 if(contextPath.equals("/WEB-INF")) {
				 //System.out.println(webInf.getPath());
				return Resource.newResource(webInf); 
			 }
			//System.out.println("nada:"+ contextPath);

			return super.getResource(contextPath);
		} catch (MalformedURLException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}
}
