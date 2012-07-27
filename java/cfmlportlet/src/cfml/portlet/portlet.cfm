<cfsetting enablecfoutputonly="true" />
<!---
<cfdump var="#request#">
 --->
<cfif NOT structKeyExists(url,"cfcName") OR url.cfcName EQ "">
  <cfthrow message="no cfc name defined"
  	detail="you must set the cfcName init-param in portlet.xml to the dot-notation path of your portlet cfc" />
</cfif>
<cfset portlet = createObject(url.cfcName) />
<cfset mode = request.PORTLET.mode />
<cfif mode eq "VIEW">
	<cfoutput>#portlet.doView(request.PORTLET.request, request.PORTLET.response)#</cfoutput>
<cfelseif mode eq "ACTION">
	<cfset portlet.processAction(request.PORTLET.request, request.PORTLET.response) />
<cfelseif mode eq "HELP">
	<cfoutput>#portlet.doHelp(request.PORTLET.request, request.PORTLET.response)#</cfoutput>
<cfelseif mode eq "EDIT">
	<cfoutput>#portlet.doEdit(request.PORTLET.request, request.PORTLET.response)#</cfoutput>
</cfif>