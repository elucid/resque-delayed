require 'resque'
require 'uuidtools'

%w(resque-delayed resque worker).each do |component|
  require File.join(File.dirname(__FILE__), 'resque-delayed', component)
end
