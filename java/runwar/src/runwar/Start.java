package runwar;

import java.io.File;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintStream;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.lang.management.ManagementFactory;
import java.lang.management.RuntimeMXBean;
import java.lang.reflect.Method;
import java.net.InetAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.URL;
import java.net.URLClassLoader;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;
import java.awt.AWTException;
import java.awt.Image;
import java.awt.MenuItem;
import java.awt.PopupMenu;
import java.awt.SystemTray;
import java.awt.Toolkit;
import java.awt.TrayIcon;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;

import javax.imageio.ImageIO;
import javax.net.SocketFactory;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.cli.PosixParser;
import org.eclipse.jetty.ajp.Ajp13SocketConnector;

import org.eclipse.jetty.server.Connector;
import org.eclipse.jetty.server.Handler;
import org.eclipse.jetty.server.NCSARequestLog;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.handler.ContextHandlerCollection;
import org.eclipse.jetty.server.handler.DefaultHandler;
import org.eclipse.jetty.server.handler.HandlerCollection;
import org.eclipse.jetty.server.handler.RequestLogHandler;
import org.eclipse.jetty.server.nio.SelectChannelConnector;
import org.eclipse.jetty.servlet.ServletHolder;
import org.eclipse.jetty.util.resource.Resource;
import org.eclipse.jetty.webapp.WebAppClassLoader;
import org.eclipse.jetty.webapp.WebAppContext;

//import railo.loader.engine.CFMLEngine;

public class Start {

	private static final Options options = new Options();
	private static Server server;
	private static String PID;

	private static String warPath;
	private static String contextPath = "/";
	private static String host = "127.0.0.1";
	private static int portNumber = 8088;
	private static int ajpPort = 8009;
	private static String loglevel = "WARN";
	private static String[] runwarArgs;
	private static int socketNumber = 8779;
	private static String logDir;
	private static String cfmlDirs;
	private static boolean background = true;
	private static boolean keepRequestLog = false;
	private static boolean openbrowser = false;
	private static String openbrowserURL;
	private static String pidFile;
	private static boolean enableAJP;
	private static int launchTimeout = 50 * 1000; // 50 secs
	private static PosixParser parser;
	private static final String SYNTAX = " java -jar runwar.jar [-war] path/to/war [options]";
	private static final String HEADER = " The runwar lib wraps jetty-runner with more awwsome. Defaults (parenthetical)";
	private static final String FOOTER = " source: github somewhere";
	private static String processName= "RunWAR";
	private static URLClassLoader _classLoader;
	private static String libDirs = null;
	private static URL jarURL = null;
	
	static TrayIcon trayIcon;
	private static boolean debug = false;
	private static File warFile;
	private static String iconImage = null;

    	
	// for openBrowser 
	public Start(int seconds) {
		Timer timer = new Timer();
		timer.schedule(this.new OpenBrowserTask(), seconds * 1000);
	}

	public static final String[] __plusConfigurationClasses = new String[] {
			org.eclipse.jetty.webapp.WebInfConfiguration.class.getCanonicalName(),
			org.eclipse.jetty.webapp.WebXmlConfiguration.class.getCanonicalName(),
			org.eclipse.jetty.webapp.MetaInfConfiguration.class.getCanonicalName(),
			org.eclipse.jetty.webapp.FragmentConfiguration.class.getCanonicalName(),
			org.eclipse.jetty.plus.webapp.EnvConfiguration.class.getCanonicalName(),
			org.eclipse.jetty.webapp.JettyWebXmlConfiguration.class.getCanonicalName(),
			org.eclipse.jetty.webapp.TagLibConfiguration.class.getCanonicalName() };

