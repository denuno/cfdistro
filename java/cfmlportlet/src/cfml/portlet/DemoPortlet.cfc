<cfcomponent extends="WEB-INF.cfml.Portlet">
	<cffunction name="doView" output="true">
		<cfset var curpage = val(getParameter("page")) />
		<cfset var nextpage = curpage + 1 />
		<cfset params = structNew() />
		<cfset params.page = nextpage />
		<cfdump var="#form#">
		<cfswitch expression="#curpage#">
			<cfdefaultcase>
				<h2>Page #curpage#</h2><a href="#createRenderURL(params)#">Link to page #nextpage#</a>
			</cfdefaultcase>
			<cfcase value="0">
				<h2>MAIN</h2>
				<a href="#createRenderURL(params)#">Link to page #nextpage#</a>
				<br /><h3>Form test:</h3>
				<form action="#createActionURL()#" method="post">
					Textfield: <input type="text" name="textfield" value=""><br />
					test redirect <input type="checkbox" name="redirect" value="1">
					<input type="submit">
				</form>
			</cfcase>
			<cfcase value="3">
				<cfset params.page = 0>
				<h2>Last page!</h2>
				<a href="#createRenderURL(params)#">Link to first page</a>
			</cfcase>
		</cfswitch>
		<h3>Parameters:</h3>
		<cfdump var="#request.PORTLET.parameters#">
	</cffunction>

	<cfscript>

	function doHelp(renderRequest,renderResponse) {
		writeOutput("HELP rocks!");
		writeOutput("Hello CFML Portlet!");
	}

	function doEdit(renderRequest,renderResponse) {
		writeOutput("EDIT rocks!");
		writeOutput("EDIT CFML Portlet!");
	}

	function processAction(actionRequest,actionResponse) {
		sys = createObject("java","java.lang.System");
		sys.out.println(request.PORTLET.mode & 'PROCESSING ACTION' & structKeyList(request.PORTLET.parameters));
		//setPortletMode("EDIT");
		if(getParameter("REDIRECT") NEQ "") {
			//sendRedirect(createRenderURL({page:3}),"urlParam");
			sendRedirect(createRenderURL({page:3}));
		} else {
			setRenderParameter("message","you submited: " & getParameter("textfield"));
			setRenderParameter("page",2);

		}
	}
	</cfscript>
</cfcomponent>