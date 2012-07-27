<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Bootswatch: Spacelab</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">

    <!-- Le HTML5 shim, for IE6-8 support of HTML elements -->
    <!--[if lt IE 9]>
      <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->

    <!-- Le styles -->
	<cfoutput>
	    <link href="#resp.encodeURL('/assets/css/bootstrap.min.css')#" rel="stylesheet">
	    <link href="#resp.encodeURL('/assets/css/bootstrap-responsive.css')#" rel="stylesheet">
	</cfoutput>

  </head>

  <body class="preview" data-spy="scroll" data-target=".subnav" data-offset="50">

<!-- Navbar
================================================== -->
<section id="navbar">
  <div class="navbar">
    <div class="navbar-inner">
      <div class="container" style="width: auto;">
        <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
        </a>
        <a class="brand" href="#">Project name</a>
        <div class="nav-collapse">
          <ul class="nav">
			<cfoutput>
            	<li class="active"><a href="#resp.encodeURL('index.cfm?action=distro.default')#">Home</a></li>
				<li>
					<a href="#resp.encodeURL('index.cfm?action=distro.list')#" title="View the list of distros">List</a>
				</li>
				<li>
					<a href="#resp.encodeURL('index.cfm?action=distro.form')#" title="Fill out form to add new distro">Add New</a>
				</li>
				<li>
					<a href="#resp.encodeURL("index.cfm?action=distro.loadpersisted")#" title="Loads any saved distros">
						Load Persisted Distros
					</a>
				</li>
				<li>
					<a href="#resp.encodeURL('index.cfm?action=distro.persist')#" title="Saves distros to disk">
						Persist All Distros
					</a>
				</li>
				<li>
					<a href="#resp.encodeURL('/index.cfm??action=distro.default&init=true')#" title="Resets framework cache">
						Reload App
					</a>
				</li>
			</cfoutput>
            <li><a href="#">Link</a></li>
            <li class="dropdown">
              <a href="#" class="dropdown-toggle" data-toggle="dropdown">Dropdown <b class="caret"></b></a>
              <ul class="dropdown-menu">
                <li><a href="#">Action</a></li>
                <li><a href="#">Another action</a></li>
                <li><a href="#">Something else here</a></li>
                <li class="divider"></li>
                <li><a href="#">Separated link</a></li>
              </ul>
            </li>
          </ul>
          <form class="navbar-search pull-left" action="">
            <input type="text" class="search-query span2" placeholder="Search">
          </form>
          <ul class="nav pull-right">
            <li><a href="#">Link</a></li>
            <li class="divider-vertical"></li>
            <li class="dropdown">
              <a href="#" class="dropdown-toggle" data-toggle="dropdown">Dropdown <b class="caret"></b></a>
              <ul class="dropdown-menu">
                <li><a href="#">Action</a></li>
                <li><a href="#">Another action</a></li>
                <li><a href="#">Something else here</a></li>
                <li class="divider"></li>
                <li><a href="#">Separated link</a></li>
              </ul>
            </li>
          </ul>
        </div><!-- /.nav-collapse -->
      </div>
    </div><!-- /navbar-inner -->
  </div><!-- /navbar -->

</section>

	<div class="container">
		<cfoutput>
			#body#
		</cfoutput>
	   <!-- Footer
	     ================================================== -->
	     <footer class="footer">
	       <p class="pull-right"><a href="#">Back to top</a></p>
	     </footer>
	</div><!-- /container -->
<!---


    <!-- Le javascript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="../assets/js/jquery.js"></script>
    <script src="../assets/js/bootstrap-dropdown.js"></script>
    <script src="../assets/js/bootstrap-scrollspy.js"></script>
    <script src="../assets/js/bootstrap-collapse.js"></script>
		<script src="../assets/js/bootstrap-tooltip.js"></script>
    <script src="../js/application.js"></script>
    <script src="../js/bootswatch.js"></script>

 --->
 </body>
</html>