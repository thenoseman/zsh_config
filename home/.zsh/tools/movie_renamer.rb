#!/usr/bin/env ruby

require "json"
require "time"
require "fileutils"
require "shellwords"

EXTENSION = %w[avi mp4 m4v 3gp mov]
movie_file_paths = Dir.glob("*.{#{EXTENSION.join(",")}}", File::FNM_CASEFOLD)
errors = []

puts "* Found #{movie_file_paths.count} movies"
movie_file_paths.each do |movie_file_path|
  metadata = JSON.parse(`mediainfo --Output=JSON #{Shellwords.escape(movie_file_path)}`)
  track_0 = metadata["media"]["track"][0]
  created_date = track_0["Encoded_Date"] || track_0["Mastered_Date"] || track_0["File_Modified_Date_Local"]

  # Fix date for some AVis
  created_date = created_date.gsub(/(.*?)- (\d)(.*?)/, "\\1-0\\2\\3")

  if created_date
    movie_date = Time.parse(created_date)
    # Fix UTC
    movie_date += 3600 if created_date.include?("UTC")

    target_path = movie_date.strftime("%Y/%Y-%m-%d")
    target_name = movie_date.strftime("%Y_%m_%d_%H_%M_%S") + File.extname(movie_file_path)
    target_final = "#{target_path}/#{target_name}"

    puts "* #{movie_file_path} => #{target_final}"
    FileUtils.mkdir_p target_path
    FileUtils.mv movie_file_path, target_final
  end
rescue => e
  errors << movie_file_path + ": " + e.message
end

puts "ERRORS:"
puts errors.join("\n")
