<cfcomponent hint="cfdocfonts" extends="railo-context.admin.plugin.Plugin">
	
	<cffunction name="init" hint="this function will be called to initalize">
		<cfargument name="lang" type="struct">
		<cfargument name="app" type="struct">
		<cfset var rootdir = getPageContext().getConfig().getRootDirectory() />
		<cfset var system = createObject("java","java.lang.System") />
		<cfset var classpath = system.getProperty("java.class.path").toString() />
		<cfset var delim = system.getProperty("path.separator") />
		<cfset var fontsNdx = 0 />
		<cfset var fontsloc = "" />
		<cfset variables.fontsjar = "" />
		<cfif findNoCase("fonts.jar",classpath)>
			<cfset fontNdx = listContainsNoCase(classpath,"fonts.jar",delim) />
			<cfset variables.fontsjar = listGetAt(classpath,fontNdx,delim) />
		<cfelse>
			<cfdirectory name="fontsloc" action="list" recurse="true" filter="fonts.jar" directory="#rootdir#" />
			<cfif fontsloc.recordcount gt 0>
				<cfset variables.fontsjar = fontsloc.directory & "/" & fontsloc.name />
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="setFontsJarLoc" output="yes" hint="set the location of the fonts.jar file">
		<cfargument name="lang" type="struct">
		<cfargument name="app" type="struct">
		<cfargument name="req" type="struct">
		<cfif fileExists(arguments.req.fontsjar)>
			<cfset variables.fontsjar = arguments.req.fontsjar />
		<cfelse>
			<h2>Sorry, but the file:</h2>
			<strong>#arguments.req.fontsjar#</strong>
			<h3>Could not be found</h3>
		  <a href="#action('overview')#?setfontsjar=1">Return to font list</a>
		</cfif>
	</cffunction>

	<cffunction name="overview" output="yes" hint="list all font files, with add and delete">
		<cfargument name="lang" type="struct">
		<cfargument name="app" type="struct">
		<cfargument name="req" type="struct">
		<cfset arguments.req.fontsjar = variables.fontsjar />
		<cftry>
			<cfset arguments.req.installedfonts = getInstalledFonts() />
		<cfcatch>
			<cfset arguments.req.installedfonts = arrayNew(1) />
		</cfcatch>
		</cftry>
		<!--- <cfoutput><cfinclude template="overview.cfm"/></cfoutput> --->
	</cffunction>

	<cffunction name="getInstalledFonts" output="false" returntype="array" hint="returns an array of the installed fonts">
		<cfset var aRet = ArrayNew(1)>
		<cfset var getLogs = "">
		<cfset var escaper = createObject("java","org.apache.commons.lang.StringEscapeUtils")>
		<cfif NOT fileExists(variables.fontsjar)>
			<cfthrow type="not.there.man" message="jar file not found: #arguments.req.fontsjar#" detail="jar file not found: #arguments.req.fontsjar#">
		</cfif>
		<cfloop file="zip://#variables.fontsjar#!/fonts/pd4fonts.properties" index="fontInfoLine">
			<cfif left(fontInfoLine,1) != "##" && fontInfoLine != "">
				<cfset arrayAppend(aRet,{fontname:listFirst(escaper.unescapeJava(fontInfoLine),"="),fontfile:listLast(fontInfoLine,"=")}) />
			</cfif>
		</cfloop>
		<cfreturn aRet />
	</cffunction>	
	
	<cffunction name="_addTTFFont" output="false" hint="adds a font">
		<cfargument name="fontPath" required="true" />
		<cfargument name="fontName" required="true" />
		<cfset var ttfname = listLast(fontPath,"/\") />
		<cfif arguments.fontName eq "">
			<cfset arguments.fontName = listFirst(ttfname,".") />			
		</cfif>
		<cfset arguments.fontName = listFirst(arguments.fontName,".") />
		<cfif NOT fileExists(fontPath)>
			<cfthrow type="buggered.esse.fontfile.notfound" message="the specified font file couldn't be found: #fontPath#" />
		</cfif>
		<cffile action="read" file="zip://#variables.fontsjar#!/fonts/pd4fonts.properties" variable="fontprops" />
		<cfif NOT findNoCase(ttfname,fontprops)>
			<cfset escaper = createObject("java","org.apache.commons.lang.StringEscapeUtils")>
			<cfset newfontTxt = escaper.escapeJava(fontName & "=" & ttfname) />
			<cffile action="append" file="zip://#variables.fontsjar#!/fonts/pd4fonts.properties" output="#newfontTxt#" addnewline="true" />
			<cffile action="copy" destination="zip://#variables.fontsjar#!/fonts/" source="#fontPath#" />
		<cfelse>
			<cfthrow type="buggered.esse.fontalreadyin" message="the specified font was already found in the properties file.  Have you restarted the server? ttf: #ttfname#">
		</cfif>
	</cffunction>
	
	<cffunction name="_removeTTFFont" output="false" hint="removes a font">
		<cfargument name="fontFile" required="true" />
		<cffile action="read" file="zip://#variables.fontsjar#!/fonts/pd4fonts.properties" variable="fontprops" />
		<cfif findNoCase(fontfile,fontprops)>
			<cfset delLine = listContainsNoCase(fontprops,fontFile,chr(13)&chr(10))>
			<cfset fontprops = listDeleteAt(fontprops,delLine,chr(13)&chr(10)) />
			<cffile action="write" file="zip://#variables.fontsjar#!/fonts/pd4fonts.properties" output="#fontprops#" />
			<cffile action="delete" file="zip://#variables.fontsjar#!/fonts/#fontFile#" />
		<cfelse>
			<cfthrow type="buggered.esse.font.notthere" message="the specified font was not found in the properties file.  Have you restarted the server? ttf: #fontfile#">
		</cfif>
	</cffunction>

	<cffunction name="addTTFFont" output="true" hint="wrapper for core addFont function">
		<cfargument name="lang" type="struct">
		<cfargument name="app" type="struct">
		<cfargument name="req" type="struct">
		<cftry>
			<cffile action="upload" accept="application/octet-stream" filefield="fontfile" nameconflict="overwrite" destination="#getTempDirectory()#" />
			<cfset _addTTFFont(getTempDirectory() & cffile.ServerFile,form.fontname) />
			<cflocation url="#action('overview')#" addtoken="false" />
		<cfcatch>
		  <h3 style="color:red">Error</h3>
		  #cfcatch.Message#<br/>
		  &nbsp; &nbsp; #cfcatch.Detail#<br />
		  <a href="#action('overview')#">Return to font list</a>
		</cfcatch>
		</cftry>		
	</cffunction>

	<cffunction name="removeTTFFont" output="yes" hint="wrapper for core removeFont function">
		<cfargument name="lang" type="struct">
		<cfargument name="app" type="struct">
		<cfargument name="req" type="struct">
		<cfset var fontfile = "" />
		<cftry>
			<cfloop list="#form.fontfiles#" index="fontfile">
				<cfset _removeTTFFont(fontfile) />
			</cfloop>
			<cflocation url="#action('overview')#" addtoken="false" />
		<cfcatch>
		  <h3 style="color:red">Error</h3>
		  #cfcatch.Message#<br/>
		  &nbsp; &nbsp; #cfcatch.Detail#<br />
		  <a href="#action('overview')#">Return to font list</a>
		</cfcatch>
		</cftry>		
	</cffunction>

	<cffunction name="testFont" output="yes" hint="little test of font">
		<cfargument name="lang" type="struct" />
		<cfargument name="app" type="struct" />
		<cfargument name="req" type="struct" />
		<cfset var docsource = "" />
		<cfloop array="#getInstalledFonts()#" index="font">
			<cfif font.fontfile eq arguments.req.fontfile>
				<cfsavecontent variable="docsource">
					<style>
						.testFont { font-family: '#font.fontname#' }
					</style>
					
					<h1 class="testFont">Test of #font.fontfile#</h1>
					
					<h2 class="testFont">style="font-family:'#font.fontname#';"</h2>
					
					<p class="testFont">
						This is a little paragraph of text to see why
						the quick brown fox asked what it's country could 
						do for great although lazy men
					</p>
					
				</cfsavecontent>
			  <cfset cvalue = "attachment;filename=testfont-#listFirst(font.fontfile,'.')#.pdf">
				<cfheader name="Content-Disposition" value="#cvalue#" charset="utf-8" />
				<cfdocument format="pdf" fontembed="true">
					#docsource#
					<h3>CFDocument Source</h3>
#htmlCodeFormat(xmlFormat(docsource))#
				</cfdocument>
			</cfif>
		</cfloop>
	</cffunction>

</cfcomponent>