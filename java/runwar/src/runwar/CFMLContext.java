package runwar;

import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;

import org.eclipse.jetty.server.handler.ContextHandlerCollection;
import org.eclipse.jetty.util.resource.Resource;
import org.eclipse.jetty.webapp.WebAppContext;

public class CFMLContext extends WebAppContext {
	private Resource[] cfmlDirResource;
	private String[] cfmlDirs;

	/**
	 * Standard constructor; passed a path or URL for a war (or exploded war
	 * directory).
	 * 
	 * @param contexts
	 * 
	 * @param contextPath
	 */
	public CFMLContext(ContextHandlerCollection contexts, String war, String contextPath, String cfmlDirList) {
		super(contexts, war, contextPath);
		this.cfmlDirs = cfmlDirList.split(",");
		this.cfmlDirResource = new Resource[cfmlDirs.length];
		try {
			for(int x =0; x < cfmlDirs.length; x++){				
				cfmlDirResource[x] = Resource.newResource(cfmlDirs[x]);
				System.out.println("Serving content from " + cfmlDirResource[x].getFile().getAbsolutePath());
			}
		} catch (MalformedURLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	// public boolean isParentLoaderPriority() {
	// return true;
	// }

	// public Resource getWebInf() {
	// return _webInf;
	// }

	public Resource getResource(String contextPath) {
		try {
			 //System.out.println("requested:"+contextPath);
			 if(!contextPath.equals("/") && !contextPath.startsWith("/WEB-INF")) {
				for (int x = 0; x < cfmlDirs.length; x++) {
					File reqFile = cfmlDirResource[x].addPath(contextPath).getFile();
					//System.out.println(cfmlDirResource[x].addPath(contextPath).getFile().getPath());
					//System.out.println(cfmlDirs[x]);
					//System.out.println("requested ==" + reqFile.getAbsolutePath() + " exists:" + reqFile.exists());
					if (reqFile.exists()) {
						// System.out.println("returning:" + cfmlDir +
						// contextPath);
						//System.out.println("ret1:"+ cfmlDirResource[x].addPath(contextPath).getFile().getAbsolutePath());
						return cfmlDirResource[x].addPath(contextPath);
					} else {
						String absPath = cfmlDirResource[x].getFile().getCanonicalPath();
						reqFile = new File(cfmlDirResource[x].getFile() + contextPath.replace(absPath, ""));
						//System.out.println("DDD==" + reqFile.getAbsolutePath() + " exists:" + reqFile.exists());
						if (reqFile.exists()) {
							//System.out.println("ret2:"+ cfmlDirResource[x].addPath(contextPath).getFile().getAbsolutePath());
							return cfmlDirResource[x].addPath(contextPath);
						}
					}
				}
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
