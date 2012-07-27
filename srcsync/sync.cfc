<cfcomponent>

	<cfset variables.srcdir = "${src.dir}" />

	<cffunction name="onAdd" access="public" output="no" returntype="void">
    	<cfargument name="data" type="struct" required="yes">
		<cflog text="add:#serialize(data)#" type="information" file="DirectoryWatcher">
		<cfset onChange(data) />
	</cffunction>

	<cffunction name="onDelete" access="public" output="no" returntype="void">
    	<cfargument name="data" type="struct" required="yes">
		<cflog text="delete:#serialize(data)#" type="information" file="DirectoryWatcher">
		<cfset var thisDir = expandPath("/") />
        <cfset var srcfile = arguments.data.directory & "/" & arguments.data.name />
        <cfset var destFile = thisDir & replace(srcfile,variables.srcdir,"") />
		<cfset createObject("java","java.io.File").init(getDirectoryFromPath(destFile)).mkdirs() />
		<cffile action="delete" file="#destFile#" />
	</cffunction>

	<cffunction name="onChange" access="public" output="no" returntype="void">
    	<cfargument name="data" type="struct" required="yes">
		<cflog text="change:#serialize(data)#" type="information" file="DirectoryWatcher">
		<cfset var thisDir = expandPath("/") />
        <cfset var srcfile = arguments.data.directory & "/" & arguments.data.name />
        <cfset var destFile = thisDir & replace(srcfile,variables.srcdir,"") />
		<cfset createObject("java","java.io.File").init(getDirectoryFromPath(destFile)).mkdirs() />
		<cflog text="#thisDir# #srcfile# #destfile#" type="information" file="DirectoryWatcher">
		<cffile action="copy" source="#srcFile#" destination="#destFile#" />
	</cffunction>

</cfcomponent>