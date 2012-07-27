<cfcomponent displayname="BuildService" output="false">

     <cfset variables.builds = structNew() />

     <cffunction name="init" access="public" output="false" returntype="any">
          <cfscript>
               var dept = "";

               // since services are cached build data we'll be persisted
               // ideally, this would be saved elsewhere, e.g. database

               // FIRST
               build = new();
               build.setId("1");
               build.setName("Accounting");

               variables.builds[build.getId()] = build;

               // SECOND
               build = new();
               build.setId("2");
               build.setName("Sales");

               variables.builds[build.getId()] = build;

               // THIRD
               build = new();
               build.setId("3");
               build.setName("Support");

               variables.builds[build.getId()] = build;

               // FOURTH
               build = new();
               build.setId("4");
               build.setName("Development");

               variables.builds[build.getId()] = build;
          </cfscript>
          <cfreturn this />
     </cffunction>

     <cffunction name="get" access="public" output="false" returntype="any">
          <cfargument name="id" type="string" required="true" />
          <cfset var result = "" />
          <cfif len(id) AND structKeyExists(variables.builds, id)>
               <cfset result = variables.builds[id] />
          <cfelse>
               <cfset result = new() />
          </cfif>
          <cfreturn result />
     </cffunction>

     <cffunction name="list" access="public" output="false" returntype="struct">
          <cfreturn variables.builds />
     </cffunction>

     <cffunction name="new" access="public" output="false" returntype="any">
          <cfreturn createObject("component", "distroManagerAJAX.models.Build").init() />
     </cffunction>

</cfcomponent>
