require "pmirror/version"
require 'nokogiri'
require 'open-uri'
require 'progressbar'

module Pmirror
  class Pmirror
    include Methadone::Main
    include Methadone::CLILogging
    include Methadone::SH

    main do |url|

      download_files( url, options[:localdir], get_download_list(url, options[:pattern]) )
      execute(options[:exec]) if options[:exec]

    end

    description "Mirror files on a remote http server based on pattern match"
    arg("url", "Url or remote site", :one, :required)
    on("-p", "--pattern PAT1,PAT2,PAT3", Array,
       "Regex to match files in remote dir, may specify multiple patterns"
      )
    on("-l", "--localdir DIR", "Local directory to mirror files to")
    on("-e", "--exec CMD", "Execute command after completion")
    on("-d", "--debug", "Enable debugging")
    on("-v", "--version", "Show version")

    def self.get_download_list(url, pattern)
      info "Getting download list"
      page = Nokogiri::HTML(open(url))
      downloads = []

      page.css("a").each do |link|
        rpm_name = link.attributes['href'].value
        pattern.each do |matcher|
          if /#{matcher}/.match(rpm_name)
            downloads << rpm_name
          end
        end
      end
      downloads
    end

    def self.download_files(url, local_dir, file_list=[])
      file_list.each do |file|
        local_fn = "#{local_dir}/#{file}"

        unless Dir.exist? options[:localdir]
          puts "PWD: #{Dir.pwd}"
          puts Dir.open(Dir.pwd).read
          puts "Destination directory '#{options[:localdir]}' does not exist!"
          exit 1
        end

        remote_fn = "#{url}/#{file}"
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

    def self.http_to_file(filename,url)
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
