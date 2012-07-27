<h3>
	Distributions
</h3>
<cfset local.distros = rc.data />
<cfoutput>
	<cfif structCount(local.distros) EQ 0>
		<div class="section-content">
			<h4>
				No distros exist but
				<a href="index.cfm?action=distro.form">
					new ones can be added
				</a>
			</h4>
		</div>
	</cfif>
	<cfloop collection="#local.distros#" item="local.id">
		<cfset local.distro = local.distros[local.id] />
		<div class="section-content">
			<h3>
				<a href="#resp.encodeURL('index.cfm?action=distro.view&id=#local.id#')#">
					#local.distro.getDistroName()#
				</a>
			</h3>
			<h4>
				#expandPath(local.distro.getBuildDirectory())#
			</h4>
			<p>
				Woohoo
				<a href="#resp.encodeURL('index.cfm?action=distro.delete&id=#local.id#')#">
					DELETE
				</a>
			</p>
		</div>
	</cfloop>
</cfoutput>
