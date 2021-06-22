#!/usr/bin/ruby
require 'insert_from_file'
require 'string_in_file'
require 'gemfile_entry'
require 'replace_quotes'
require 'remove_double_blank'
require 'line_containing'

puts 'Adding RuboCop to the Gemfile'
InsertFromFile.add_end('mod-02-01-Gemfile.txt', 'Gemfile')
puts 'bundle install --quiet'
system('bundle install --quiet')
StringInFile.replace("gem 'rubocop'", GemfileEntry.active('rubocop'),'Gemfile')
puts 'bundle install --quiet'
system('bundle install --quiet')

puts 'bundle install --quiet'
system('bundle install --quiet')