	public static void main(String[] args) throws Exception {
		runwarArgs = args;
		parseArguments(args);
		String userHome = System.getProperty("user.home");
		File libDir;
		if(userHome != null) {
			File currentDir = new File(userHome + "/.railo/");
			libDir = new File(currentDir,"lib");
		} else {
			libDir = new File(Start.class.getProtectionDomain().getCodeSource().getLocation().getPath()).getParentFile();
		}
		System.setProperty("org.eclipse.jetty.LEVEL",loglevel.toUpperCase());

		System.setProperty("file.encoding","UTF-8");
		// hack to prevent . being picked up as the system path (jacob.x.dll)
		if(System.getProperty("java.library.path") == null) {
			System.setProperty("java.library.path",libDir.getPath());
		} else {
			System.setProperty("java.library.path",libDir.getPath() + ":" + System.getProperty("java.library.path"));
		}
		// check/get available ports
        try {
			ServerSocket nextAvail = new ServerSocket(portNumber, 1, InetAddress.getByName(host));
			portNumber = nextAvail.getLocalPort();
			ServerSocket nextAvail2 = new ServerSocket(socketNumber, 1, InetAddress.getByName(host));
			socketNumber = nextAvail2.getLocalPort();
			nextAvail.close();
			nextAvail2.close();
		} catch (Exception e) {
			throw new RuntimeException(e);
		}

		//System.out.println("warpath:"+warPath+" contextPath:" + contextPath + " host:"+host+" port:" + portNumber + " cfml-dirs:"+cfmlDirs);
		//System.out.println("background: " + background);

		if (background) {
			// this will eventually system.exit();
			relaunchAsBackgroundProcess(launchTimeout);
			// just in case
			Thread.sleep(200);
			System.exit(0);
		}
        String osName = System.getProperties().getProperty("os.name");
        if(osName != null && osName.startsWith("Mac OS X"))
        {   
    		System.setProperty("com.apple.mrj.application.apple.menu.about.name",processName);
    		System.setProperty("com.apple.mrj.application.growbox.intrudes","false");
    		System.setProperty("apple.laf.useScreenMenuBar","true");
    		System.setProperty("-Xdock:name",processName);
            try{
            	Image dockIcon = ImageIO.read(Start.class.getResource("/runwar/icon.png"));
            	Class<?> appClass = Class.forName("com.apple.eawt.Application");
            	Method getAppMethod = appClass.getMethod("getApplication");
            	Object appInstance = getAppMethod.invoke(null);
            	Method dockMethod = appInstance.getClass().getMethod("setDockIconImage", java.awt.Image.class);
            	dockMethod.invoke(appInstance, dockIcon);		
            }
            catch(Exception e) { }
        }
		server = new Server();
		System.out.println("port:" + portNumber + " stop-port:" + socketNumber + " warpath: " + warPath);
		System.out.println("contextPath: " + contextPath);
		System.out.println("Log Directory: " + logDir);
		System.out.println("********************************");
		// runwar.BrowserOpener.openURL("http://127.0.0.1:8080/blah/index.cfm");
		Connector connector = new SelectChannelConnector();
		// SocketConnector connector = new SocketConnector();
		connector.setPort(portNumber);
		connector.setHost(host);
		server.setConnectors(new Connector[] { connector });
		//setupSSL();		
		if(enableAJP) {
			System.out.println("Enabling AJP protocol on port " + ajpPort);
			Ajp13SocketConnector ajp = new Ajp13SocketConnector();
			ajp.setPort(ajpPort);
			server.addConnector(ajp);
		}

		HandlerCollection handlers = server.getChildHandlerByClass(HandlerCollection.class);
		if (handlers == null) {
			handlers = new HandlerCollection();
			server.setHandler(handlers);
		}
		ContextHandlerCollection contexts = handlers.getChildHandlerByClass(ContextHandlerCollection.class);
		if (contexts == null) {
			contexts = new ContextHandlerCollection();
		}

		WebAppContext context;
		if(libDirs != null || jarURL != null) {
			List<URL> cp=new ArrayList<URL>();
			if(libDirs!=null)
				cp.addAll(expandJars(Resource.newResource(libDirs)));
			if(jarURL!=null)
				cp.add(jarURL);
			//context.setExtraClasspath(libDirs+"/");
			initClassLoader(cp);
			//context.setClassLoader(new WebAppClassLoader(_classLoader, context));
			//context.setParentLoaderPriority(true);
			//context.setClassLoader(_classLoader);
		}
		
		File webinf = new File(warFile,"WEB-INF");
		if(warFile.isDirectory() && !webinf.exists()) {
			context = new ExternalContext(contexts, warPath, contextPath, warFile,new File(libDir,"server/WEB-INF"));
			Class cfmlServlet;
			Class restServlet;
			try{
				cfmlServlet = context.getClass().getClassLoader().loadClass("railo.loader.servlet.CFMLServlet");
			} catch (java.lang.ClassNotFoundException e) {
				cfmlServlet = _classLoader.loadClass("railo.loader.servlet.CFMLServlet");
			}
			try{
				restServlet = context.getClass().getClassLoader().loadClass("railo.loader.servlet.RestServlet");
			} catch (java.lang.ClassNotFoundException e) {
				restServlet = _classLoader.loadClass("railo.loader.servlet.RestServlet");
			}
			String webConfigDir = new File(libDir,"server/railo-web/").getPath();
			context.setClassLoader(context.getClass().getClassLoader());
			ServletHolder servletHolder = new ServletHolder(cfmlServlet);
			servletHolder.setInitParameter("configuration",webConfigDir);
			servletHolder.setInitParameter("railo-server-root",new File(libDir,"server").getPath());
			servletHolder.setInitOrder(1);
			ServletHolder rservletHolder = new ServletHolder(restServlet);
			rservletHolder.setInitParameter("railo-web-directory",webConfigDir);
			rservletHolder.setInitOrder(1);
			context.setWelcomeFiles(new String[] {"index.cfm","index.cfml","index.html","index.htm"});
			context.addServlet(servletHolder, "*.cfm");
			context.addServlet(servletHolder, "*.cfc");
			context.addServlet(rservletHolder, "/rest/*");
		} else {
			// WebAppContext context = new WebAppContext(contexts, warPath,contextPath);
			context = new CFMLContext(contexts, warPath, contextPath, cfmlDirs);
			context.setWelcomeFiles(new String[] {"index.cfm","index.cfml","index.html","index.htm"});
		}

		context.setConfigurationClasses(__plusConfigurationClasses);
		// context.setContextPath(contextPath);
		// context.setResourceBase(warPath);
		// context.setWar(warPath);
		// context.setServer(server);
		// context.setResourceAlias("/index.cfm","file:///workspace/cfdistro/build/index.html");
		// server.setHandler(context);
		try {
			PID = ManagementFactory.getRuntimeMXBean().getName().split("@")[0];
		} catch (Exception e) {
			System.out.println("Unable to get PID");
		}
		if (keepRequestLog) {
			System.out.println("Logging requests to " + logDir + "server.log.txt");
			RequestLogHandler requestLogHandler = new RequestLogHandler();
			NCSARequestLog requestLog = new NCSARequestLog(logDir + "server.yyyy_mm_dd.request.log");
			requestLog.setRetainDays(90);
			requestLog.setAppend(true);
			requestLog.setExtended(true);
			requestLog.setLogTimeZone("GMT");
			requestLogHandler.setRequestLog(requestLog);
			handlers.setHandlers(new Handler[] { contexts, new DefaultHandler(), requestLogHandler });
		} else {
			handlers.setHandlers(new Handler[] { contexts, new DefaultHandler() });
		}
		TeeOutputStream tee = null;
		
		if(logDir != null) {
			File logDirectory = new File(logDir);
			logDirectory.mkdir();
			if(logDirectory.exists()) {
				if(debug) System.out.println("Logging to " + logDirectory + "/server.out.txt");
				tee = new TeeOutputStream(System.out, new FileOutputStream(logDirectory + "/server.out.txt"));
				PrintStream newOut = new PrintStream(tee, true);
				System.setOut(newOut);
				System.setErr(newOut);	
			} else {
				if(debug) System.out.println("Could not create log: " + logDirectory + "/server.out.txt");
			}
		}
        Thread monitor = new MonitorThread(tee, socketNumber);
		monitor.start();
		hookTray();

		//System.err.println(Arrays.asList(contexts.getHandlers()));
		server.setHandler(handlers);
		server.setStopAtShutdown(true);
		server.setSendServerVersion(true);

		if (openbrowser) {
			new Start(3);
		}
		server.start();
		portNumber = server.getConnectors()[0].getLocalPort();
		System.out.println("http-port:" + server.getConnectors()[0].getLocalPort() + " stop-port:" + socketNumber +" PID:" + PID);
		// BrowserOpener.openURL("http://" + host + ":" + server.getConnectors()[0].getLocalPort() + contextPath +
		// openurl.replaceFirst("^/", ""));
		server.join();
		if (background) {
			System.exit(0);
		}
	}

