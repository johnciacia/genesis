#!/usr/bin/ruby


if !Dir.glob( 'config.rb' ).empty?
  require 'config.rb'
else
  $mysql_username = "root"
  $mysql_password = "root"
  $project_dir = "/var/www/"


  $fqdn = "http://localhost/"
  $wp_user_login = "admin"
  $wp_user_password = "changeme"
  $wp_admin_email = "admin@example.com"
end


def init_project(project) 
  
end

def create_project(project)   
  
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
  system( 'mkdir ' + $project_dir + project)
  if Dir.glob( $project_dir + project ).empty?
    puts 'Failed: mkdir ' + $project_dir + project
    return false
  end

  #unzip wordpress to the project directory
  system( "tar -xzf /tmp/latest.tar.gz -C " + $project_dir + project + " --strip-components=1")
  if Dir.glob( $project_dir + project + '/index.php' ).empty?
    puts "Failed: tar -xzf /tmp/latest.tar.gz -C " + $project_dir + project + " --strip-components=1"
    return false
  end 
  
  #create a mysql database for the new wordpress install
  system( "mysql -u " + $mysql_username + " -p" + $mysql_password + " -e 'CREATE DATABASE " + project + ";'")
  #setup the config file
  system( "sed -e 's/database_name_here/" + project + "/g' " \
          + "-e 's/username_here/" + $mysql_username + "/g' " \
          + "-e 's/password_here/" + $mysql_password + "/g' " \
          + $project_dir + project + "/wp-config-sample.php > " \
          + $project_dir + project + "/wp-config.php")
  #run the wordpress install
  out = `curl -d 'weblog_title=#{project}&user_login=#{$wp_user_login}&pass1=#{$wp_user_password}&pass2=#{$wp_user_password}&admin_email=#{$wp_admin_email}&blog_public=0' #{$fqdn}#{project}/wp-admin/install.php?step=2 --silent`

  puts "WordPress has been installed: #{$fqdn}#{project}"

end

def delete_project(project)
  system("rm -rf " + $project_dir + project);
  system("mysql -u " + $mysql_username + " -p" + $mysql_password + " -e 'DROP DATABASE " + project + ";'")  
end



print "> "
STDOUT.flush

while ( command = gets.strip ) != 'exit'
  args = command.split( ' ' );
  case args[0]
    when "create"
      create_project args[1]
    when "delete"
      delete_project args[1]
    else 
      puts "Unknown command"
  end
  
  print "> "
  STDOUT.flush
end