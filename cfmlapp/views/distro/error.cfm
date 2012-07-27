<cffunction name="structToDL" output="true">
	<cfargument name="struct" required="true" />
	<cfset var key = "" />
	<cfset var strukt = arguments.struct />
	<dl>
		<cfloop list="#structKeyList(strukt)#" index="key">
			<cfif !isSimpleValue(strukt[key]) OR isSimpleValue(strukt[key]) AND strukt[key] neq "">
				<dt><strong>#key#</strong></dt>
			</cfif>
			<cfif isSimpleValue(strukt[key])>
				<dd>#strukt[key]#</dd>
			<cfelseif isStruct(strukt[key])>
				<dd>#structToDL(strukt[key])#</dd>
			</cfif>
		</cfloop>
	</dl>
</cffunction>
<style>
 dl {
	border:1px;
	padding-left:10px;

 }
 dt {
    font-weight: bold;
    text-decoration: underline;
  }
  dd {
    margin: 0;
    padding: 0 0 0.5em 0;
  }
</style>
<div class="item">
	<div class="date"><div>
			DSTRO 
		</div>
		<span>
			01 
		</span></div>
	<div class="content">
		<h1>ERROR OCCURRED</h1>
		<div class="body">
			<cfoutput>
				#structToDL(request.exception)#
			</cfoutput>
		</div>
	</div>
</div>
