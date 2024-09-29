#!/usr/bin/env ruby
#----------------------
#File: poly_synth.rb
#Version: 1.5
#Date: 04/16/2021
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'aws-sdk-polly'

require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab4"

$f1_version="1.5"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS
voiceID='Vicki'
filename="polly_text.txt"   #"polly_text.txt"
#----------------------------------

begin
  
  MyLog.log.info "Filename:  #{filename}"
  # Open file and get the contents as a string
  if File.exist?(filename)
    contents = IO.read(filename)
    MyLog.log.info "File contents:  #{contents}"
  else
    puts 'No such file: ' + filename
    exit 1
  end

  # Create an Amazon Polly client using
  # credentials from the shared credentials file ~/.aws/credentials
  # and the configuration (region) from the shared configuration file ~/.aws/config
  polly = Aws::Polly::Client.new(region: 'us-east-1')

  resp = polly.synthesize_speech({
    output_format: "mp3",
    text: contents,
    voice_id: voiceID,
  })
  
  # Save output
  # Get just the file name
  #  abc/xyz.txt -> xyx.txt
  name = File.basename(filename)

  # Split up name so we get just the xyz part
  parts = name.split('.')
  first_part = parts[0]
  mp3_file = first_part + '.mp3'
  
  #Write the mp3 to a file
  IO.copy_stream(resp.audio_stream, mp3_file)

  puts 'Wrote MP3 content to local file : ' + mp3_file
  MyLog.log.info 'Wrote MP3 content to local file : ' + mp3_file
  
  #Write the mp3 to a second file
  mp3_file_turnin = first_part+'_turnin.mp3'
  IO.copy_stream(mp3_file, mp3_file_turnin)
  #IO.copy_stream(resp.audio_stream, mp3_file_turnin)
  
  puts 'Wrote MP3 content to file for turnin: ' + mp3_file_turnin
  MyLog.log.info 'Wrote MP3 content to file for turnin: ' + mp3_file_turnin
rescue StandardError => ex
  puts 'Got error:'
  puts 'Error message:'
  puts ex.message
end

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)

#Upload MP3 File
file= File.new(mp3_file_turnin)
assignment_turn_in(file,lab,mp3_file)


