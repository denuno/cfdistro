<cfsetting enablecfoutputonly="true"><cfsilent>
	<cfparam name="attributes.result"  default="cfantrunner">
	<cfif NOT structKeyExists(thistag,"tag")>
		<cfset thistag.tag = createObject("component","cfc.antrunner") />
		<cfset thistag.tag.init(THISTAG.HasEndTag) />
	</cfif>
	<cfset tag = thistag.tag />
</cfsilent>

    <cffunction name="onStartTag" output="yes" returntype="boolean">
   		<cfargument name="attributes" type="struct">
   		<cfargument name="caller" type="struct">
  		<cfargument name="generatedContent" type="string">
		<cfset tag.onStartTag(attributes,caller,THISTAG.HasEndTag) />
		<cfreturn false/>
	</cffunction>

    <cffunction name="onEndTag" output="yes" returntype="boolean">
   		<cfargument name="attributes" type="struct">
   		<cfargument name="caller" type="struct">
  		<cfargument name="generatedContent" type="string">
		<cfset tag.onEndTag(attributes,caller,THISTAG.GeneratedContent) />
		<cfreturn false/>
	</cffunction>

<cfsetting enablecfoutputonly="false">