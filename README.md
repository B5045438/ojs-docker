ojs-docker
=================

Deploys Open Journal Systems via Docker. Pretty barebones right now.


Usage
-----

To create the image `axfelix/ojs-docker`, execute the following command on the ojs-docker folder:

	docker build -t axfelix/ojs-docker .



Running your LAMP docker image
------------------------------

Start your image by binding a port to the container's port 80:

	docker run -d -p 8008:80 axfelix/ojs-docker

Test your deployment by going to `localhost:8008` in a web browser.




Connecting to the bundled MySQL server from within the container
----------------------------------------------------------------

The bundled MySQL server has a `root` user with no password for local connections.
Simply connect from your PHP code with this user:

	<?php
	$mysql = new mysqli("localhost", "root");
	echo "MySQL Server info: ".$mysql->host_info;
	?>



Setting a specific password for the MySQL server admin account
--------------------------------------------------------------

If you want to use a preset password instead of a random generated one, you can
set the environment variable `MYSQL_PASS` to your specific password when running the container:

	docker run -d -p 80:80 -e MYSQL_PASS="mypass" tutum/lamp



Disabling .htaccess
--------------------

`.htaccess` is enabled by default. To disable `.htaccess`, you can remove the following contents from `Dockerfile`

	# config to enable .htaccess
    ADD apache_default /etc/apache2/sites-available/000-default.conf
    RUN a2enmod rewrite


**originally by http://www.tutum.co, with thanks**
