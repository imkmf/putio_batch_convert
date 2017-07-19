require 'dotenv'
Dotenv.load

require 'httparty'
require 'json'
require 'ostruct'

module PutIO
  class Folder < OpenStruct
  end

  class File < OpenStruct
  end

  class MP4Status < OpenStruct
  end

  class Client
    include HTTParty
    base_uri 'https://put.io/v2'
    headers 'Accept' => 'application/json'

    def initialize(key)
      @options = { query: { oauth_token: key } }
    end

    def get(url)
      # puts "GET: #{url}"
      self.class.get(url, @options)
    end

    def post(url)
      # puts "POST: #{url}"
      self.class.post(url, @options)
    end

    def files(parent_id = 0)
      get("/files/list?parent_id=#{parent_id}")
    end

    def file_conversion_status(id)
      MP4Status.new(get("/files/#{id}/mp4"))
    end

    def file_convert(id)
      post("/files/#{id}/mp4")
    end
  end

  class FileManager
    attr_accessor :client

    def initialize(folder_id = nil)
      self.client = CLIENT
      traverse(folder_id)
    end

    def files
      @_files ||= []
    end

    def folders
      @_folders ||= []
    end

    def traverse(folder_id)
      resp = client.files(folder_id)
      resp["files"].each do |item|
        if item["file_type"] == "FOLDER"
          folders << PutIO::Folder.new(item)
        else
          files << PutIO::File.new(item)
        end
      end

      files.each do |file|
        if file.is_mp4_available
          puts "SKIPPING::AVAILABLE\t#{file.name}"
          next
        end

        if !file.content_type.start_with?("video/")
          puts "SKIPPING::NONVIDEO\t#{file.name}"
          next
        end

        status = client.file_conversion_status(file.id)
        pending_statuses = ["IN_QUEUE", "CONVERTING"]
        if status.mp4 && pending_statuses.include?(status.mp4["status"])
          puts "PENDING::#{status.mp4['status']}\t#{file.name}"
          next
        end

        if status.mp4 && status.mp4["status"] == "COMPLETED"
          puts "SKIPPING::COMPLETED\t#{file.name}"
          next
        end

        puts "STARTING\t\t#{file.name}"
        client.file_convert(file.id)
      end

      folders.each do |folder|
        PutIO::FileManager.new(folder.id)
      end
    end
  end
end

API_KEY = ENV["API_KEY"]
CLIENT = PutIO::Client.new(API_KEY)
PutIO::FileManager.new
