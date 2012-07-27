<cfcomponent displayname="Distro" output="false">

     <cfset variables.fw = "" />

     <cffunction name="init" access="public" output="false" returntype="any">
          <cfargument name="fw" />
          <cfset variables.fw = arguments.fw />
          <cfreturn this />
     </cffunction>

     <cffunction name="setDepartmentService" access="public" output="false">
          <cfargument name="departmentService" type="any" required="true" />
          <cfset variables.departmentService = arguments.departmentService />
     </cffunction>

     <cffunction name="getDepartmentService" access="public" returntype="any" output="false">
          <cfreturn variables.departmentService />
     </cffunction>

     <cffunction name="setDistroService" access="public" output="false" returntype="void">
          <cfargument name="distroService" type="any" required="true" />
          <cfset variables.distroService = arguments.distroService />
     </cffunction>

     <cffunction name="getDistroService" access="public" output="false" returntype="any">
          <cfreturn variables.distroService />
     </cffunction>

     <cffunction name="setBuildService" access="public" output="false" returntype="void">
          <cfargument name="buildService" type="any" required="true" />
          <cfset variables.buildService = arguments.buildService />
     </cffunction>

     <cffunction name="getBuildService" access="public" output="false" returntype="any">
          <cfreturn variables.buildService />
     </cffunction>

     <cffunction name="default" access="public" output="false" returntype="void">
          <cfargument name="rc" type="struct" required="true" />
          <cfset rc.message = "cfdistro - CFML Distribution Management" />
     </cffunction>

     <cffunction name="endDelete" access="public" output="false" returntype="void">
          <cfargument name="rc" type="struct" required="true" />
          <!--- distro deleted so by default lets go back to the distros list page --->
          <cfset variables.fw.redirect("distro.list") />
     </cffunction>

     <cffunction name="form" access="public" output="false" returntype="void">
          <cfargument name="rc" type="struct" required="true" />
          <!--- sending as named arguments, service will handle validation, returns new distro if not found --->
          <cfset rc.distro = getDistroService().get(argumentCollection=rc) />
          <!--- we need to retrieve all departments for the drop down selection --->
          <cfset rc.departments = getDepartmentService().list() />
     </cffunction>

     <cffunction name="view" access="public" output="false" returntype="void">
          <cfargument name="rc" type="struct" required="true" />
          <!--- sending as named arguments, service will handle validation, returns new distro if not found --->
          <cfset rc.distro = getDistroService().get(argumentCollection=rc) />
		<cfif NOT structKeyExists(rc,"message")>
			<cfset rc.message = "" />
		</cfif>
          <!--- we need to retrieve all departments for the drop down selection --->
          <cfset rc.departments = getDepartmentService().list() />
     </cffunction>

     <cffunction name="testrewrite" access="public" output="false" returntype="void">
          <cfargument name="rc" type="struct" required="true" />
