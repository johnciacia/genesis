#!/usr/bin/ruby
require 'yaml'


$config = YAML.load_file('config.yml')
$mysql_username = $config['server']['mysql_username']
$mysql_password = $config['server']['mysql_password']
$wp_user_login = $config['wordpress']['user_login']
$wp_user_password = $config['wordpress']['user_password']
$wp_admin_email = $config['wordpress']['admin_email']

def install_wp(project)

  project_dir = $config['server']['path'].gsub('%{project}', project)
  
  out = `mysql -u #{$mysql_username} -p#{$mysql_password}  -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '#{project}';"`
  if !out.empty?
    puts "Failed: the database '#{project}' alraedy exists"
    return false
  end

  #download the latest stable version of wordpress
  system( 'curl -o /tmp/latest.tar.gz http://wordpress.org/latest.tar.gz --silent' )
  if Dir.glob( '/tmp/latest.tar.gz' ).empty?
    puts 'Failed: curl -o /tmp/latest.tar.gz http://wordpress.org/lates.tar.gz'
    return false
  end

  #create a new project directory
  system( 'mkdir -p ' + project_dir)
  if Dir.glob( project_dir ).empty?
    puts 'Failed: mkdir -p ' + project_dir
    return false
  end

  #unzip wordpress to the project directory
  system( "tar -xzf /tmp/latest.tar.gz -C " + project_dir + " --strip-components=1")
  if Dir.glob( project_dir + '/index.php' ).empty?
    puts "Failed: tar -xzf /tmp/latest.tar.gz -C " + project_dir + " --strip-components=1"
    return false
  end 
  
  #create a mysql database for the new wordpress install
  system( "mysql -u " + $mysql_username + " -p" + $mysql_password + " -e 'CREATE DATABASE " + project + ";'")
  #setup the config file
  system( "sed -e 's/database_name_here/" + project + "/g' " \
          + "-e 's/username_here/" + $mysql_username + "/g' " \
          + "-e 's/password_here/" + $mysql_password + "/g' " \
          + project_dir + "/wp-config-sample.php > " \
          + project_dir + "/wp-config.php")
  #run the wordpress install
  #@todo: make definable in config file
  host = $config['server']['protocol'] + project + '.' + $config['server']['domain']
  out = `curl -d 'weblog_title=#{project}&user_login=#{$wp_user_login}&pass1=#{$wp_user_password}&pass2=#{$wp_user_password}&admin_email=#{$wp_admin_email}&blog_public=0' #{host}/wp-admin/install.php?step=2 --silent`
  puts "WordPress has been installed: #{host}"
end

def delete_project(project)
  project_dir = $config['server']['path'].gsub('%{project}', project)
  system("rm -rf " + project_dir);
  system("mysql -u " + $mysql_username + " -p" + $mysql_password + " -e 'DROP DATABASE " + project + ";'")  
end

def create_host(vhost)
  project_dir = $config['server']['path'].gsub('%{project}', vhost)
  system( "mkdir -p " + project_dir )
  system( "sed -e 's/{VHOST}/" + vhost + "/g' " \
        + "-e 's/{DOMAIN}/" + $config['server']['domain'] + "/g' " \
        + "/etc/apache2/sites-available/default.template > " \
        + "/etc/apache2/sites-available/" + vhost )
  system( "a2ensite " + vhost )  
  system( "service apache2 reload" )
end

def delete_host(vhost)
  project_dir = $config['server']['path'].gsub('%{project}', vhost)
  system( "a2dissite " + vhost )  
  system( "rm -rf " + project_dir )
  system( "rm -rf /etc/apache2/sites-available/" + vhost )
  system( "service apache2 reload" )
end

def init_project(project)
  puts project
end

def install_wp_base_debug

end

print "> "
STDOUT.flush

while ( command = gets.strip ) != 'exit'
  args = command.split( ' ' );
  case args[0]
    when "init"
      case args[1]
        when "host"
          create_host args[2]
        when "project"
          project_dir = $root_dir + args[2] + '/' + $web_root
          print "[" + project_dir + "] "
          STDOUT.flush
          sub = gets.strip
          if(!sub.empty?)
            project_dir = project_dir + sub
          end
          init_project project_dir
      end
    when "install"
      case args[1]
        when "wp"
          install_wp args[2]
        when "wp-base-debug"
          install_wp_base_debug
      end
    when "delete"
      case args[1]
        when "host"
          delete_host args[2]
        when "project"
          delete_project args[2]
      end
    else 
      puts "Unknown command"
  end
  
  print "> "
  STDOUT.flush
end