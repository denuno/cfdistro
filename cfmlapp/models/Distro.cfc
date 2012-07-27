<cfcomponent displayname="Distro" output="false">

	<cfset variables.id = "" />
	<cfset variables.distroName = "" />
	<cfset variables.buildDirectory = "" />
	<cfset variables.srcDirectory = "" />
	<cfset variables.tempDirectory = "" />

	<cffunction name="init" access="public" output="false" returntype="Distro">
		<cfreturn this />
	</cffunction>

	<cffunction name="setBuildDirectory">
		<cfargument name="buildDirectory" required="true" />
		<cfif NOT buildDirectory.endsWith("/") AND NOT buildDirectory.endsWith("\")>
			<cfset buildDirectory = buildDirectory & "/" />
		</cfif>
		<cfif directoryexists(buildDirectory)>
			<cfset variables.buildDirectory = arguments.buildDirectory />
		<cfelseif directoryexists(expandpath(buildDirectory))>
			<cfset variables.buildDirectory = expandpath(arguments.buildDirectory) />
		<cfelse>
			<cfthrow type="cfdistro.build.directory.error" message="the directory #buildDirectory# does not exist!" detail="the directory #buildDirectory# does not exist!" />
		</cfif>
	</cffunction>

	<cffunction name="buildFileExists" returntype="boolean">
		<cfif fileExists(variables.buildDirectory & "build.xml")>
			<cfreturn true />
		</cfif>
		<cfreturn false />
	</cffunction>

	<cffunction name="makeCFDistroBuild" output="false">
		<cfset var properties = structNew() />
		<cfset properties["cfdistro.target.build.dir"] = variables.buildDirectory>
		<cfif variables.distroName eq "">
			<cfthrow type="cfdistro.noname" message="no name has been set for this distro." detail="no name has been set for this distro.  Please set a name before trying to build." />
		</cfif>
		<cf_antrunner antfile="#expandpath('/cfdistro/build.xml')#" target="copy.cfdistro.dist" properties="#properties#">
		<cfset makeDefaultBuildXML(distroName=variables.distroName) />
		<cfreturn cfantrunner />
	</cffunction>

	<cffunction name="build" output="false">
		<cfargument name="target" />
		<cfset var properties = structNew() />
		<cfset properties["cfdistro.target.build.dir"] = variables.buildDirectory>
		<cf_antrunner antfile="#variables.buildDirectory#build.xml" properties="#properties#" target="#arguments.target#">
		<cfreturn cfantrunner />
	</cffunction>

	<cffunction name="makeDefaultBuildXML" output="false">
		<cfargument name="distroName" default="#variables.distroName#" />
		<cfset var buildXML = "" />
		<cfif buildFileExists()>
			<cfreturn />
		</cfif>
		<cfsavecontent variable="buildXML">
			<cfoutput>
				<project name="#arguments.distroName#.build" default="build.localdev" basedir="./" xmlns:antcontrib="antlib:net.sf.antcontrib">
					<property name="distro.name" value="#arguments.distroName#" />
					<property name="default.cfengine" value="railo" />
					<property name="src.dir" location="../src" />
					<property name="dist.dir" location="./dist" />
					<property name="pub.dir" location="../pub" />
					<property name="docs.dir" location="../docs" />
					<property name="tests.dir" location="../tests" />
					<property name="conf.dir" location="../conf" />
					<property name="cfadmin.password" value="testtest" />
					<property name="temp.dir" location="./temp" />
					<property name="runwar.port" value="8080" />

					<import file="${basedir}/cfdistro/build.xml"/>

					<target name="build.localdev">
						<antcontrib:runtarget target="cfdistro.build.localdev" />
					</target>

					<target name="build.localdev.start.launch">
						<antcontrib:runtarget target="cfdistro.build.localdev.start.launch" />
					</target>

					<target name="build.localdev.start" depends="build.localdev">
						<antcontrib:runtarget target="runwar.start" />
					</target>
					<target name="build.localdev.stop">
						<antcontrib:runtarget target="runwar.stop" />
					</target>

					<target name="build.war.binary" depends="compile-cf">
						<antcall target="add-cfantrunner" />
						<antcall target="cfdistro.build.war.binary" />
					</target>
				</project>
			</cfoutput>
		</cfsavecontent>
		<cffile action="write" file="#variables.buildDirectory#/build.xml" output="#trim(buildXML)#">
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
