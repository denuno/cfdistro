<cfif structKeyExists(url,"cfe")>
	<cfset cfecall = createObject("java","org.cfeclipse.cfeclipsecall.CallClient") />
	<cfset doOpen = cfecall.doOpen("2342","/$HOME/programs/eclipse-inst/eclipse.command",url.cfe)>
<cfelseif structKeyExists(form,"cfe")>
	<cfset cfecall = createObject("java","org.cfeclipse.cfeclipsecall.CallClient") />
	<cfset doOpen = cfecall.doOpen("2342","/$HOME/programs/eclipse-inst/eclipse.command",form.cfe)>
</cfif>
<cfabort />