	private static List<URL> expandJars(Resource lib) throws IOException {
		List<URL> classpath=new ArrayList<URL>();
		String[] list = lib.list();
		if (list == null)
			return classpath;

		for (String path : list) {
			if (".".equals(path) || "..".equals(path))
				continue;

			Resource item = lib.addPath(path);

			if (item.isDirectory())
				classpath.addAll(expandJars(item));
			else {
				if (path.toLowerCase().endsWith(".jar") || path.toLowerCase().endsWith(".zip")) {
					if(!path.toLowerCase().contains("servlet") && !path.toLowerCase().contains("jetty") &&
							!path.toLowerCase().contains("runwar")) {
						URL url = item.getFile().toURI().toURL();
						System.out.println("lib: added to classpath: "+path);
						classpath.add(url);
					}
				}
			}
		}
		return classpath;
	}

	protected static void initClassLoader(List<URL> _classpath) {
		if (_classLoader == null && _classpath != null && _classpath.size() > 0) {
			/*
			ClassLoader context = Thread.currentThread().getContextClassLoader();
			if (context == null)
				_classLoader = new URLClassLoader(_classpath.toArray(new URL[_classpath.size()]));
			else
				_classLoader = new URLClassLoader(_classpath.toArray(new URL[_classpath.size()]), context);
			Thread.currentThread().setContextClassLoader(_classLoader);
			System.out.println("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOUT"+_classpath.size());
			*/
			_classLoader = new URLClassLoader(_classpath.toArray(new URL[_classpath.size()]),Thread.currentThread().getContextClassLoader());
			Thread.currentThread().setContextClassLoader(_classLoader);
		}
	}	
	
