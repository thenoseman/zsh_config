# -*- encoding : utf-8 -*-
#  gem install pry pry-doc debugger bond wirb awesome_print git-up

# Break out of the Bundler jail
# from https://github.com/ConradIrwin/pry-debundle/blob/master/lib/pry-debundle.rb
if defined? Bundler
  Gem.post_reset_hooks.reject! { |hook| hook.source_location.first =~ %r{/bundler/} }
  Gem::Specification.reset
  load 'rubygems/custom_require.rb'
end

require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require 'ap' rescue nil
require 'irb/completion'
require 'irb/ext/save-history'
require 'wirb'
require 'bond'

# https://github.com/cldwalker/bond
Bond.start

# https://github.com/janlelis/wirb/
Wirb.start

# keep history
IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"

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

# show complete IRB history
def history
  puts Readline::HISTORY.entries.split("exit").last[0..-2].join("\n")
end

# Use Pry everywhere
begin
  require 'pry'
  Pry.start
  exit
rescue
  warn "You really should \"gem install pry pry-doc --no-ri --no-rdoc\" into your global system gemdir"
end
