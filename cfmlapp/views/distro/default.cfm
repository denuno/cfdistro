<div class="item">

	<div class="content">

		<h1><cfoutput>#rc.message#</cfoutput></h1>
		<div class="body">
		<cfif structKeyExists(rc, "reload")>
			<p><strong>The framework cache (and application scope) have been reset.</strong></p>
		</cfif>
		<p>Welcome to something kinda nufty.</p>

<!---
<!-- put in server root -->
ColdFusion Information - click on struct for  infomation<br>
<cfoutput>
<br>Base Template Path = #GetBaseTemplatePath()#<p>
<cfdump var="#server#"expand="no" Label="Server"><p>

<cfset fObj = createObject("java", "coldfusion.server.ServiceFactory") >

<cfset MyService = fObj.getRuntimeService() >
<cfset MyData = MyService.getMappings() >
<cfdump var="#MyData#" expand="no" Label="Mappings"><p>

<cfset MyService = fObj.getDataSourceService() >
<cfset MyData = MyService.getDatasources() >
<cfdump var="#MyData#" expand="no" Label="Data Sources" ><p>

<cfset allTasks = fObj.CronService.listAll()>
<cfset numberOtasks = arraylen(allTasks)>
<cfset CronArray = ArrayNew(1)>
<cfloop index="i" from="1" to="#numberOtasks#">
 <CFSET CronTemp = StructNew()>
 <CFSET CronTemp.task = allTasks[i].task>
 <CFSET CronTemp.interval = allTasks[i].interval>
 <CFSET CronTemp.start_date = allTasks[i].start_date>
 <CFSET CronTemp.http_proxy_port = allTasks[i].http_proxy_port>
 <CFSET CronTemp.http_port = allTasks[i].http_port>
 <CFSET CronTemp.request_time_out = allTasks[i].request_time_out>
 <CFSET CronTemp.resolveurl = allTasks[i].resolveurl>
 <CFSET CronTemp.start_time = allTasks[i].start_time>
 <CFSET CronTemp.disabled = allTasks[i].disabled>
 <CFSET CronTemp.operation = allTasks[i].operation>
 <CFSET CronTemp.publish = allTasks[i].publish>
 <CFSET CronTemp.url = allTasks[i].url>
 <CFSET CronTemp.paused = allTasks[i].paused>
 <CFSET ArrayAppend(CronArray, CronTemp)>
</cfloop>
<cfdump var="#CronArray#" expand="no" Label="Scheduled Tasks"><p>

<CFSET  results=StructNew()>
<CFSET  dbService = fObj.getDebuggingService()>
<CFSET  mailService = fObj.getMailSpoolService()>
<CFSET  rtService = fObj.getRuntimeService()>
<CFSET results.debugging=dbService.isEnabled()>
<CFSET results.debugip=dbService.iplist.iplist>
<CFSET results.mailserver=mailService.getServer()>
<CFSET results.mailthreads=mailService.getMaxDeliveryThreads()>
<CFSET results.trustedcache=rtService.isTrustedCache()>
<CFSET results.slowlimit=rtService.getSlowRequestLimit()>
<cfdump var="#results#" expand="no" Label="Configuration Settings"><p>

<p><b>Driver Versions</b>
<cfset drivernames = "macromedia.jdbc.oracle.OracleDriver,
macromedia.jdbc.db2.DB2Driver, macromedia.jdbc.informix.InformixDriver,
macromedia.jdbc.sequelink.SequeLinkDriver,
macromedia.jdbc.sqlserver.SQLServerDriver,
macromedia.jdbc.sybase.SybaseDriver">
<cfset drivernames=Replace(drivernames," ","","ALL")>
<table BORDER="1" cellpadding="5">
 <cfloop index="drivername" list="#drivernames#">
  <cfobject action="CREATE" class="#drivername#" name="driver" type="JAVA">
  <cfset args= ArrayNew(1)>
  <cfset driver.main(args)>
  <cfoutput><tr><td>#drivername#</td><td>#driver.getMajorVersion()#.#driver.getMinorVersion()#</td></tr></cfoutput>
 </cfloop>
</table>

</cfoutput>

		<cfschedule action="run" task="__list">
 --->
		</div>

	</div>

</div>


