# -*- encoding : utf-8 -*-
#  gem install pry pry-doc debugger bond wirb awesome_print git-up
#

module Debundle
  VERSION = '0.8.d'
end

class << Debundle
  # Break out of the Bundler jail.
  def debundle!
    return unless defined?(Bundler)
    if Gem.post_reset_hooks.reject!{ |hook| hook.source_location.first =~ %r{/bundler/} }
      Bundler.preserve_gem_path
      Gem.clear_paths
      Gem::Specification.reset
      remove_bundler_monkeypatches
    end
  rescue => e
    puts "Debundling failed: #{e.message}"
    puts "When reporting bugs to https://github.com/ConradIrwin/pry-debundle, please include:"
    puts "* gem version: #{Gem::VERSION rescue 'undefined'}"
    puts "* bundler version: #{Bundler::VERSION rescue 'undefined'}"
    puts "* ruby version: #{RUBY_VERSION rescue 'undefined'}"
    puts "* ruby engine: #{RUBY_ENGINE rescue 'undefined'}"
  end

  private

  def rubygems_18_or_better?
    defined?(Gem.post_reset_hooks)
  end

  def rubygems_20_or_better?
    Gem::VERSION.to_i >= 2
  end

  # Ugh, this stuff is quite vile.
  def remove_bundler_monkeypatches
    if rubygems_20_or_better?
      load 'rubygems/core_ext/kernel_require.rb'
    else
      load 'rubygems/custom_require.rb'
    end

    if rubygems_18_or_better?
      Kernel.module_eval do
        def gem(gem_name, *requirements) # :doc:
          skip_list = (ENV['GEM_SKIP'] || "").split(/:/)
          raise Gem::LoadError, "skipping #{gem_name}" if skip_list.include? gem_name
          spec = Gem::Dependency.new(gem_name, *requirements).to_spec
          spec.activate if spec
        end
      end
    else
      Kernel.module_eval do
        def gem(gem_name, *requirements) # :doc:
          skip_list = (ENV['GEM_SKIP'] || "").split(/:/)
          raise Gem::LoadError, "skipping #{gem_name}" if skip_list.include? gem_name
          Gem.activate(gem_name, *requirements)
        end
      end
    end
  end
end

Debundle.debundle!

### END debundle.rb ###
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

# Use Pry everywhere
begin
  require 'pry'
  I18n.locale = :de if defined? I18n
  Pry.config.history.should_save = true
  Pry.config.history.file = "~/.irb_history"
  IRB.conf[:IRB_NAME]="pry"
  Pry.start
  Kernel.exit
rescue StandardError
  warn "You really should \"gem install pry pry-doc --no-ri --no-rdoc\" into your global system gemdir"
end