	private static void setupSSL() {
		/*

		SelectChannelConnector connector = new SelectChannelConnector();
        connector.setPort(8080);
        connector.setMaxIdleTime(30000);
        connector.setConfidentialPort(8443);
        connector.setStatsOn(true);
        
        server.setConnectors(new Connector[]
        { connector });

        SslSelectChannelConnector ssl_connector = new SslSelectChannelConnector();
        ssl_connector.setPort(8443);
        SslContextFactory cf = ssl_connector.getSslContextFactory();
        cf.setKeyStore(jetty_home + "/etc/keystore");
        cf.setKeyStorePassword("OBF:1vny1zlo1x8e1vnw1vn61x8g1zlu1vn4");
        cf.setKeyManagerPassword("OBF:1u2u1wml1z7s1z7a1wnl1u2g");
        cf.setTrustStore(jetty_home + "/etc/keystore");
        cf.setTrustStorePassword("OBF:1vny1zlo1x8e1vnw1vn61x8g1zlu1vn4");
        cf.setExcludeCipherSuites(
                new String[] {
                    "SSL_RSA_WITH_DES_CBC_SHA",
                    "SSL_DHE_RSA_WITH_DES_CBC_SHA",
                    "SSL_DHE_DSS_WITH_DES_CBC_SHA",
                    "SSL_RSA_EXPORT_WITH_RC4_40_MD5",
                    "SSL_RSA_EXPORT_WITH_DES40_CBC_SHA",
                    "SSL_DHE_RSA_EXPORT_WITH_DES40_CBC_SHA",
                    "SSL_DHE_DSS_EXPORT_WITH_DES40_CBC_SHA"
                });
        ssl_connector.setStatsOn(true);
        server.addConnector(ssl_connector);
		 */
		
	}

