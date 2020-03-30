#
# Configuration for Pry
#
Pry.config.editor = "mvim -f"
Pry.config.pager = false

Pry.config.prompt_name = File.basename(Dir.pwd)
Pry.config.prompt = Pry::Prompt.new(
  "custom",
  "custom",
  [proc { |obj, nest_level| "🛠 #{RUBY_VERSION} (#{obj.class}):#{nest_level} > " },
   proc { |obj, nest_level| "🛠 #{RUBY_VERSION} (#{obj}):#{nest_level} * " }]
)

if defined?(Rails) && Rails.env && defined?(Rails::ConsoleMethods)
  extend Rails::ConsoleMethods
end

Pry.config.ls.instance_var_color = :bright_blue

# For pry-debugger
Pry.commands.alias_command "c", "continue"
Pry.commands.alias_command "s", "step"
Pry.commands.alias_command "n", "next"
Pry.commands.alias_command "f", "finish"

Pry.commands.alias_command "@", "whereami"

Pry::Commands.block_command "trace", "shows #caller without the framework files" do
  output.puts Pry::ColorPrinter.pp(caller.select { |s| s =~ /\/platform/ })
end
