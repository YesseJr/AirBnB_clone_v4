# Installs and setsup Nginx with puppet
$dirs = [ '/data/', '/data/web_static/',
          '/data/web_static/releases/',
          '/data/web_static/shared/',
          '/data/web_static/releases/test/'
        ]

$hello = "user www-data;
worker_processes 4;
pid /run/nginx.pid;
events {
	worker_connections 768;
	# multi_accept on;
}
http {
 	server {
		listen 80;
		location /hbnb_static {
			alias /data/web_static/current/;
		}
	}
	##
	# Basic Settings
	##
	sendfile on;
	tcp_nopush on;
	tcp_nodelay on;
	keepalive_timeout 65;
	types_hash_max_size 2048;
	# server_tokens off;
	# server_names_hash_bucket_size 64;
	# server_name_in_redirect off;
	include /etc/nginx/mime.types;
	default_type application/octet-stream;
	##
	# Logging Settings
	##
	access_log /var/log/nginx/access.log;
	error_log /var/log/nginx/error.log;
	##
	# Gzip Settings
	##
	gzip on;
	gzip_disable \"msie6\";
	# gzip_vary on;
	# gzip_proxied any;
	# gzip_comp_level 6;
	# gzip_buffers 16 8k;
	# gzip_http_version 1.1;
	##
	# nginx-naxsi config
	##
	# Uncomment it if you installed nginx-naxsi
	##
	#include /etc/nginx/naxsi_core.rules;
	##
	# nginx-passenger config
	##
	# Uncomment it if you installed nginx-passenger
	##
	
	#passenger_root /usr;
	#passenger_ruby /usr/bin/ruby;
	##
	# Virtual Host Configs
	##
	include /etc/nginx/conf.d/*.conf;
	#include /etc/nginx/sites-enabled/*;
}
#mail {
#	# See sample authentication script at:
#	# http://wiki.nginx.org/ImapAuthenticateWithApachePhpScript
# 
#	# auth_http localhost/auth.php;
#	# pop3_capabilities \"TOP\" \"USER\";
#	# imap_capabilities \"IMAP4rev1\" \"UIDPLUS\";
# 
#	server {
#		listen     localhost:110;
#		protocol   pop3;
#		proxy      on;
#	}
# 
#	server {
#		listen     localhost:143;
#		protocol   imap;
#		proxy      on;
#	}
#}"

exec { 'update':
  command => 'sudo apt-get update',
  path    => ['/usr/bin', '/usr/sbin'],
}->
exec { 'install nginx':
  command => 'sudo apt-get install -y nginx',
  path    => ['/usr/bin', '/usr/sbin'],
}->
exec { 'create test folder':
  command => 'sudo mkdir -p /data/web_static/releases/test/',
  path    => ['/usr/bin', '/usr/sbin'],
}->
exec { 'create shared folder':
  command => 'sudo mkdir -p /data/web_static/shared/',
  path    => ['/usr/bin', '/usr/sbin'],
}->
exec { 'create index':
  command => 'echo "Hello world" | sudo tee \
/data/web_static/releases/test/index.html',
  path    => ['/bin/', '/usr/bin', '/usr/sbin'],
}->
exec { 'delete current if exist':
  command => 'sudo rm /data/web_static/current',
  onlyif  => 'test -e /data/web_static/current',
  path    => ['/bin/', '/usr/bin', '/usr/sbin'],
}->
exec { 'make link':
  command => 'sudo ln -s /data/web_static/releases/test/ \
/data/web_static/current',
  path    => ['/bin/', '/usr/bin', '/usr/sbin'],
}->
exec { 'change owners':
  command => 'sudo chown -R ubuntu:ubuntu /data/',
  path    => ['/bin/', '/usr/bin', '/usr/sbin'],
}->
exec { 'delete conf':
  command => 'sudo rm /etc/nginx/nginx.conf',
  path    => ['/bin/', '/usr/bin', '/usr/sbin'],
}->
exec { 'make conf':
  command => "echo \"${hello}\" | sudo tee /etc/nginx/nginx.conf",
  path    => ['/bin/', '/usr/bin', '/usr/sbin'],
}->
exec { 'restart nginx':
  command => 'sudo service nginx restart',
  path    => ['/usr/bin', '/usr/sbin'],
}
