# -*- encoding : utf-8 -*-
#
# Configuration for Pry
#
Pry.config.editor = "mvim -f"

Pry.prompt = [proc { |obj, nest_level| "#{RUBY_VERSION} (#{obj}):#{nest_level} > " }, proc { |obj, nest_level| "#{RUBY_VERSION} (#{obj}):#{nest_level} * " }]

if defined?(Rails) && Rails.env
  extend Rails::ConsoleMethods
end