<!---
			<cfset var urlregex = rc.urlregex />
			<cfset var fromUrl = rc.fromUrl />
 --->
			<cfscript>
				fromUrl = "/rewrite-status";
				toUrl = "/rewrite-status";

				FileInputStream = createObject("java","java.io.FileInputStream");
				MockRequest = createObject("java","org.tuckey.web.testhelper.MockRequest");
				MockResponse = createObject("java","org.tuckey.web.testhelper.MockResponse");
				Conf = createObject("java","org.tuckey.web.filters.urlrewrite.Conf");
				RewrittenUrl = createObject("java","org.tuckey.web.filters.urlrewrite.RewrittenUrl");
				UrlRewriteWrappedResponse = createObject("java","org.tuckey.web.filters.urlrewrite.UrlRewriteWrappedResponse");
				UrlRewriter = createObject("java","org.tuckey.web.filters.urlrewrite.UrlRewriter");
				loglev = createObject("java","org.tuckey.web.filters.urlrewrite.utils.Log");
				loglev.setLevel("DEBUG");

				conf = Conf.init(FileInputStream.init("/workspace/cfdistro/build/urlrewrite.xml"), "urlrewrite.xml");
				rewriter = UrlRewriter.init(conf);
				mockreq = MockRequest.init(fromUrl);
				mockresp = MockResponse.init();
				dump(rewriter.processRequest(mockreq, mockresp));
				rewrittenUrl = rewriter.processRequest(mockreq, mockresp);
				writeoutput("Could not rewrite URL from:" & fromUrl & " to:" & toUrl & rewrittenUrl.getTarget());
				writeoutput("Rewrite from:" & fromUrl & " to:" & toUrl & " did not succeed" & toUrl & rewrittenUrl.getTarget());
				abort;

			</cfscript>
		<cfif NOT structKeyExists(rc,"message")>
			<cfset rc.message = "" />
		</cfif>
          <!--- we need to retrieve all departments for the drop down selection --->
          <cfset rc.departments = getDepartmentService().list() />
     </cffunction>

     <cffunction name="persist" access="public" output="false" returntype="void">
          <cfargument name="rc" type="struct" required="true" />
          <!--- sending as named arguments, service will handle validation, returns new distro if not found --->
          <cfset rc.distro = getDistroService().persist(argumentCollection=rc) />
		<cfif NOT structKeyExists(rc,"message")>
			<cfset rc.message = "" />
		</cfif>
          <!--- we need to retrieve all departments for the drop down selection --->
          <cfset rc.distros = getDistroService().list() />
     </cffunction>

     <cffunction name="loadpersisted" access="public" output="false" returntype="void">
          <cfargument name="rc" type="struct" required="true" />
          <!--- sending as named arguments, service will handle validation, returns new distro if not found --->
          <cfset rc.distros = getDistroService().loadpersisted(argumentCollection=rc) />
		<cfif NOT structKeyExists(rc,"message")>
			<cfset rc.message = "" />
		</cfif>
          <cfset variables.fw.redirect("distro.list") />
     </cffunction>

	<cffunction name="cfdistroinstall" access="public" output="false" returntype="void">
	     <cfargument name="rc" type="struct" required="true" />
	     <!--- sending as named arguments, service will handle validation, returns new distro if not found --->
	     <cfset rc.distro = getDistroService().get(argumentCollection=rc) />
	     <cfset var results = rc.distro.makeCFDistroBuild() />
          <cfset rc.message = "Copied CFDistro support files<blockquote><pre>" & results.outtext & results.errortext & "</pre></blockquote>" />
	     <!--- we need to retrieve all departments for the drop down selection --->
          <cfset variables.fw.redirect("distro.view",'id,message') />
	</cffunction>

	<cffunction name="build" access="public" output="false" returntype="void">
	     <cfargument name="rc" type="struct" required="true" />
	     <!--- sending as named arguments, service will handle validation, returns new distro if not found --->
	     <cfset rc.distro = getDistroService().get(argumentCollection=rc) />
	     <cfif structKeyExists(rc,"target")>
		     <cfset target = rc.target>
	     <cfelse>
		     <cfset target = "build">
		</cfif>
	     <cfset var results = rc.distro.build(target) />
          <cfset rc.message = "Build Results<blockquote><pre>" & results.outtext & results.errortext & "</pre></blockquote>" />
	     <!--- we need to retrieve all departments for the drop down selection --->
          <cfset variables.fw.redirect("distro.view",'id,message') />
	</cffunction>

     <cffunction name="startSave" access="public" output="false" returntype="void">
          <cfargument name="rc" type="struct" required="true" />
          <cfset var distroService = getDistroService() />
          <cfset var distro = "" />
          <!--- sending as named arguments, service will handle validation, returns new distro if not found --->
          <cfset distro = distroService.get(argumentCollection=rc) />
          <!--- update our distro object with the data entered --->
          <cfset variables.fw.populate(distro,"id,distroname,buildDirectory",true) />

          <!--- update the department object with the new selection --->
          <cfif structKeyExists(rc, "departmentId") AND len(rc.departmentId)>
               <cfset distro.setDepartmentId(rc.departmentId) />
               <cfset distro.setDepartment(getDepartmentService().get(rc.departmentId)) />
          </cfif>
          <cfset rc.distro = distro />
     </cffunction>

     <cffunction name="endSave" access="public" output="false" returntype="void">
          <cfargument name="rc" type="struct" required="true" />
		<cfset rc.id = rc.distro.getId()>
          <!--- distro saved so by default lets go back to the distros list page --->
          <cfset variables.fw.redirect("distro.list") />
     </cffunction>

</cfcomponent>
