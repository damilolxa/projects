#!/usr/bin/env ruby
#----------------------
#File: translate.rb
#Version: 1.2
#Date: 02/02/2020
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'optparse'
require 'aws-sdk-translate'

require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab5"

$f1_version="1.2"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

options = {}
begin
  # Get the arguements from the command line
  OptionParser.new do |opt|
    opt.on('--file FILE') { |o| options[:file] = o }
    opt.on('--from_lang FROMLANGUAGE') { |o| options[:from_lang] = o }
    opt.on('--to_lang TOLANGUAGE') { |o| options[:to_lang] = o }
  end.parse!
  
  if(options[:file]==nil||options[:from_lang]==nil||options[:to_lang]==nil)
    puts "You are missing a required arguement!"
    exit 1
  end
  
  filename = options[:file]
  from_lang=options[:from_lang]
  to_lang=options[:to_lang]
  
  puts "Translating Filename: #{filename}"
  puts "From Language: #{from_lang}"
  puts "To Language: #{to_lang}"  
  MyLog.log.info "Translating Filename: #{filename}"
  MyLog.log.info "From Language: #{from_lang}"
  MyLog.log.info "To Language: #{to_lang}"
  # Open file and get the contents as a string
  if File.exist?(filename)
    contents = IO.read(filename)
   # MyLog.log.info "Contents: #{contents}"  
  else
    puts 'No such file: ' + filename
    exit 1
  end

  client = Aws::Translate::Client.new
  
  resp = client.translate_text({
    text: contents, # required
    source_language_code: from_lang, # required
    target_language_code: to_lang, # required
  })
  
  if(from_lang=="auto")
    puts "The Unknown Language Code Determination: #{resp.source_language_code}"
    MyLog.log.info "The Unknown Language Code Determination: #{resp.source_language_code}"
  end
  
  puts "Original Text: #{contents}"
  MyLog.log.info "Original Text: #{contents}"
  
  puts "Translation: #{resp.translated_text}"
  MyLog.log.info "Translation: #{resp.translated_text}"
  
rescue StandardError => ex
  puts 'Got error:'
  puts 'Error message:'
  puts ex.message
end

#Upload work for credit
file= File.new("mylab.log")
if(from_lang=="en")
  objname="translate_en.log"
elsif (from_lang=="es")
  objname="translate_es.log"
else
  objname="translate_un.log"
end

assignment_turn_in(file,lab,objname)
