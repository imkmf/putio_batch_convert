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
      puts "GET: #{url}"
      self.class.get(url, @options)
    end

    def post(url)
      puts "POST: #{url}"
      self.class.post(url, @options)
    end

    def files(id = nil)
      id_url = "/#{id}" if id
      get("/files/list#{id_url}")
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
        if item["content_type"] == "application/x-directory"
          folders << PutIO::Folder.new(item)
        else
          files << PutIO::File.new(item)
        end
      end

      files.each do |file|
        next if file.is_mp4_available

        status = client.file_conversion_status(file.id)
        statuses = ["IN_QUEUE","CONVERTING","COMPLETED"]
        next if !status.mp4 || statuses.include?(status.mp4["status"])

        puts "FOUND: Converting #{file.name}"
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
