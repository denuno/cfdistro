<cfcomponent extends="framework">

	<cfscript>
	this.mappings["/distroManagerAJAX"] = expandPath("/cfdistro/cfmlapp/");
	this.name = 'fw1-distroManagerAJAX';


	resp = getPageContext().getResponse();

	variables.framework = {
	  base="/distroManagerAJAX",
	  baseURL=getContextRoot(),
	  action = 'action',
	  usingSubsystems = false,
	  defaultSubsystem = 'home',
	  defaultSection = 'main',
	  defaultItem = 'default',
	  subsystemDelimiter = ':',
	  siteWideLayoutSubsystem = 'common',
	  home = 'distro.default', // defaultSection & '.' & defaultItem
	  // or: defaultSection & subsystemDelimiter & defaultSection & '.' & defaultItem
	  error = 'distro.error', // defaultSection & '.error'
	  // or: defaultSection & subsystemDelimiter & defaultSection & '.error'
	  reload = 'init',
	  password = 'true',
	  reloadApplicationOnEveryRequest = false,
	  preserveKeyURLKey = 'fw1pk',
	  maxNumContextsPreserved = 10,
	  applicationKey = 'org.corfield.framework'
	};
	//base = replaceNoCase(getDirectoryFromPath(getCurrentTemplatePath()), expandPath(""), "")

	function setupApplication()
	{
		setBeanFactory(createObject("component", "cfdistro.cfmlapp.models.ObjectFactory").init(expandPath("/cfdistro/cfmlapp/config/beans.xml.cfm")));
	}

/*
  total hack because urlrewrite clobbers request content for some reason!
 */
	function onRequestStart(targetPath) {
		var param = "";
		if(gethTTPRequestData().method eq "POST") {
			if(NOT structKeyExists(form,"fieldnames")) {
				var paramMap = getPageContext().getRequest().getParameterMap();
				var paramMapKeys = structKeyList(paramMap);
				form.fieldnames = paramMapKeys;
				for(x =1; x lte listLen(paramMapKeys); x++) {
					param = listGetAt(paramMapKeys,x);
					form[param] = paramMap[param][1];
				}
			}
		}
		super.onRequestStart(targetPath);
	}

	</cfscript>

</cfcomponent>