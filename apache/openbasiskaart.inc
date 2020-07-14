        ServerAdmin webmaster@opengeogroep.nl
        ServerName openbasiskaart.nl
        ServerAlias www.openbasiskaart.nl openbasiskaart.b3p.nl

	Protocols h2 http/1.1

        # MapCache
        MapCacheAlias /mapcache "/mnt/data/mapcache/mapcache.xml"
        <Directory /mnt/data/mapcache/>
                Options +FollowSymLinks
                Require all granted
        </Directory>
        <Location /mapcache/>
                Header set Access-Control-Allow-Origin "*"
		<RequireAll>
			Require all granted
			# Deny vanwege MapProxy bulk requests (2017-04-06)
			Require not ip 78.31.115.30
		</RequireAll>
        </Location>

        # Website
        DocumentRoot /var/www/openbasiskaart/website
        <Directory />
                Options None
                AllowOverride None
        </Directory>
        <Directory /var/www/openbasiskaart/website>
                Options None
                AllowOverride None
                Require all granted
        </Directory>
        
        # MapServer FastCGI
        AddHandler fcgid-script fcgi
        <IfModule mod_fcgid.c>
                FcgidMaxProcessesPerClass 50
        		FcgidBusyTimeout 120                
                FcgidIOTimeout 120                   
                #FcgidMaxRequestsPerProcess 50
                #FcgidMinProcessesPerClass 32
                FcgidInitialEnv PROJ_LIB /usr/share/proj
                #FcgidInitialEnv LD_LIBRARY_PATH "/usr/local/lib:/usr/local/pgsql/lib"
        </IfModule>
        ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
        <Directory "/usr/lib/cgi-bin">
                AllowOverride None
                Options +ExecCGI +FollowSymLinks
                Require all granted
		Header set Access-Control-Allow-Origin "*"
        </Directory>

