require "pmirror/version"
require 'nokogiri'
require 'open-uri'
require 'progressbar'

module Pmirror
  class Pmirror
    include Methadone::Main
    include Methadone::CLILogging
    include Methadone::SH

    main do
      d "Inside main"

      download_list = get_download_list(options[:url], options[:pattern])
      d "download_list: #{download_list.inspect}"
      download_files(options[:localdir], download_list)
      execute(options[:exec]) if options[:exec]

    end

    description "Mirror files on a remote http server based on pattern match"
    on("-p", "--pattern PAT1,PAT2,PAT3", Array,
       "Regex to match files in remote dir, may specify multiple patterns"
      )
    on("-l", "--localdir DIR", "Local directory to mirror files to")
    on("-e", "--exec CMD", "Execute command after completion")
    on("-d", "--debug", "Enable debugging")
    on("-v", "--version", "Show version")
    on("-u", "--url URL,URL", Array, "Url or remote site")

    def self.d(msg)
      if options[:debug]
        puts "[DEBUG]: #{msg}"
      end
    end

    def self.get_download_list(url_list, pattern)
      d "inside get_download_list"
      downloads = {}
      url_list.each do |single_url|
        downloads[single_url] = []
        d "Getting download list for url: #{single_url}"
        page = Nokogiri::HTML(open(single_url))

        page.css("a").each do |link|
          file_name = link.attributes['href'].value
          pattern.each do |matcher|
            if /#{matcher}/.match(file_name)
              d "Found match: #{file_name}"
              downloads[single_url] << file_name
            end
          end
        end
        d "Returning downloads: #{downloads.inspect}"
      end
      downloads
    end

    def self.download_files(local_dir, url_hash={})
      d "Inside download_files"
      url_hash.each_key do |single_url|
        d "Working on #{single_url}"
        url_hash[single_url].each do |file|
          local_fn = "#{local_dir}/#{file}"

          unless Dir.exist? options[:localdir]
            d "PWD: #{Dir.pwd}"
            puts Dir.open(Dir.pwd).read
            puts "Destination directory '#{options[:localdir]}' does not exist!"
            exit 1
          end

          remote_fn = "#{single_url}/#{file}"
          unless File.exist?(local_fn)
            puts "Downloading File: #{file}"
            puts "#{remote_fn} ==> #{local_fn}"
            http_to_file(local_fn, remote_fn)
            # File.write(local_fn, open(remote_fn).read)
            puts "Download Complete for #{file}"
          else
            puts "Skipping #{file}, already exists"
          end
        end
      end
    end

    def self.http_to_file(filename,url)
      d "Inside http_to_file"
      pbar = nil
      File.open(filename, 'wb') do |save_file|
        open(url, 'rb',
             :content_length_proc => lambda {|t|
          if t && 0 < t
            pbar = ProgressBar.new("=", t)
            pbar.file_transfer_mode
          end
        },
        :progress_proc => lambda {|s|
          pbar.set s if pbar
        }) {|f| save_file.write(f.read) }
      end
      puts
    end

    def self.execute(cmd)
      d "Inside execute"
      puts "Executing: #{cmd}"
      sh("cd #{options[:localdir]} && #{cmd}")
    end

    def self.update_repodata(local_dir)
      puts "Running createrepo for dir '#{local_dir}'"
      sh("createrepo -c /#{local_dir}/.cache -d #{local_dir}")
    end

    go!
  end
end