	@SuppressWarnings("static-access")
	private static void parseArguments(String[] args) throws Exception {
		parser = new PosixParser();
		options.addOption( OptionBuilder
                .withDescription( "path to war" )
                .hasArg()
                .withArgName("path")
                .create("war") );
		
		options.addOption( OptionBuilder
				.withLongOpt( "context" )
				.withDescription( "context path.  (/)" )
				.hasArg().withArgName("context")
				.create("c") );
		
		options.addOption( OptionBuilder
				.withLongOpt( "host" )
				.withDescription( "host.  (127.0.0.1)" )
				.hasArg().withArgName("host")
				.create("o") );
		
		options.addOption( OptionBuilder
				.withLongOpt( "port" )
				.withDescription( "port number.  (8088)" )
				.hasArg().withArgName("http port").withType(Number.class)
				.create('p') );
		
		options.addOption( OptionBuilder
				.withLongOpt( "stop-port" )
				.withDescription( "stop listener port number. (8779)\n" )
				.hasArg().withArgName("port").withType(Number.class)
				.create("stopsocket") );
		
		options.addOption( OptionBuilder
				.withDescription( "stop backgrounded.  Optional stop-port" )
				.hasOptionalArg().withArgName("stop port")
				.create("stop") );
		
		options.addOption( OptionBuilder
				.withLongOpt( "enable-ajp" )
				.withDescription( "Enable AJP.  Default is false" )
				.hasArg().withArgName("true|false").withType(Boolean.class)
				.create("enableajp") );
		
		options.addOption( OptionBuilder
				.withLongOpt( "ajp-port" )
				.withDescription( "AJP port.  Disabled if not set." )
				.hasArg().withArgName("ajp port").withType(Number.class)
				.create("ajp") );
		
		options.addOption( OptionBuilder
				.withLongOpt( "log-dir" )
				.withDescription( "Log directory.  (WEB-INF/logs)" )
				.hasArg().withArgName("path/to/log/dir")
				.create("logdir") );

		options.addOption( OptionBuilder
				.withLongOpt( "dirs" )
				.withDescription( "List of external directories to serve from" )
				.hasArg().withArgName("path,path,...")
				.create("d") );
		
		options.addOption( OptionBuilder
				.withLongOpt( "libdir" )
				.withDescription( "List of directories to add contents of to classloader" )
				.hasArg().withArgName("path,path,...")
				.create("libs") );
		
		options.addOption( OptionBuilder
				.withLongOpt( "jar" )
				.withDescription( "jar to be added to classpath" )
				.hasArg().withArgName("path")
				.create("j") );
		
		options.addOption( OptionBuilder
				.withLongOpt( "background" )
				.withDescription( "Run in background (true)" )
				.hasArg().withArgName("true|false").withType(Boolean.class)
				.create('b') );
		
		options.addOption( OptionBuilder
				.withDescription( "Log requests to specified file" )
				.hasArg().withArgName("/path/to/log")
				.create("requestlog") );

		options.addOption( OptionBuilder
				.withLongOpt( "open-browser" )
				.withDescription( "Open default web browser after start (false)" )
				.hasArg().withArgName("true|false")
				.create("open") );

		options.addOption( OptionBuilder
				.withLongOpt( "open-url" )
				.withDescription( "URL to open browser to. (http://$host:$port)\n" )
				.hasArg().withArgName("url")
				.create("url") );
		
		options.addOption( OptionBuilder
				.withDescription( "Process ID file." )
				.hasArg().withArgName("pidfile")
				.create("pidfile") );

		options.addOption( OptionBuilder
				.withLongOpt( "timeout" )
				.withDescription( "Startup timout for background process. (50)\n" )
				.hasArg().withArgName("seconds").withType(Number.class)
				.create("t") );

		options.addOption( OptionBuilder
				.withLongOpt( "loglevel" )
				.withDescription( "log level [DEBUG|INFO|WARN|ERROR] (DEBUG)" )
				.hasArg().withArgName("level")
				.create("level") );

		options.addOption( OptionBuilder
				.withDescription( "set log level to debug" )
				.hasArg().withArgName("true|false").withType(Boolean.class)
				.create("debug") );
		
		options.addOption( OptionBuilder
				.withLongOpt( "processname" )
				.withDescription( "Process name where applicable" )
				.hasArg().withArgName("name")
				.create("procname") );

		options.addOption( OptionBuilder
				.withLongOpt( "iconpath" )
				.withDescription( "icon path for OS X" )
				.hasArg().withArgName("path")
				.create("icon") );
		
		options.addOption( new Option( "h", "help", false, "print this message" ) );

		try {
			CommandLine line = parser.parse( options, args );
		    // parse the command line arguments
		    if (line.hasOption("help")) {
		    	printUsage("Options");
		    }
		    if (line.hasOption("background")) {
		    	background = Boolean.valueOf(line.getOptionValue("background"));
		    }
		    if (line.hasOption("libs")) {
                Resource lib = Resource.newResource(line.getOptionValue("libs"));
                if (!lib.exists() || !lib.isDirectory())
                	printUsage("No such lib directory "+lib);
                libDirs = line.getOptionValue("libs");
            }

		    if (line.hasOption("jar")) {
		    	 Resource jar = Resource.newResource(line.getOptionValue("jar"));
	                if (!jar.exists() || jar.isDirectory())
	                	printUsage("No such jar "+jar);
	                jarURL = jar.getFile().toURI().toURL();
	        }
		    
		    if (line.hasOption("timeout")) {
		    	launchTimeout = ((Number)line.getParsedOptionValue("timeout")).intValue() * 1000;
		    }
		    if (line.hasOption("stop-port")) {
		    	socketNumber = ((Number)line.getParsedOptionValue("stop-port")).intValue();
		    }
		    if (line.hasOption("war")) {
		    	warPath = line.getOptionValue("war");
		    	warFile = new File(warPath);
		    	if(warFile.exists()) {
		    		warPath = warFile.toURI().toURL().toString();
		    	} else {
		    		throw new RuntimeException("Could not find war! " + warPath);
		    	}
		    } else if (!line.hasOption("stop")) {
		    	printUsage("Must specify -war path/to/war, or -stop [-stop-socket]");
		    } 
		    if (line.hasOption("stop")) {
		    	if(line.getOptionValue("stop")!=null) {
		    		socketNumber = Integer.parseInt(line.getOptionValue("stop")); 
		    	}
		    	new Stop().main(new String[] {Integer.toString(socketNumber)});
		    }
		    if (line.hasOption("context")) {
		    	contextPath = line.getOptionValue("context");
		    }
		    if (line.hasOption("host")) {
		    	host  = line.getOptionValue("host");
		    }
		    if (line.hasOption("port")) {
		    	portNumber = ((Number)line.getParsedOptionValue("port")).intValue();
		    }
		    if (line.hasOption("enable-ajp")) {
		    	enableAJP = Boolean.valueOf(line.getOptionValue("enable-ajp"));
		    }
		    if (line.hasOption("ajp")) {
		    	ajpPort = ((Number)line.getParsedOptionValue("ajp")).intValue();
		    }
		    if (line.hasOption("logdir")) {
		    	logDir= line.getOptionValue("logdir");
		    } else {
		    	if(warFile.isDirectory()) {
		    		logDir = warFile.getPath() + "/WEB-INF/logs/";
		    	}
		    }
			cfmlDirs = warPath;
		    if (line.hasOption("dirs")) {
		    	cfmlDirs= line.getOptionValue("dirs");
		    }
		    if (line.hasOption("requestlog")) {
		    	keepRequestLog = Boolean.valueOf(line.getOptionValue("requestlog"));
		    }
		    if (line.hasOption("loglevel")) {
		    	loglevel = line.getOptionValue("loglevel").toUpperCase();
		    }

		    if (line.hasOption("debug")) {
		    	debug= Boolean.valueOf(line.getOptionValue("debug"));
		    	if(debug)loglevel = "DEBUG";
		    }
		    
		    if (line.hasOption("open-browser")) {
		    	openbrowser = Boolean.valueOf(line.getOptionValue("open"));
		    }
		    if (line.hasOption("open-url")) {
		    	openbrowserURL = line.getOptionValue("open-url");
		    }

		    if (line.hasOption("pidfile")) {
		    	pidFile  = line.getOptionValue("pidfile");
		    }

		    if (line.hasOption("processname")) {
		    	processName  = line.getOptionValue("processname");
		    }

		    if (line.hasOption("icon")) {
		    	iconImage  = line.getOptionValue("icon");
		    }
		    if(loglevel.equals("DEBUG")) {
		    	for(Option arg: line.getOptions()) {
		    		System.err.println(arg);
		    		System.err.println(arg.getValue());
		    	}
		    }
		}
		catch( ParseException exp ) {
		    System.out.println( "Unexpected exception:" + exp.getMessage() );
	    	printUsage(exp.getMessage());
			System.exit(1);
		}
	}

