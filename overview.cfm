<cfoutput>

<cfif arguments.req.fontsjar eq "" OR structKeyExists(arguments.req,"setfontsjar")
			OR NOT fileExists(arguments.req.fontsjar)>
	<h2>Set fonts.jar location</h2>
	<form action="#action('setFontsJarLoc')#" method="post" enctype="multipart/form-data">
	  #arguments.lang.fontsjar_label# <input type="text" name="fontsjar" id="fontjar" size="31" value="#arguments.req.fontsjar#" />
		<input type="submit" class="submit" name="setFontjar" value="Set Font Jar Dir">
	</form>
	<cfif arguments.req.fontsjar gt "" AND NOT fileExists(arguments.req.fontsjar)>
		<strong style="color:red">File does not exist: #arguments.req.fontsjar#</strong>
	</cfif>
<cfelse>
<strong><a href="#action('overview')#&setfontsjar=1">Fonts Jar: #arguments.req.fontsjar#</a></strong>
</cfif>

<h2>#arguments.lang.add_font_header#</h2>
<form action="#action('addTTFFont')#" method="post" enctype="multipart/form-data">
  #arguments.lang.fontname_label# <input type="text" name="fontname" id="fontname" size="21" />
  #arguments.lang.fontfile_label# <input type="file" name="fontfile" id="fontfile" /><input type="submit" class="submit" name="addFont" value="Add Font">
</form>

<span style="color:red">#arguments.lang.restart_railo#</span>

<h2>#arguments.lang.remove_font_header#</h2>
<table class="tbl" width="650">
<tr>
	<td></td>
	<td class="tblHead">#arguments.lang.fontname#</td>
	<td class="tblHead">#arguments.lang.fontfile#</td>
</tr>
		<form action="#action('removeTTFFont')#" method="post">
<cfloop array="#arguments.req.installedfonts#" index="fonts">
	<tr>
		<td>
			<input type="checkbox" class="checkbox" name="fontfiles" value="#fonts.fontfile#">
		</td>		
		<td class="tblContent">#fonts.fontname#</td>
		<td class="tblContent"><a href="#action('testfont')#&fontfile=#fonts.fontfile#" title="test #fonts.fontname#" target="_blank">#fonts.fontfile#</a></td>
	</tr>
</cfloop>
 <tr>
	<td></td>
	<td valign="top"><img src="resources/img/web-bgcolor.gif.cfm" width="1" height="14"><img src="resources/img/web-bgcolor.gif.cfm" width="36" height="1">
	<input type="reset" class="reset" name="cancel" value="cancel">
	<input type="submit" class="submit" name="mainAction" value="delete">
<!--- 
	<input type="submit" class="submit" name="mainAction" value="verify">
 --->
	</td>
	<td>
	</td>
</tr>
		</form>
</table>
</cfoutput>

