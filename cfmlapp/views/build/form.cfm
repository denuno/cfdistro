<cfset local.distro = rc.distro>
<cfset local.depts = rc.departments>

<h3>Distro Info</h3>

<cfoutput>
<form id="distroForm" class="familiar medium" method="post" action="index.cfm?action=distro.save">

	<input type="hidden" name="id" value="#local.distro.getId()#">

	<div class="field">
		<label for="distroName" class="label">Name:</label>
		<input type="text" name="distroName" id="distroName" value="#local.distro.getDistroName()#">
	</div>

	<div class="field">
		<label for="buildDirectory" class="label">Build Directory:</label>
		<input type="text" name="buildDirectory" id="buildDirectory" value="#local.distro.getBuildDirectory()#">
	</div>

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

	<div class="control">
	     <input type="submit" value="Build">
	     <input type="submit" value="Deploy">
	</div>
	<div class="control">
	     <input type="submit" value="Save Distro">
	     <input type="submit" value="Delete Distro">
	</div>

</form>
</cfoutput>