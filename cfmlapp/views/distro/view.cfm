<cfset local.distro = rc.distro>
<cfset local.id = rc.distro.getId()>
<cfset local.depts = rc.departments>

<cfoutput>
<h2>Distro Info</h2>
					<div class="section-content">
						<h3>
		#local.distro.getDistroName()#
						</h3>
						<h4>
Build File: #local.distro.getBuildDirectory()#
		<a href="#resp.encodeURL('index.cfm?action=distro.form&id=#local.id#')#">Edit</a>
						</h4>
						<p>
<form id="distroForm" class="familiar medium" method="post" action="#resp.encodeURL('index.cfm?action=distro.save')#">

	<input type="hidden" name="id" value="#local.id#">

	<p><cfoutput>#rc.message#</cfoutput></p>


		<cfif local.distro.buildFileExists()>
			<a href="#resp.encodeURL('index.cfm?action=distro.build&id=#local.id#&target=runwar.start')#">Start</a> |
			<a href="#resp.encodeURL('index.cfm?action=distro.testrewrite&id=#local.id#')#">Test URLRewriteFilter</a> |
			<a href="#resp.encodeURL('index.cfm?action=distro.build&id=#local.id#')#">Build</a> |
	 		<a href="#resp.encodeURL('index.cfm?action=distro.cfdistroinstall&id=#local.id#')#">Update CFDistro</a> |
	 		<a href="#resp.encodeURL('index.cfm?action=distro.build&target=tests.build.start.run.stop&id=#local.id#')#">tests.build.start.run.stop</a> |
	 		<a href="#resp.encodeURL('index.cfm?action=distro.build&target=tests.build.start.run.stop.both&id=#local.id#')#">tests.build.start.run.stop.both</a>
 	<cfelse>
	 		<a href="#resp.encodeURL('index.cfm?action=distro.cfdistroinstall&id=#local.id#')#">Install CFDistro</a>
		</cfif>

<!---
	<div class="field">
		<label for="email" class="label">Email:</label>
		<input type="text" name="email" id="email" value="#local.distro.getEmail()#">
	</div>

	<div class="field">
		<label for="departmentId" class="label">Department:</label>
		<select name="departmentId" id="departmentId">
			<cfloop collection="#local.depts#" item="local.id">

				<cfset local.dept = local.depts[local.id]>

				<!--- when editing a distro we need to set the dept that distro currently has --->
				<cfif local.id EQ local.distro.getDepartmentId()>
					<option value="#local.id#" selected="selected">#local.dept.getName()#</option>
				<cfelse>
					<option value="#local.id#">#local.dept.getName()#</option>
				</cfif>
            </cfloop>
		</select>
	</div>
 --->
</form>
</cfoutput>
						</p>
				</div>
