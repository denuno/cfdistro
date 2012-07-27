<cffunction name="expandPath" output="false">
	<cfargument name="filename" type="any" required="true">
	<cfargument name="__name" type="any" required="false">
	<cfargument name="__isweb" type="any" required="false">
	<cftry>
		<cfset SuperLength=createObject('java','railo.runtime.functions.system.ExpandPath') />
		<cfreturn SuperLength.call(getPageContext(),arguments.filename) />
		<cfcatch>
		<cfif filename eq "./">
			<cfset rapath = getPageContext().getCurrentTemplatePageSource().getDisplayPath() />
			<cfreturn listDeleteAt(rapath,listLen(rapath,"/"),"/") />
	    <cfdump var="#getPageContext().getBasePageSource().getMapping()#">
		</cfif>
    <cfdump var="#arguments#">
    <cfdump var="#getPageContext()#">
    <cfdump var="#getPageContext().getBasePageSource()#">
    <cfdump var="#getPageContext().getBasePageSource().getMapping()#">
    <cfdump var="#getPageContext().getCurrentTemplatePageSource().getDisplayPath()#">
    <cfdump var="#getPageContext().getTemplatePath()#">
    <cfdump var="#getPageContext().getRootTemplateDirectory()#">
    <cfdump var="#getPageContext().getPageSourceList()#">
    <cfdump var="#getPageContext().getPage()#">
    <cfdump var="#getPageContext().getActiveComponent()#">
		getTemplatePath
    <cfdump var="#variables#">
		<cfabort/>
		</cfcatch>
	</cftry>
</cffunction>