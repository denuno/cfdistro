<Directory "@httpd.host.documentroot@">
  Options None
	AllowOverride None
	Allow from all
	Order deny,allow
</Directory>

ServerAdmin @httpd.host.serveradmin@
DocumentRoot @httpd.host.documentroot@

DirectoryIndex @httpd.host.directoryindex@
@httpd.host.404@
@httpd.host.403@
@httpd.host.503@
@httpd.host.500@

RewriteEngine on
Include @httpd.host.dir@/security.rewrites.conf
RewriteRule   ^\@war.contextpath@\/(.+)	/$1 [R,QSA,L]
RewriteRule   ^\/(.+)\.cfm(.+)?	http://@server.host@:@server.port.http@@war.contextpath@/$1.cfm$2 [P,QSA,L]

#RewriteRule ^(.+\.cf[cm])$	http://@server.host@:@server.port.http@@war.contextpath@/$1 [P,QSA,L]
#RewriteCond %{DOCUMENT_ROOT}%{REQUEST_FILENAME} !-f
#RewriteRule   ^\/(.+)?	http://@server.host@:@server.port.http@@war.contextpath@/$1 [P,QSA,L]
