#!/usr/bin/env ruby
#----------------------
#File: create_transcribe_job.rb
#Version: 1.3
#Date: 05/15/2020
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'awesome_print'
require 'aws-sdk-transcribeservice'

require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab5"

$f1_version="1.3"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS
uri = "https://s3.amazonaws.com/menmountbucket/polly_text.mp3" #For example: https://s3.amazonaws.com/tuitec427fa18/polly_text.mp3
#----------------------------------

client = Aws::TranscribeService::Client.new(region: 'us-east-1')

puts "Creating new transcription job!"
MyLog.log.info "Creating new transcription job!"

 resp = client.start_transcription_job({
   transcription_job_name: "Transcribe", # required
   language_code: "en-US", # required, accepts en-US, es-US
     media_format: "mp3", # required, accepts mp3, mp4, wav, flac
   media: { # required
     media_file_uri: uri, 
   },
   settings: {
     show_speaker_labels: false,
   },
 })

print "Response: "
ap resp
MyLog.log.info "Response:  #{resp}"
 
#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)