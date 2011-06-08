require 'rubygems'
require 'wirble'
require 'ap'

# Colorize IRB
Wirble.init
Wirble.colorize

# Log SQL to STDOUT if in Rails
if ENV.include?('RAILS_ENV') && !Object.const_defined?('RAILS_DEFAULT_LOGGER')
  require 'logger'
  RAILS_DEFAULT_LOGGER = Logger.new(STDOUT)
end

def log_activeresource
  ActiveResource::Base.logger = ActiveRecord::Base.logger
end

def sqllogoff
  ActiveRecord::Base.logger = nil
end

def history
  puts Readline::HISTORY.entries.split("exit").last[0..-2].join("\n")
end
