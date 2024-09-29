#!/usr/bin/env ruby
#----------------------
#File: assignment_turn_in.rb
#Version: 1.3
#Date: 04/16/2021
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$ati_version="1.3"
require 'aws-sdk-s3'
require 'awesome_print'

def assignment_turn_in(file,lab,objname="",course="ITEC427",semester="",section="",uname="")
    #Set values based on environment variables if they have not been set yet
    if(objname=="")
        objname = (File.basename($0,".rb")+".log")
    end
    if(semester=="")
        semester = ENV["SEMESTER"]
    end
    if(section=="")
        section = ENV["SECTION"]
    end
    if(uname=="")
        uname = ENV["UNAME"]
    end

    #Put your results in my bucket so I can grade the lab
    s3 = Aws::S3::Client.new(region: 'us-east-1')
    path= course+"/"+semester+"/"+section+"/"+lab+"/"+uname.downcase()+"/"
    objectid= path + objname
    bucket="towson-itec427"
    if(File.extname(file)==".log")
        open(file, 'a') { |f|
            f.puts "#{objname} submitted using version #{$ati_version} of #{File.basename(__FILE__)}"
        }
    end
    puts "#{objname} submitted using version #{$ati_version} of #{File.basename(__FILE__)}"
    puts "********************************************************************"
    puts "Writing "+File.basename(file) + " to "+path+" path in "+bucket+" bucket as "+objname
    puts "********************************************************************"
    resp=s3.put_object({
        body: file, 
        bucket: bucket, 
        key: objectid,
        acl: "bucket-owner-full-control",
    })    
    ap resp
    
    File.delete(file) if File.exist?(file)
end