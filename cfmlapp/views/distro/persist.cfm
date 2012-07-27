<div class="item">

	<div class="date">
		<div>DSTRO</div>
		<span>01</span>
	</div>
	
	<div class="content">
	
		<h1>Persisted Distributions</h1>
	
		<div class="body">
<cfset local.distros = rc.data>

<cfoutput>
<table border="0" cellspacing="0">
	<col width="40" />
	<thead>
		<tr>
			<th>Id</th>
			<th>Name</th>
			<th>Build Directory</th>
			<!--- <th>Department</th> --->
			<th>Delete</th>
		</tr>
	</thead>
	<tbody>
		<cfif structCount(local.distros) EQ 0>
			<tr><td colspan="5">No distros exist but <a href="index.cfm?action=distro.form">new ones can be added</a>.</td></tr>
		</cfif>
		<cfloop collection="#local.distros#" item="local.id">

			<cfset local.distro = local.distros[local.id]>

			<tr>
				<td><a href="index.cfm?action=distro.view&id=#local.id#">#local.id#</a></td>
				<td><a href="index.cfm?action=distro.view&id=#local.id#">#local.distro.getDistroName()#</a></td>
				<td>#local.distro.getBuildDirectory()#</td>
				<!--- <td>#local.distro.getDepartment().getName()#</td> --->
				<td><a href="index.cfm?action=distro.delete&id=#local.id#">DELETE</a></td>
			</tr>
		</cfloop>
	</tbody>
</table>
</cfoutput>
		</div>
	
	</div>

</div>


