[settings]
mode=production
appname=${distro.name}
appreloadkey=appreload
installed=0
[production]
title=${distro.name}
filedir=
filestore=fileDir
filestoreaccessinfo=
assetdir=
assetpath=
plugindir=
usefilemode=true
defaultfilemode=775
mapdir=mura
webrootmap=muraWRM
datasource=${distro.name}
dbtype=h2
dbusername=${dsn.username}
dbpassword=${dsn.password}
context=
stub=
admindomain=
adminemail=admin@localhost.com
mailserverip=
mailserversmtpport=25
mailserverpopport=110
sendfrommailserverusername=true
mailserverusername=admin@localhost.com
mailserverpassword=
mailservertls=false
mailserverssl=false
usedefaultsmtpserver=1
adminssl=0
logevents=0
debuggingenabled=true
port=${server.port.http}
sessionhistory=1
sharableremotesessions=1
uselegacysessions=1
dashboard=true
locale=Server
ping=0
enablemuratag=true
proxyuser=
proxypassword=
proxyserver=
proxyport=80
sortpermission=editor
imageinterpolation=highestQuality
productiondatasource=
productionassetpath=
productionwebroot=
productionfiledir=
productionassetdir=
clusterlist=
siteidinurls=0
indexfileinurls=1
strictextendeddata=1
loginstrikes=4
tempdir=
purgedrafts=true
confirmsaveasdraft=true
notifywithversionlink=true
autoresetpasswords=false
sourceimagescale=3000
sourceimagescaleby=x
fmshowsitefiles=1
fmshowapplicationroot=1
editablecomments=0
scriptprotect=true
strongpasswords=0
