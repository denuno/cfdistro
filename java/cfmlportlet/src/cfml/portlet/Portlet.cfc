<cfcomponent>
	<cfscript>
	function doView(renderRequest,renderResponse) {
	}

	function doHelp(renderRequest,renderResponse) {
	}

	function doEdit(renderRequest,renderResponse) {
	}

	function processAction(actionRequest,actionResponse) {
	}

	function getParameter(required paramName) {
		var paramPos = listFindNoCase(structKeyList(request.PORTLET.parameters),paramName);
		if(paramPos neq 0) {
			paramName = listGetAt(structKeyList(request.PORTLET.parameters),paramPos);
			return request.PORTLET.parameters[paramName];
		}
		return "";
	}

	function setPortletMode(mode) {
		var PortletMode = createObject("java","javax.portlet.PortletMode");
		var res = request.PORTLET.response;
		if(isPortletModeAllowed(mode)) {
			switch(ucase(mode)) {
				case "EDIT":
					res.setPortletMode(PortletMode.EDIT);
					break;
				case "HELP":
					res.setPortletMode(PortletMode.HELP);
					break;
				case "VIEW":
					res.setPortletMode(PortletMode.VIEW);
					break;
				default:
					res.setPortletMode(PortletMode.VIEW);
			}
		} else {
			throw("portlet mode [#mode#] is not allowed in the current state");
		}
	}

	function isPortletModeAllowed(mode) {
		var PortletMode = createObject("java","javax.portlet.PortletMode");
		var req = request.PORTLET.request;
		switch(ucase(mode)) {
			case "EDIT":
				return req.isPortletModeAllowed(PortletMode.EDIT);
			case "HELP":
				return req.isPortletModeAllowed(PortletMode.HELP);
			case "VIEW":
				return req.isPortletModeAllowed(PortletMode.VIEW);
			default:
				throw("unknown mode [#mode#]");
		}
	}

	function setRenderParameter(name,value) {
		request.PORTLET.response.setRenderParameter(name,value);
	}

	function sendRedirect(required location,renderUrlParamName="") {
		if(renderUrlParamName != "") {
			request.PORTLET.response.sendRedirect(location,renderUrlParamName);
		} else {
			request.PORTLET.response.sendRedirect(location);
		}
	}

	function createRenderURL(params) {
		var renderURL = request.PORTLET.response.createRenderURL();
		var param = "";
		for(param in listToArray(structKeyList(params))) {
			renderURL.setParameter(param, params[param]);
		}
		return renderURL.toString();
	}

	function createActionURL(params) {
		var actionURL = request.PORTLET.response.createActionURL();
		var param = "";
		for(param in listToArray(structKeyList(params))) {
			actionURL.setParameter(param, params[param]);
		}
		return actionURL.toString();
	}

	function getPortletRequest() {
		return request.PORTLET.request;
	}
	</cfscript>
</cfcomponent>