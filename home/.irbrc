# https://github.com/carlhuda/bundler/issues/183#issuecomment-1149953
# Also add all gems from the global gemset to the loadpath
if defined?(::Bundler)
  global_gemset = ENV['GEM_PATH'].split(':').grep(/@global$/).first
  if global_gemset
    all_global_gem_paths = Dir.glob("#{global_gemset}/gems/*")
    all_global_gem_paths.each do |p|
      gem_path = "#{p}/lib"
      $LOAD_PATH << gem_path
    end
  end
end

require 'rubygems'

require 'ap' rescue nil

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

# show compplete IRB history
def history
  puts Readline::HISTORY.entries.split("exit").last[0..-2].join("\n")
end

# Use Pry everywhere
begin
  require 'pry'
  Pry.start
  exit
rescue
  warn "You really should \"rvm gemset use global && gem install pry pry-doc --no-ri --no-rdoc\""
end