	private static void printUsage(String message) {
	    HelpFormatter formatter = new HelpFormatter();
        formatter.setOptionComparator(new Comparator<Option>() {
            public int compare(Option o1, Option o2) {
            	if(o1.getOpt().equals("war")) {return -1;} else if(o2.getOpt().equals("war")) {return 1;}
            	if(o1.getOpt().equals("p")) {return -1;} else if(o2.getOpt().equals("p")) {return 1;}
            	if(o1.getOpt().equals("c")) { return -1; } else if(o2.getOpt().equals("c")) {return 1;}
            	if(o1.getOpt().equals("d")) { return -1; } else if(o2.getOpt().equals("d")) {return 1;}
            	if(o1.getOpt().equals("b")) { return -1; } else if(o2.getOpt().equals("b")) {return 1;}
            	if(o1.getOpt().equals("h")) {return 1;} else if(o2.getOpt().equals("h")) {return -1;}
            	if(o1.getOpt().equals("url")) {return 1;} else if(o2.getOpt().equals("url")) {return -1;}
            	if(o1.getOpt().equals("open")) {return 1;} else if(o2.getOpt().equals("open")) {return -1;}
            	if(o1.getOpt().equals("stopsocket")) {return 1;} else if(o2.getOpt().equals("stopsocket")) {return -1;}
            	if(o1.getOpt().equals("stop")) {return 1;} else if(o2.getOpt().equals("stop")) {return -1;}
                return o1.getOpt().compareTo(o2.getOpt());
            }
        });
        formatter.setWidth(80);
	    formatter.setSyntaxPrefix("USAGE:");
	    formatter.setLongOptPrefix("--");
	    //formatter.printHelp( SYNTAX, options,false);
	    formatter.printHelp(80, SYNTAX, message + '\n' + HEADER, options, FOOTER, false);
	}

	private static class MonitorThread extends Thread {

		private ServerSocket socket;
		private TeeOutputStream stdout;
		private int socketNumber;

		public MonitorThread(TeeOutputStream tee, int socketNumber) {
			stdout = tee;
			setDaemon(true);
			setName("StopMonitor");
			this.socketNumber = socketNumber;
			try {
				socket = new ServerSocket(socketNumber, 1, InetAddress.getByName("127.0.0.1"));
			} catch (Exception e) {
				throw new RuntimeException(e);
			}
		}

		@Override
		public void run() {
			System.out.println("***********************************");
			System.out.println("*** starting jetty 'stop' listener thread - Host: 127.0.0.1 - Socket: " + this.socketNumber);
			System.out.println("***********************************");
			Socket accept;
			try {
				accept = socket.accept();
				BufferedReader reader = new BufferedReader(new InputStreamReader(accept.getInputStream()));
				reader.readLine();
				System.out.println("***********************************");
				System.out.println("*** stopping jetty embedded server");
				System.out.println("***********************************");
				server.stop();
				accept.close();
				socket.close();
			} catch (Exception e) {
				throw new RuntimeException(e);
			}
			try {
				stdout.close();
			} catch (Exception e) {
				System.out.println("Redirect:  Unable to close this log file!");
			}
			System.exit(0);

		}
	}

	public static boolean serverCameUp(int timeout, long sleepTime, InetAddress server, int port) {
		long start = System.currentTimeMillis();
		while ((System.currentTimeMillis() - start) < timeout) {
			if (!checkServerIsUp(server, port)) {
				try {
					Thread.sleep(sleepTime);
				} catch (InterruptedException e) {
					return false;
				}
			} else {
				return true;
			}
		}
		return false;
	}

	public static boolean checkServerIsUp(InetAddress server, int port) {
		Socket sock = null;
		try {
			sock = SocketFactory.getDefault().createSocket(server, port);
			sock.setSoLinger(true, 0);
			return true;
		} catch (IOException e) {
			return false;
		} finally {
			if (sock != null) {
				try {
					sock.close();
				} catch (IOException e) {
					// don't care
				}
			}
		}
	}

