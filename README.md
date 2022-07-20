# civicrmdocker

I could never quite get the existing CiviCRM container to work right so I decided to build from scratch. 
It takes the basic Drupal Container (with PHP 7.4 and MariaDB) then adds all the updates and the latest versions 

This also allows you to add any other modules you want to install on the initial build.

It is a combination of a docker compose file plus a batch script.  The batch script is set for Windows but should work on Linux as well.  You just need to change the EOL settings. 

The Items that need to be edited to your specific needs are:

d9civi.env: 

   MYSQL_ROOT_PASSWORD=MYROOTPASSWORD
   MYSQL_PASSWORD=MYSQLPASSWORD


d9civienv-compose.yml
	The Container Name : 
		Currently : testdrupal
	The Network Name.  If you want to connect to an existing network add it here
		Currently : drupalnetwork
	

d9civi-latest.bat or d9civi-latest.sh (if you have a LinuxHost

	Line 12: 
		docker exec --user www-data testdrupal drush site-install --db-url=mysql://drupal9:MYSQLPASSWORD@drupaldb:3306/drupal9 --account-name=admin --account-pass=MYADMINPASSWORD
	Line 14.  For some reason it is better to change the CiviCRM version to the latest manually composer does not seem to like getting the latest version: 
		docker exec --user www-data testdrupal bash -c "composer config extra.compile-mode all && composer config extra.enable-patching true && composer config minimum-stability dev && composer require civicrm/civicrm-asset-plugin:'~1.1' && composer -W require civicrm/civicrm-{core,packages,drupal-8}:'~5.51.1'" 
		
	Line 29:
		I have Webform and CiviCRM Entity downloaded by default (because those are probably in any CIviCRM installation. I added CodeMirror just to demonstrate how to add extra modules and libraries
	Line 32: 
		This enables the downloaded modules. Be carefule as the name to enable is not always the same as the download name. 

trustedhostsettings.php
	You will need to add the IP Number or the URL of the Docker Container that has the drupal instance.  Or edit the settings.php after the installation is complete. 

		$settings['trusted_host_patterns'] = ['^localhost$','192.168.0.196',];


If you don't like the name of the container as "testdrupal" you will need to change that in the batch file as well.

I would  NOT use this for production with a lot more testing, but it works well to create a development environment.


 