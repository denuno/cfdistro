<cfcomponent displayname="DistroService" output="false">

	<cfset variables.distros = structNew()>

	<cffunction name="init" access="public" output="false" returntype="any">
	<cfargument name="departmentService" type="any" required="true" />
	<cfargument name="buildService" type="any" required="true" />

		<cfscript>
		var distro = "";
		var deptService = arguments.departmentService;
		var buildService = arguments.buildService;
		variables.persistPath = getdirectoryFromPath(getMetadata(this).path) & "/../";

		setDepartmentService(arguments.departmentService);

		// since services are cached distro data we'll be persisted
		// ideally, this would be saved elsewhere, e.g. database

		// FIRST
		distro = new();
		distro.setId("1");
		distro.setDistroName("cfdistro");
		distro.setBuildDirectory(expandpath("/cfdistro/") & "/../../build");
		distro.setFirstName("Curly");
		distro.setLastName("Stooge");
		distro.setEmail("curly@stooges.com");
		distro.setDepartmentId("1");
		distro.setDepartment(deptService.get("1"));

		variables.distros[distro.getId()] = distro;

		distro = new();
		distro.setId("2");
		distro.setDistroName("denstar");
		distro.setBuildDirectory(expandpath("/cfdistro/") & "/../../../denstar/build");
		distro.setFirstName("Curly");
		distro.setLastName("Stooge");
		distro.setEmail("curly@stooges.com");
		distro.setDepartmentId("1");
		distro.setDepartment(deptService.get("1"));

		variables.distros[distro.getId()] = distro;

		variables.nextid = 3;

		</cfscript>

		<cfreturn this>
	</cffunction>

	<cffunction name="setDepartmentService" access="public" output="false">
		<cfargument name="departmentService" type="any" required="true" />
		<cfset variables.departmentService = arguments.departmentService />
	</cffunction>
	<cffunction name="getDepartmentService" access="public" returntype="any" output="false">
		<cfreturn variables.departmentService />
	</cffunction>

	<cffunction name="delete" access="public" output="false" returntype="boolean">
		<cfargument name="id" type="string" required="true">

		<cfreturn structDelete(variables.distros, arguments.id)>
	</cffunction>

	<cffunction name="get" access="public" output="false" returntype="any">
		<cfargument name="id" type="string" required="false" default="">

		<cfset var result = "">

		<cfif len(id) AND structKeyExists(variables.distros, id)>
			<cfset result = variables.distros[id]>
		<cfelse>
			<cfset result = new()>
		</cfif>

		<cfreturn result>
	</cffunction>

	<cffunction name="list" access="public" output="false" returntype="struct">
		<cfreturn variables.distros>
    </cffunction>

	<cffunction name="persist" access="public" output="false" returntype="struct">
		<cffile action="write" file="#variables.persistpath#/distros.ser" output="#serialize(variables.distros)#" addnewline="false" />
		<cfreturn variables.distros>
    </cffunction>

	<cffunction name="loadpersisted" access="public" output="false" returntype="struct">
		<cfset var serfile = "">
		<cffile action="read" file="#variables.persistpath#/distros.ser" variable="serfile" />
		<cfset variables.distros  = evaluate(serfile) />
		<cfreturn variables.distros>
    </cffunction>

	<cffunction name="new" access="public" output="false" returntype="any">
		<cfreturn createObject("component", "distroManagerAJAX.models.Distro").init()>
	</cffunction>

	<cffunction name="save" access="public" output="false" returntype="void">
		<cfargument name="distro" type="any" required="true">

		<cfset var newId = 0>

		<!--- since we have an id we are updating a distro --->
		<cfif len(arguments.distro.getId())>
			<cfset variables.distros[arguments.distro.getId()] = arguments.distro>
		<cfelse>
			<!--- otherwise a new distro is being saved --->
			<!--- BEN --->
			<cflock type="exclusive" name="setNextID" timeout="10" throwontimeout="false">
				<cfset newId = variables.nextid>
				<cfset variables.nextid = variables.nextid + 1>
			</cflock>
			<!--- END BEN --->

			<cfset arguments.distro.setId(newId)>

			<cfset variables.distros[newId] = arguments.distro>
		</cfif>
	</cffunction>

</cfcomponent>