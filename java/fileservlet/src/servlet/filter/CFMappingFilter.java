// ========================================================================
// Copyright 199-2004 Mort Bay Consulting Pty. Ltd.
// ------------------------------------------------------------------------
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at 
// http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ========================================================================

package servlet.filter;

import java.io.IOException;
import java.io.File;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletRequest;

/* ------------------------------------------------------------ */
public class CFMappingFilter implements Filter {
	private String cfsrc, defaultFileNames;
	private String fileSeparator = System.getProperty("file.separator");

	public void init(FilterConfig filterConfig) {
		cfsrc = filterConfig.getInitParameter("cfsrc").replaceAll("/",fileSeparator);
		defaultFileNames = filterConfig.getInitParameter("defaultFileNames");
	}

	/* ------------------------------------------------------------ */
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException,
			ServletException {
		String[] requestedPath = ((HttpServletRequest) request).getServletPath().split("/?");
		String contextPath = ((HttpServletRequest) request).getContextPath();
		String path, query;
		if(requestedPath.length > 1) {
			path = requestedPath[0];
			query = requestedPath[1];
		} else {
			path = requestedPath[0];
			query = "";
		}
		if (cfsrc != null) {
			File requestedFile = new File(cfsrc + path);
			System.out.println("initwith:"+requestedFile.getPath());
			if (requestedFile.exists()) {
				System.out.println("exists");
				if (requestedFile.isDirectory() && !path.endsWith("/")) {
					//System.out.println("redir");
					HttpServletResponse resp = (HttpServletResponse) response;
					HttpServletRequest req = (HttpServletRequest) request;
					resp.sendRedirect(req.getContextPath() + path + "/");					
				}
				else if (requestedFile.isDirectory()) {
					File defaultFile = getDefaultFile(requestedFile.getPath());
					//System.out.println("getDefault:"+defaultFile.getPath());
					if(defaultFile.exists()) {
						request.getRequestDispatcher(defaultFile.getPath().replace(cfsrc,"")).forward(request, response);						
					} else {
						chain.doFilter(request, response);						
					}
				} 
				else {
					//System.out.println("go for:" + contextPath + requestedFile.getPath().replace(cfsrc,"").replace(fileSeparator,"/"));
					System.out.println(requestedFile.getPath());					
					request.getRequestDispatcher(requestedFile.getPath()).forward(request, response);					
				}
			} else {
				chain.doFilter(request, response);
			}
		}
	}

	private File getDefaultFile(String directory) {
		String[] files = defaultFileNames.split(" ");
		for (int i = 0; i < files.length; i++) {
			File defaultFile = new File(directory + File.separator + files[i]);
			System.out.println("looking..."+defaultFile.getPath());
			if (defaultFile.exists()) {
				return defaultFile;
			}
		}
		return new File("");
	}

	public void destroy() {
	}
}