	class OpenBrowserTask extends TimerTask {
		public void run() {
			System.out.println("Waiting upto 35 seconds for "+host+":"+portNumber+"...");
			try {
				if (serverCameUp(35000, 3000, InetAddress.getByName(host), portNumber)) {
					if(!openbrowserURL.startsWith("http")) {
						openbrowserURL = (!openbrowserURL.startsWith("/")) ? "/"+openbrowserURL : openbrowserURL;
						openbrowserURL = "http://" + host + ":" + portNumber + openbrowserURL;
					}
					System.out.println("Opening browser to..." + openbrowserURL);
					BrowserOpener.openURL(openbrowserURL.trim());
					//BrowserOpener.openURL("http://127.0.0.1:"+portNumber + "/railo-context/admin/server.cfm");
				} else {
					System.out.println("could not open browser to..." + openbrowserURL + "... timeout...");					
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
			return;
		}
	}

	/*
	 * 
	 * BACKGROUND
	 * 
	 */

	public static File getJreExecutable() throws FileNotFoundException {
		String jreDirectory = System.getProperty("java.home");
		if (jreDirectory == null) {
			throw new IllegalStateException("java.home");
		}
		final String javaPath = System.getProperty("java.home") + File.separator + "bin" + File.separator + "java"
				+ (File.separator.equals("\\") ? ".exe" : "");
		File exe = new File(javaPath);
		if (!exe.isFile()) {
			throw new FileNotFoundException(exe.toString());
		}
		if(debug)System.out.println("Java: "+javaPath);
		return exe;
	}

	public static void launch(List<String> cmdarray, int timeout) throws IOException, InterruptedException {
		byte[] buffer = new byte[1024];

		ProcessBuilder processBuilder = new ProcessBuilder(cmdarray);
		processBuilder.redirectErrorStream(true);
		Process process = processBuilder.start();
		InputStream is = process.getInputStream();
		InputStreamReader isr = new InputStreamReader(is);
		BufferedReader br = new BufferedReader(isr);
		if(debug ) {
			System.out.println("launching: "+cmdarray.toString());
			System.out.println("timeout of " + timeout / 1000 + " seconds");
		}

		String line;
		int exit = -1;
		long start = System.currentTimeMillis();
		while ((System.currentTimeMillis() - start) < timeout) {
			if (br.ready() && (line = br.readLine()) != null) {
				// Outputs your process execution
				System.out.println(line);
				try {
					exit = process.exitValue();
					if (exit == 0) {
						// Process finished
						while((line = br.readLine())!= null) {
							System.out.println(line);
						}
					} else if(exit==1) {
						while((line = br.readLine())!= null) {
							System.out.println(line);
						}
						System.exit(1);
					}
				} catch (IllegalThreadStateException t) {
					// The process has not yet finished.
					// Should we stop it?
					if(processOutput(line)) {
						System.err.println(line);
						process.destroy();
						Thread.sleep(3000);
						System.exit(1);
					}
					while((line = br.readLine())!= null) {
						if(processOutput(line)) {
							System.err.println(line);
							process.destroy();
							Thread.sleep(3000);
							System.exit(1);
						}
					}
				}
			}
			Thread.sleep(100);
		}
		if((System.currentTimeMillis() - start) > timeout) {
			process.destroy();
			System.err.println("Startup exceeded timeout of " + timeout / 1000 + " seconds");
			System.exit(1);
		}
		System.exit(0);


	}

	private static boolean processOutput(String line) {
		if(line.indexOf("INFO:oejs.AbstractConnector:Started") != -1) {
			// start up was successful, quit out
			System.exit(0);
		} else if(line.indexOf("WARN:oejuc.AbstractLifeCycle:FAILED") != -1) {
			System.err.println("Error deploying servlet!");
			return true;			
		}
		//System.out.println(line);
		return false;
	}

	public static void relaunchAsBackgroundProcess(int timeout) {
		try {
			String path = Start.class.getProtectionDomain().getCodeSource().getLocation().getPath();
			System.out.println("Starting background process from:"+path);
			String decodedPath = URLDecoder.decode(path, "UTF-8");
			decodedPath = new File(decodedPath).getPath();
			List<String> cmdarray = new ArrayList<String>();
			cmdarray.add(getJreExecutable().toString());
			List<String> currentVMArgs = getCurrentVMArgs();
	        String osName = System.getProperties().getProperty("os.name");
	        if(osName != null && osName.startsWith("Mac OS X")) {
	        	cmdarray.add("-Dcom.apple.mrj.application.apple.menu.about.name=" + processName);
	        	cmdarray.add("-Dcom.apple.mrj.application.growbox.intrudes=false");
	        	cmdarray.add("-Dapple.laf.useScreenMenuBar=true");
	        	cmdarray.add("-Xdock:name=" + processName);
	        	cmdarray.add("-Dfile.encoding=UTF-8");
	        }
			for(String arg : currentVMArgs) {
				cmdarray.add(arg);
			}
			cmdarray.add("-jar");
			cmdarray.add(decodedPath);
			int argIndex = 0;
			for(String arg : runwarArgs) {
				//System.out.println(argIndex + arg);
				argIndex++;
				if(arg.contains("background")||arg.startsWith("-b")) {
					// set background to false since we're wrapping it
					//System.out.println("Backgrounding process");
					argIndex++;
					continue;
				} else {
					cmdarray.add(arg);
				}
			}
			cmdarray.add("-background");
			cmdarray.add("false");
			launch(cmdarray,timeout);
		} catch (IOException e) {
			e.printStackTrace();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}

	private static void appendToBuffer(List<String> resultBuffer, StringBuffer buf) {
		if (buf.length() > 0) {
			resultBuffer.add(buf.toString());
			buf.setLength(0);
		}
	}
	
	public static List<String> getCurrentVMArgs(){
		RuntimeMXBean RuntimemxBean = ManagementFactory.getRuntimeMXBean();
		List<String> arguments = RuntimemxBean.getInputArguments();
		return arguments;
	}

	public static String[] tokenizeArgs(String argLine) {
		List<String> resultBuffer = new java.util.ArrayList<String>();

		if (argLine != null) {
			int z = argLine.length();
			boolean insideQuotes = false;
			StringBuffer buf = new StringBuffer();

			for (int i = 0; i < z; ++i) {
				char c = argLine.charAt(i);
				if (c == '"') {
					appendToBuffer(resultBuffer, buf);
					insideQuotes = !insideQuotes;
				} else if (c == '\\') {
					if ((z > i + 1) && ((argLine.charAt(i + 1) == '"') || (argLine.charAt(i + 1) == '\\'))) {
						buf.append(argLine.charAt(i + 1));
						++i;
					} else {
						buf.append("\\");
					}
				} else {
					if (insideQuotes) {
						buf.append(c);
					} else {
						if (Character.isWhitespace(c)) {
							appendToBuffer(resultBuffer, buf);
						} else {
							buf.append(c);
						}
					}
				}
			}
			appendToBuffer(resultBuffer, buf);

		}

		String[] result = new String[resultBuffer.size()];
		return resultBuffer.toArray(result);
	}

	private static void hookTray() {
		
		if (SystemTray.isSupported()) {
			
			SystemTray tray = SystemTray.getSystemTray();
			Image image;
			if(iconImage == null) {
				image = Toolkit.getDefaultToolkit().getImage(Start.class.getResource("/runwar/icon.png"));
			} else {
				image = Toolkit.getDefaultToolkit().getImage(iconImage);
			}
			MouseListener mouseListener = new MouseListener() {
				public void mouseClicked(MouseEvent e) {}
				public void mouseEntered(MouseEvent e) {}
				public void mouseExited(MouseEvent e) {}
				public void mousePressed(MouseEvent e) {}
				public void mouseReleased(MouseEvent e) {}
			};
			
			ActionListener exitListener = new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					System.out.println("Exiting...");
					System.exit(0);
				}
			};
			ActionListener openAdminListener = new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					System.out.println("Opening admin...");
					BrowserOpener.openURL("http://127.0.0.1:"+portNumber + "/railo-context/admin/server.cfm");
				}
			};
			ActionListener openUrlListener = new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					System.out.println("Opening browser...");
					BrowserOpener.openURL("http://127.0.0.1:"+portNumber + "/");
				}
			};
			
			PopupMenu popup = new PopupMenu();
			MenuItem item = new MenuItem("Stop Server (" + processName + ")");
			item.addActionListener(exitListener);
			popup.add(item);
			item = new MenuItem("Open Browser");
			item.addActionListener(openUrlListener);
			popup.add(item);
			item = new MenuItem("Open Admin");
			item.addActionListener(openAdminListener);
			popup.add(item);
			
			trayIcon = new TrayIcon(image, processName + " server on " + host + ":" + portNumber + " PID:" + PID, popup);
			
			ActionListener actionListener = new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					trayIcon.displayMessage("Action Event", 
							"An Action Event Has Been Performed!",
							TrayIcon.MessageType.INFO);
				}
			};
			
			trayIcon.setImageAutoSize(true);
			trayIcon.addActionListener(actionListener);
			trayIcon.addMouseListener(mouseListener);
			
			try {
				tray.add(trayIcon);
			} catch (AWTException e) {
				System.err.println("TrayIcon could not be added.");
			}
			
		} else {
			
			//  System Tray is not supported
			
		}
	}
	
}