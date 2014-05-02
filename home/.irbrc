# -*- encoding : utf-8 -*-
#  gem install pry pry-doc debugger bond wirb awesome_print git-up

require 'irb/completion'
require 'irb/ext/save-history'

begin
  require 'wirb'
  require 'bond'
  Bond.start
  Wirb.start
rescue LoadError
end

# keep history
IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history_file"

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
  I18n.locale = :de if defined? I18n
  Pry.config.history.should_save = true
  Pry.config.history.file = "~/.irb_history"
  IRB.conf[:IRB_NAME]="pry"
  Pry.start
  exit
rescue
  warn "You really should \"gem install pry pry-doc --no-ri --no-rdoc\" into your global system gemdir"
end
