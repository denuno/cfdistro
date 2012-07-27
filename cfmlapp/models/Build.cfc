<cfcomponent displayname="Distro" output="false">

     <cfset variables.id = "" />
     <cfset variables.distroId = "" />
     <cfset variables.buildFile = "" />

     <cffunction name="init" access="public" output="false" returntype="Build">
          <cfargument name="buildFile" />
          <cfset variables.buildFile = arguments.buildFile />
          <cfreturn this />
     </cffunction>

     <cffunction name="getTargets" output="false">
          <cf_antrunner antfile="#variables.buildFile#" action="getTargets" resultsVar="buildResults">
		<cfreturn buildResults />
     </cffunction>

     <cffunction name="onMissingMethod" output="false">
          <cfargument name="missingMethodName" type="string" />
          <cfargument name="missingMethodArguments" type="struct" />
          <cfset var property = "" />
          <cfset var value = "" />
          <cfif findNoCase("get",arguments.missingMethodName) is 1>
               <cfset property = replaceNoCase(arguments.missingMethodName,"get","") />
               <cfreturn variables[property] />
          <cfelseif findNoCase("set",arguments.missingMethodName) is 1>
               <cfset property = replaceNoCase(arguments.missingMethodName,"set","") />
               <!--- assume only arg is value --->
               <cfset value = arguments.missingMethodArguments[listFirst(structKeyList(arguments.missingMethodArguments))] />
               <cfset variables[property] = value />
          <cfelse>
               <cfthrow type="#getMetadata(this).name#.no.method" message="there is no method by this name: #missingMethodName#" />
          </cfif>
     </cffunction>

</cfcomponent>
