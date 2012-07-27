package cfml.portlet;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.EventRequest;
import javax.portlet.EventResponse;
import javax.portlet.GenericPortlet;
import javax.portlet.PortletContext;
import javax.portlet.PortletException;
import javax.portlet.PortletMode;
import javax.portlet.PortletRequest;
import javax.portlet.PortletRequestDispatcher;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;
import javax.portlet.WindowState;

import org.apache.commons.io.FileUtils;

public class CFMLPortlet extends GenericPortlet {

	private static final long serialVersionUID = 1L;
	public static final String CFC_PATH_PARAM = "wee";
	public static final String PORTLET_CFM = "/WEB-INF/cfml/portlet.cfm";
	private String cfmlCall;

	@Override
	public void init() throws PortletException {
		cfmlCall = PORTLET_CFM + "?cfcName=" + getPortletConfig().getInitParameter("cfcName");
		exportJarResource("cfml/portlet/Portlet.cfc", "/WEB-INF/cfml/Portlet.cfc");
		exportJarResource("cfml/portlet/portlet.cfm", "/WEB-INF/cfml/portlet.cfm");
		exportJarResource("cfml/portlet/DemoPortlet.cfc", "/WEB-INF/cfml/DemoPortlet.cfc");
	}

	private void exportJarResource(String source, String dest) {
		URL resource = CFMLPortlet.class.getClassLoader().getResource(source);
		File destFile = new File(getPortletContext().getRealPath(dest));
		try {
			File tmpFile = File.createTempFile("portlet", ".tmp");
			tmpFile.deleteOnExit();
			FileUtils.copyURLToFile(resource, tmpFile);
			if(!FileUtils.contentEquals(tmpFile, destFile)) {
				FileUtils.copyFile(tmpFile, destFile);
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void doView(RenderRequest request, RenderResponse response) throws PortletException, IOException {
		String mode = null;
		if (request.getPortletMode() == PortletMode.VIEW) {
			mode = "VIEW";
		} else if (request.getPortletMode() == PortletMode.EDIT) {
			mode = "EDIT";
		} else if (request.getPortletMode() == PortletMode.HELP) {
			mode = "HELP";
		}

		String windowState = getWindowStateAsString(request);

		Map portletScope = new HashMap();
		portletScope.put("MODE", mode);
		portletScope.put("WINDOW", windowState);
		portletScope.put("REQUEST", request);
		portletScope.put("RESPONSE", response);
		portletScope.put("CONFIG", getPortletConfig());
		portletScope.put("ATTRIBUTES", createAttributeMap(request));
		portletScope.put("PARAMETERS", createParameterMap(request));
		portletScope.put("PROPERTIES", createPropertyMap(request));
		request.setAttribute("PORTLET", portletScope);
		response.setContentType("text/html; charset=utf-8");
		PortletContext context = getPortletContext();
		PortletRequestDispatcher rd = context.getRequestDispatcher(cfmlCall);
		rd.include(request, response);
	}

	private String getWindowStateAsString(RenderRequest request) {
		String windowState = null;
		WindowState ws = request.getWindowState();
		if (ws == WindowState.NORMAL) {
			windowState = "NORMAL";
		} else if (ws == WindowState.MAXIMIZED) {
			windowState = "MAXIMIZED";
		} else if (ws == WindowState.MINIMIZED) {
			windowState = "MINIMIZED";
		} else { // allow for custom states
			windowState = ws.toString();
		}
		return windowState;
	}

	public void processAction(ActionRequest request, ActionResponse response) throws PortletException {
		try {
			Map portletScope = new HashMap();
			portletScope.put("MODE", "ACTION");
			portletScope.put("REQUEST", request);
			portletScope.put("RESPONSE", response);
			portletScope.put("CONFIG", getPortletConfig());
			portletScope.put("ATTRIBUTES", createAttributeMap(request));
			portletScope.put("PARAMETERS", createParameterMap(request));
			portletScope.put("PROPERTIES", createPropertyMap(request));
			request.setAttribute("PORTLET", portletScope);

			PortletRequestDispatcher rd = getPortletContext().getRequestDispatcher(cfmlCall);
			rd.include(request, response);
		} catch (Exception e) {
			e.printStackTrace();
			throw new PortletException(e);
		}
	}

	public void processEvent(EventRequest request, EventResponse response) throws PortletException {
		try {
			Map portletScope = new HashMap();
			portletScope.put("MODE", "EVENT");
			portletScope.put("REQUEST", request);
			portletScope.put("RESPONSE", response);
			portletScope.put("CONFIG", getPortletConfig());
			portletScope.put("ATTRIBUTES", createAttributeMap(request));
			portletScope.put("PARAMETERS", createParameterMap(request));
			portletScope.put("PROPERTIES", createPropertyMap(request));
			request.setAttribute("PORTLET", portletScope);

			PortletRequestDispatcher rd = getPortletContext().getRequestDispatcher(cfmlCall);
			rd.include(request, response);
		} catch (Exception e) {
			e.printStackTrace();
			throw new PortletException(e);
		}
	}

	// @Override
	// public String getTitle(RenderRequest request) {
	// String title = getPortletConfig().getInitParameter("title");
	// if (title == null) {
	// title = "CF Portlet";
	// }
	// return title;
	//
	// }

	private Map createParameterMap(PortletRequest request) {
		Map map = new HashMap();
		Enumeration names = request.getParameterNames();
		while (names.hasMoreElements()) {
			String name = (String) names.nextElement();
			map.put(name.toUpperCase(), request.getParameter(name));
		}
		return map;
	}

	private Map createAttributeMap(PortletRequest request) {
		Map map = new HashMap();
		Enumeration names = request.getAttributeNames();
		while (names.hasMoreElements()) {
			String name = (String) names.nextElement();
			map.put(name.toUpperCase(), request.getAttribute(name));
		}
		return map;
	}

	private Map createPropertyMap(PortletRequest request) {
		Map map = new HashMap();
		Enumeration names = request.getPropertyNames();
		while (names.hasMoreElements()) {
			String name = (String) names.nextElement();
			map.put(name.toUpperCase(), request.getProperty(name));
		}
		return map;
	}

}
