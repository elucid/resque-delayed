#!/usr/bin/env rake

begin
  require 'bundler/setup'
rescue LoadError => error
  abort error.message
end

require "bundler/gem_tasks"
require "resque-delayed/tasks"

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new
