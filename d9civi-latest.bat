docker-compose -f d9civienv-compose.yml --env-file d9civi.env up -d
docker exec testdrupal apt-get update
docker exec testdrupal apt-get -y install libicu-dev nano unzip libzip-dev git wget default-mysql-client
docker exec testdrupal docker-php-ext-install intl mysqli zip
docker exec testdrupal pecl install apcu uploadprogress
docker exec testdrupal mkdir /opt/drupal/web/sites/default/files
docker exec testdrupal chown -R www-data:www-data /opt/drupal/
docker exec testdrupal chown -R www-data:www-data /var/www/  
docker exec testdrupal chmod 755 /opt/drupal/web/sites/default/files
docker cp drupal.ini testdrupal:/usr/local/etc/php/conf.d/drupal.ini
docker exec --user www-data testdrupal bash -c "composer -W require drush/drush:^10"
docker exec --user www-data testdrupal drush site-install --db-url=mysql://drupal9:MYSQLPASSWORD@drupaldb:3306/drupal9 --account-name=admin --account-pass=MYADMINPASSWORD
docker exec --user www-data testdrupal drush cr 
docker exec --user www-data testdrupal bash -c "composer config extra.compile-mode all && composer config extra.enable-patching true && composer config minimum-stability dev && composer config --no-plugins allow-plugins.civicrm/civicrm-asset-plugin true && composer config --no-plugins allow-plugins.cweagans/composer-patches true && composer config --no-plugins allow-plugins.civicrm/composer-downloads-plugin true && composer config --no-plugins allow-plugins.civicrm/composer-compile-plugin true && composer require civicrm/civicrm-asset-plugin:'~1.1' && composer -W require civicrm/civicrm-{core,packages,drupal-8}:'~5.51.1'"
docker exec --user www-data testdrupal composer -W update 
docker exec --user www-data testdrupal chmod 777 /opt/drupal/web/sites/default
docker cp trustedhostsettings.php testdrupal:/opt/drupal/web/sites/default/trustedhostsettings.php
docker exec testdrupal chown www-data:www-data /opt/drupal/web/sites/default/trustedhostsettings.php
docker exec --user www-data testdrupal bash -c "cat /opt/drupal/web/sites/default/settings.php /opt/drupal/web/sites/default/trustedhostsettings.php > /opt/drupal/web/sites/default/newsettings.php"
docker exec --user www-data testdrupal rm /opt/drupal/web/sites/default/settings.php
docker exec --user www-data testdrupal mv /opt/drupal/web/sites/default/newsettings.php /opt/drupal/web/sites/default/settings.php
docker restart testdrupal
docker exec --user www-data testdrupal drush cr
docker exec testdrupal curl -LsS https://download.civicrm.org/cv/cv.phar -o /usr/local/bin/cv
docker exec testdrupal chmod +x /usr/local/bin/cv
docker exec --user www-data testdrupal drush en civicrm -l http://localhost
docker exec --user www-data testdrupal chmod 444 /opt/drupal/web/sites/default/civicrm.settings.php
docker exec --user www-data testdrupal drush cr
docker exec --user www-data testdrupal composer -W require drupal/ckeditor_codemirror drupal/civicrm_entity drupal/webform drupal/webform_civicrm
docker exec --user www-data testdrupal wget "https://github.com/w8tcha/CKEditor-CodeMirror-Plugin/releases/download/v1.18.5/CKEditor-CodeMirror-Plugin.zip"
docker exec --user www-data testdrupal unzip -o CKEditor-CodeMirror-Plugin.zip -d ./web/libraries/ckeditor.codemirror
docker exec --user www-data testdrupal drush -y en civicrm_entity webform webform_civicrm ckeditor_codemirror
docker exec --user www-data testdrupal drush webform:libraries:download
docker exec --user www-data testdrupal drush updatedb -l http://localhost
docker exec --user www-data testdrupal drush cr