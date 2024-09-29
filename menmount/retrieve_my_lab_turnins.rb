#!/usr/bin/env ruby
#----------------------
#File: retrieve_my_lab_turnins.rb
#Version: 1.3
#Date: 02/06/2021
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$version="1.3"
$LOAD_PATH << "."
require 'awesome_print'
require 'aws-sdk-s3'
require 'fileutils'

#----------------------------------INPUTS
lab="Lab1"          #Example: Lab1
#Leave these blank to use your environment variables
semester=""         #Example: SP21 
section=""          #Example: Section851 
uname=""            #Example: jauten 
#----------------------------------

def retrieve_assignment_turn_in(lab,semester="",section="",uname="",course="ITEC427")
    if(semester=="")
        semester = ENV["SEMESTER"]
    end
    if(section=="")
        section = ENV["SECTION"]
    end
    if(uname=="")
        uname = ENV["UNAME"]
    end
    
    bucket = "towson-itec427"

    #Put your results in my bucket so I can grade the lab
    s3 = Aws::S3::Client.new(region: 'us-east-1')
    
    prefix=course+"/"+semester+"/"+section+"/"+lab+"/"+uname.downcase()+"/"

    objectkeys = Array.new
    s3.list_objects({bucket: bucket,prefix: prefix}).contents.each do |item|
      objectkeys.push(item.key)
    end
    
    puts "Retrieving the following objects:"
    puts objectkeys

    storepath="./Assignments/"+lab+"/"
    objectkeys.each do |item|
    
    resp = s3.get_object(
        bucket: bucket,
        key: item)
    
    filename=storepath+item.split('/')[5].strip
    #puts "Path: #{filename}"
    dirname = File.dirname(filename)
    #puts "Directory: #{dirname}"
    unless File.directory?(dirname)
        FileUtils.mkdir_p(dirname)
    end
    #puts "Filename: #{filename}"
    
    file=File.new(filename,"w+")
    #file.binmode
    file.write resp.body.read
    #resp.body.save(path)
    end
    
end



retrieve_assignment_turn_in(lab,semester,section,uname)
