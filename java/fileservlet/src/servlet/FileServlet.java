package servlet;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.Closeable;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.net.URLDecoder;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * The File servlet for serving from absolute path.
 * @author BalusC
 * @link http://balusc.blogspot.com/2007/07/fileservlet.html
 */
public class FileServlet extends HttpServlet {

    // Constants ----------------------------------------------------------------------------------

    private static final int DEFAULT_BUFFER_SIZE = 10240; // 10KB.

    // Properties ---------------------------------------------------------------------------------

    private String filePath;
    private String defaultFileNames;

    // Actions ------------------------------------------------------------------------------------

    public void init() throws ServletException {

        // Define base path somehow. You can define it as init-param of the servlet.
        this.filePath = getServletConfig().getInitParameter("filePath");
		this.defaultFileNames = getServletConfig().getInitParameter("defaultFileNames");
		if(this.defaultFileNames == null) {
			this.defaultFileNames = "index.cfm";
		}

        // In a Windows environment with the Applicationserver running on the
        // c: volume, the above path is exactly the same as "c:\files".
        // In UNIX, it is just straightforward "/files".
        // If you have stored files in the WebContent of a WAR, for example in the
        // "/WEB-INF/files" folder, then you can retrieve the absolute path by:
        // this.filePath = getServletContext().getRealPath("/WEB-INF/files");
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException
    {
        // Get requested file by path info.
        String requestedFile = request.getPathInfo();

        // Check if file is actually supplied to the request URI.
        if (requestedFile == null) {
            // Do your thing if the file is not supplied to the request URI.
            // Throw an exception, or send 404, or show default/warning page, or just ignore it.
            response.sendError(HttpServletResponse.SC_NOT_FOUND); // 404.
            return;
        }

        // Decode the file name (might contain spaces and on) and prepare file object.
        File file = new File(filePath, URLDecoder.decode(requestedFile, "UTF-8"));

        // Check if file actually exists in filesystem.
        if (!file.exists()) {
            // Do your thing if the file appears to be non-existing.
            // Throw an exception, or send 404, or show default/warning page, or just ignore it.
            response.sendError(HttpServletResponse.SC_NOT_FOUND); // 404.
            return;
        }
        if(requestedFile.endsWith(".cfm") || requestedFile.endsWith(".cfc")) {
        	// we will avoid sending inprocessed CFML to the client
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
			//request.getRequestDispatcher("*.cfm").include(request, response);
			//request.getRequestDispatcher(request.getServletPath() + requestedFile).forward(request, response);
        	return;
        }
		if (file.isDirectory() && !requestedFile.endsWith("/")) {
			//System.out.println("redir");
			HttpServletResponse resp = (HttpServletResponse) response;
			HttpServletRequest req = (HttpServletRequest) request;
			response.sendRedirect(req.getContextPath() + requestedFile + "/");					
		}
		else if (file.isDirectory()) {
			File defaultFile = getDefaultFile(file.getPath());
			System.out.println("getDefault:"+defaultFile.getPath());
			if(defaultFile.exists()) {
				//response.sendRedirect(defaultFile.getPath().replace(this.filePath,""));					
				request.getRequestDispatcher(defaultFile.getPath().replace(this.filePath,"")).forward(request, response);						
			} else {
	            response.sendError(HttpServletResponse.SC_NOT_FOUND); // 404.
			}
		} 

		// Get content type by filename.
        String contentType = getServletContext().getMimeType(file.getName());

        // If content type is unknown, then set the default value.
        // For all content types, see: http://www.w3schools.com/media/media_mimeref.asp
        // To add new content types, add new mime-mapping entry in web.xml.
        if (contentType == null) {
            contentType = "application/octet-stream";
        }

        // Init servlet response.
        response.reset();
        response.setBufferSize(DEFAULT_BUFFER_SIZE);
        response.setContentType(contentType);
        response.setHeader("Content-Length", String.valueOf(file.length()));
        //response.setHeader("Content-Disposition", "attachment; filename=\"" + file.getName() + "\"");

        // Prepare streams.
        BufferedInputStream input = null;
        BufferedOutputStream output = null;

        try {
            // Open streams.
            input = new BufferedInputStream(new FileInputStream(file), DEFAULT_BUFFER_SIZE);
            output = new BufferedOutputStream(response.getOutputStream(), DEFAULT_BUFFER_SIZE);

            // Write file contents to response.
            byte[] buffer = new byte[DEFAULT_BUFFER_SIZE];
            int length;
            while ((length = input.read(buffer)) > 0) {
                output.write(buffer, 0, length);
            }
        } finally {
            // Gently close streams.
            close(output);
            close(input);
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
    
    
    // Helpers (can be refactored to public utility class) ----------------------------------------

    private static void close(Closeable resource) {
        if (resource != null) {
            try {
                resource.close();
            } catch (IOException e) {
                // Do your thing with the exception. Print it, log it or mail it.
                e.printStackTrace();
            }
        }
    }

}