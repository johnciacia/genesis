#!/usr/bin/ruby

pwd = `pwd`

#get the plugin name
printf("Plugin Name: ")
STDOUT.flush
plugin = gets.strip

#get the directory
printf("[#{pwd.strip}] ")
STDOUT.flush
dir = gets.strip
if dir.empty?
	dir = pwd.strip
end

dir = dir + '/' + plugin

system("mkdir -p #{dir}")

code = "<?php
/*
Plugin Name: #{plugin}
Plugin URI: 
Description: 
Author: 
Version: 0.1-alpha
Author URI: 
Text Domain: 
Domain Path: 
Network: 

Copyright YEAR  PLUGIN_AUTHOR_NAME  (email : PLUGIN AUTHOR EMAIL)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License, version 2, as 
published by the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

" + plugin.capitalize + "::initialize
class " + plugin.capitalize + " {

	public static function initialize() {
		
	}
}
?>"

readme = "=== #{plugin} ===
Contributors: 
Donate link: 
Tags: 
Requires at least:
Tested up to:
Stable tag:

Here is a short description of the plugin.  This should be no more than 150 characters.  No markup here.

== Description ==

This is the long description.  No limit, and you can use Markdown (as well as in the following sections).

For backwards compatibility, if this section is missing, the full length of the short description will be used, and
Markdown parsed."

File.open("#{dir}/#{plugin}.php", 'w') {|f| f.write(code) }
File.open("#{dir}/readme.txt", 'w') {|f| f.write(readme) }

