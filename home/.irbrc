require "irb/completion"

unless RUBY_VERSION.start_with?("3.3")
  require "irb/ext/save-history"
  
  # Use Pry everywhere
  begin
    require "pry"
    I18n.locale = :de if defined? I18n
    IRB.conf[:IRB_NAME] = "pry"
    Pry.start
    Kernel.exit
  rescue StandardError
    warn "You really should \"gem install pry pry-doc --no-ri --no-rdoc\" into your global system gemdir"
  end
end

# keep history
IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_FILE] = "#{ENV["HOME"]}/.irb_history_file"

# Log SQL to STDOUT if in Rails
if ENV.include?("RAILS_ENV") && !Object.const_defined?("RAILS_DEFAULT_LOGGER")
  require "logger"
  RAILS_DEFAULT_LOGGER = Logger.new(STDOUT)
end

def log_activeresource
  ActiveResource::Base.logger = ActiveRecord::Base.logger
end

def sqllogoff
  ActiveRecord::Base.logger = nil
end

