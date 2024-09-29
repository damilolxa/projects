#!/usr/bin/env ruby
#----------------------
#File: get_transcribe_job.rb
#Version: 1.3
#Date: 10/05/2020
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'awesome_print'
require 'awesome_print'
require 'aws-sdk-transcribeservice'
require 'net/http'
require 'uri'
require 'json'

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

complete=false
while complete==false
    #Retrieve transcribe job
    resp = client.get_transcription_job({
        transcription_job_name: "Transcribe", # required
    })
    if(resp.transcription_job.transcription_job_status=="FAILED")
       puts "The Transcription job failed! Look at the code for creating it..." 
       exit 1
    end
    ap resp
    puts resp.transcription_job.transcription_job_status
    MyLog.log.info resp.transcription_job.transcription_job_status 
    #Make the code wait 2 second before polling the status
    sleep(2)
    puts "Polling the status of job..."
    MyLog.log.info "Polling the status of job..."
    complete=(resp.transcription_job.transcription_job_status=="COMPLETED")
end

#Get the JSON result from the returned URI
uri = URI.parse(resp.transcription_job.transcript.transcript_file_uri)
response = Net::HTTP.get_response uri
json_response = JSON.load(response.body)
results=json_response['results']
transcripts=results['transcripts']
transcript=transcripts[0]['transcript']
puts transcript
MyLog.log.info "Transcript: "+transcript

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)