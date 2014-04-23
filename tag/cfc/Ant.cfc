<cfcomponent output="false"><cfscript>

	thisDir = getDirectoryFromPath(getMetaData(this).path);
	cl = createObject("LibraryLoader").init(thisDir & "/../../ant/lib/",thisDir & "/../../lib/").init();
	//cl = new LibraryLoader(thisDir & "/lib/").init();
	jSystem = cl.create("java.lang.System");
	jThread = cl.create("java.lang.Thread");
	jProject = cl.create("org.apache.tools.ant.Project");
	jSimpleBigProjectLogger = cl.create("org.apache.tools.ant.listener.SimpleBigProjectLogger");
	jProjectHelper = cl.create("org.apache.tools.ant.ProjectHelper");
	jComponentHelper = cl.create("org.apache.tools.ant.ComponentHelper");

	function doRecorder(required project,required action) {
		var recorderTarget =  cl.create("org.apache.tools.ant.Target").init();
		var recordAction = cl.create("org.apache.tools.ant.taskdefs.Recorder$ActionChoices");
		var verbosityLevel = cl.create("org.apache.tools.ant.taskdefs.Recorder$VerbosityLevelChoices");
		var recorder = cl.create("org.apache.tools.ant.taskdefs.Recorder");
		project.addTarget("ciao"&action, recorderTarget);
		recordAction.setValue(lcase(action));
		recorder.setProject(project);
		recorder.setName("/tmp/log.txt");
		recorder.setAction(recordAction);
		recorder.setAppend(false);
		verbosityLevel.setValue("verbose");
		recorder.setLogLevel(verbosityLevel);
		recorderTarget.addTask(recorder);
		recorderTarget.execute();
	}

	function getCurrentOutput() {
		return toString(variables.outStream);
	}

    remote function run(antfile,target="",properties,basedir="",logLevel="MSG_INFO",action="run",generatedContent="",taskOutputOnly=true)  {
			variables.switchThreadContextClassLoader = cl.getLoader().switchThreadContextClassLoader;
			return switchThreadContextClassLoader(this.runInThreadContext,arguments,cl.getLoader().getURLClassLoader());
	}

	function runInThreadContext(antfile,target="",properties,basedir="",logLevel="MSG_INFO",action="run",generatedContent="",taskOutputOnly=true) {
		//MSG_ERR, MSG_WARN, MSG_INFO, MSG_VERBOSE, MSG_DEBUG
			var buildfile = antfile;
			var targetname = target;
			var cTL = jThread.currentThread().getContextClassLoader();
			thisDir = getDirectoryFromPath(getMetaData(this).path);
			//jThread.currentThread().setContextClassLoader(cl.GETLOADER().getURLClassLoader());
				var definedProps = createObject("java","java.util.Properties").init();
				if(structKeyExists(arguments,"properties") && isStruct(arguments.properties)) {
					var x = 0;
					for(x=1; x lte listLen(structKeyList(arguments.properties)); x++){
						var prop = listGetAt(structKeyList(arguments.properties),x);
						definedProps.put(prop,arguments.properties[prop].toString());
					}
				}

				//var DemuxOutputStream = createObject("java","org.apache.tools.ant.DemuxOutputStream");
				var PrintStream = createObject("java","java.io.PrintStream");
				if(structKeyExists(arguments,"outputstream")) {
					var outStream = arguments.outputstream;
				} else {
					var outStream = createObject("java","java.io.ByteArrayOutputStream").init();
				}
				var errStream = createObject("java","java.io.ByteArrayOutputStream").init();
				var outPrint = PrintStream.init(outStream);
				var errPrint = PrintStream.init(errStream);

				var prop = "";
				var runResults = structNew();
				if(baseDir == "") {
					basedir = getDirectoryFromPath(buildfile);
				}
				if(NOT fileExists(buildFile) && generatedContent =="") {
				  throw("cfantrunner.buildfile.missing","File not found: #buildFile#");
				}
				var buildfileob = createObject("java","java.io.File").init(buildFile);
				var system = createObject("java","java.lang.System");
				system.setProperty("ant.home",thisDir);

				var project = jProject.init();
				//request.debug(createObject("java","ClassLoaderUtils").showClassLoaderHierarchy(project.class.classLoader));
		        project.setCoreLoader( cl.GETLOADER().getURLClassLoader() );
				//runLogger.setMessageOutputLevel(project[attributes.logLevel]);
		        //project.setDefaultInputStream( system.in );
		        //system.setIn( createObject("java","org.apache.tools.ant.DemuxInputStream").init( project ) );
				//system.setOut(PrintStream.init(DemuxOutputStream.init(project,false)));
				//system.setErr(PrintStream.init(DemuxOutputStream.init(project,true)));

	 			project.fireBuildStarted();

				project.init();
				project.setSystemProperties();

				var runLogger = jSimpleBigProjectLogger.init();
				runLogger.setErrorPrintStream(errPrint);
				runLogger.setOutputPrintStream(outPrint);
				runLogger.setMessageOutputLevel(project[logLevel]);
		        project.addBuildListener(runLogger);

/*
	     		var propertyHelper = createObject("java","org.apache.tools.ant.PropertyHelper").getPropertyHelper(project);
	     		var ResolvePropertyMap = createObject("java","org.apache.tools.ant.property.ResolvePropertyMap").init(project, propertyHelper,propertyHelper.getExpanders())
	                    .resolveAllProperties(definedProps, javacast("null",""), false);
*/

	            var propsIt = definedProps.entrySet().iterator();
	            while(propsIt.hasNext()) {
	                var ent = propsIt.next();
	                project.setUserProperty(ent.getKey(), ent.getValue());
	            }

				project.setKeepGoingMode(false);

	     		var helper = jProjectHelper.getProjectHelper();
	     		var comhelper = jComponentHelper.getComponentHelper(project);
	     		// load default task/data definitions
	     		comhelper.initDefaultDefinitions();

		        project.addReference( "ant.projectHelper", helper );
				project.setUserProperty("ant.file",buildfileob.getAbsolutePath());
				project.setProperty("cfdistro.classloader.type","server");
				project.setProperty("ant.reuse.loader","true");


				//doRecorder(project,"start");
				project.setBasedir(baseDir);

				if(generatedContent != ""){
					var cfdistroFile = getDirectoryFromPath(getMetadata(this).path) &"../../build.xml";
					var gennedProject = "<project name='gennedProject'><import file='#cfdistroFile#'/><target name='__gennedAntTargetFool'>#generatedContent#</target></project>";
					var tFile = getTempfile(getTempDirectory(),".xml");
					fileWrite(tFile,gennedProject);
					var buildfileob = createObject("java","java.io.File").init(tFile);
					targetName = "__gennedAntTargetFool";
				}
		        //helper.parse( project, buildfileob );
				helper.configureProject(project, buildfileob);
				if(targetName == ""){
					targetName = project.getDefaultTarget();
				}
				if(targetName == ""){
					throw("cfantrunner.target.missing","Target Not found : " & targetName);
				}
				if(NOT listFind(structKeyList(project.getTargets()),targetName)) {
					throw("cfantrunner.target.missing","Target Not found : " & targetName);
				}
				try{
					if(action == "getTargets") {
						var targets = getTargets(project);
		 				project.fireBuildFinished(javacast("null",""));
						errPrint.close();
						if(!structKeyExists(arguments,"outputstream"))
							outPrint.close();
						//jThread.currentThread().setContextClassLoader(cTL);
						return targets;
					} else {
						project.executeTarget(targetName);
					}
				}
				catch (any err) {
		 			project.fireBuildFinished(javacast("null",""));
					throw(err);
				}
				//doRecorder(project,"stop");
				errPrint.flush();
				errPrint.close();
				outPrint.flush();
				if(!structKeyExists(arguments,"outputstream"))
					outPrint.close();

	 			project.fireBuildFinished(javacast("null",""));
				runResults.errorText = errStream.toString();
				runResults.outText = outStream.toString();
				runResults.properties = duplicate(project.getProperties());
				if(taskOutputOnly) {
					runResults.outText = mid(runResults.outText,find(targetName&":",runResults.outText)+len(TargetName)+2,len(runResults.outText));
					runResults.outText = rereplace(runResults.outText,"\[echo\]\s","","all");
				}
				project = javacast("null","");
				variables.errStream = javacast("null","");
				this = javacast("null","");
				//jThread.currentThread().setContextClassLoader(cTL);
			return runResults;
	}

	function getTargets(project) {
		var targetsArray = project.getTargets();
		var targs = queryNew("name,location,description,if,unless,depends");
		var targets = structKeyList(targetsArray);
		queryAddRow(targs,listLen(targets));
		for(x = 1; x <= listLen(targets); x++) {
			var key = listGetAt(targets,x);
			querysetcell(targs,"name",targetsArray[key].getName(),x);
			location = targetsArray[key].getLocation();
			querysetcell(targs,"location",location.getFileName() & " line: " & location.getLineNumber(),x);
			querysetcell(targs,"description",targetsArray[key].getDescription(),x);
			querysetcell(targs,"if",targetsArray[key].getIf(),x);
			querysetcell(targs,"unless",targetsArray[key].getUnless(),x);
			var deps = targetsArray[key].getDependencies();
			var depList = "";
			while(deps.hasMoreElements()) {
				depList = listAppend(depList,deps.nextElement());
			}
			querysetcell(targs,"depends",depList,x);
		}
		return targs;
	}

</cfscript></cfcomponent>