    ServerAdmin webmaster@opengeogroep.nl
    ServerName v3.openbasiskaart.nl
    #ServerAlias www.openbasiskaart.nl openbasiskaart.b3p.nl

    Protocols h2 http/1.1

    # goaccess log format: %h %^[%d:%t %^] "%r" %s %b %D "%M" "%R" "%u"
    LogFormat "%h %l %u %t \"%r\" %>s %b %D \"%{Content-Type}o\" \"%{Referer}i\" \"%{User-agent}i\"" goaccess

    # MapServer FastCGI
    AddHandler fcgid-script fcgi
    <IfModule mod_fcgid.c>
        FcgidMaxProcessesPerClass 50
        FcgidBusyTimeout 120
        FcgidIOTimeout 120
        FcgidInitialEnv MAPSERVER_CONFIG_FILE /opt/openbasiskaart/mapserver.conf
    </IfModule>
    ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
    <Directory "/usr/lib/cgi-bin">
        AllowOverride None
        Options +ExecCGI +FollowSymLinks
        Require all granted
        Header set Access-Control-Allow-Origin "*"
    </Directory>

    # MapCache
    MapCacheAlias /mapcache "/opt/openbasiskaart/mapcache/mapcache.xml"
    <Directory /var/opt/mapcache/>
        Options +FollowSymLinks
        Require all granted
    </Directory>
    <Location /mapcache/>
        Header set Access-Control-Allow-Origin "*"
        <RequireAll>
            Require all granted
            # Voor handmatige IP blocks
            #Require not ip x.x.x.x
        </RequireAll>
    </Location>
    #<LocationMatch ^/mapcache/demo/>
    #    Header set Content-Security-Policy upgrade-insecure-requests
    #</LocationMatch>

    # Website
    DocumentRoot /opt/openbasiskaart/website
    <Directory />
        Options None
        AllowOverride None
    </Directory>
    <Directory /opt/openbasiskaart/website>
        Options None
        AllowOverride None
        Require all granted
    </Directory>
