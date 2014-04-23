<cfcomponent name="cfantrunner">

    <cffunction name="init" output="no" hint="invoked after tag is constructed">
    	<cfargument name="hasEndTag" type="boolean" default="false">
      	<cfargument name="parent" type="component" required="no" hint="the parent cfc custom tag, if there is one">
		<cfscript>
			var libs = "";
		</cfscript>
		<cfreturn this />
  	</cffunction>

    <cffunction name="onStartTag" output="yes" returntype="boolean">
   		<cfargument name="attributes" type="struct">
   		<cfargument name="caller" type="struct">
   		<cfargument name="hasEndTag" type="boolean">
		<cfif not hasEndTag>
			<cfset onEndTag(attributes,caller,"") />
		</cfif>
	    <cfreturn hasEndTag>
	</cffunction>

    <cffunction name="onEndTag" output="yes" returntype="boolean">
   		<cfargument name="attributes" type="struct">
   		<cfargument name="caller" type="struct">
  		<cfargument name="generatedContent" type="string">
		<cfscript>
			structDelete(caller,"cfantrunner");
			structDelete(caller,attributes.resultsVar);
			attributes.generatedContent = generatedContent;
			var antresults = new Ant().run(argumentCollection=attributes);
			caller[attributes.resultsVar] = antresults;
		</cfscript>
		<cfreturn false/>
	</cffunction>

</cfcomponent>