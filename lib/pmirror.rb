require "pmirror/version"
require 'nokogiri'
require 'open-uri'
require 'progressbar'

module Pmirror
  class Pmirror
    include Methadone::Main
    include Methadone::CLILogging
    include Methadone::SH
    version(::Pmirror::VERSION)

    main do
      debug "Inside main"

      parse_config(options[:config]) if options[:config]
      normalize_defaults

      if options[:url] && options[:pattern] && options[:localdir]
        download_list = get_download_list(options[:url], options[:pattern])
        debug "download_list: #{download_list.inspect}"
        if download_list
          download_files(options[:localdir], download_list)
        else
          info "No files to download"
        end

        execute(options[:exec]) if options[:exec]
      else
        help_now!("Missing arguments")
      end

    end

    description "Mirror files on a remote http server based on pattern match"
    on("-p", "--pattern PAT,PAT", Array,
       "Regex to match files in remote dir, may specify multiple patterns"
      )
    on("-l", "--localdir DIR", "Local directory to mirror files to")
    on("-e", "--exec CMD", "Execute command after completion")
    on("-u", "--url URL,URL", Array, "Url or remote site")
    on("-c", "--config FILE", "Config file (yaml) to use instead of command line options")

    use_log_level_option

    def self.parse_config(config_file)
      debug "In parse_config"
      parsed = YAML::load_file(config_file)
      if parsed.kind_of? Hash
        parsed.each do |option,value|
          debug "Storing option '#{option}' with value '#{value.inspect}'"
          options[option] = value
        end
      end
    end

    def self.get_download_list(url_list, pattern)
      debug "inside get_download_list"
      downloads = {}
      url_list.each do |single_url|
        downloads[single_url] = []
        info "Getting download list for url: #{single_url}"
        page = Nokogiri::HTML(open(single_url))

        page.css("a").each do |link|
          file_name = link.attributes['href'].value
          pattern.each do |matcher|
            if /#{matcher}/.match(file_name)
              debug "Found match: #{file_name}"
              downloads[single_url] << file_name
            end
          end
        end
        debug "Returning downloads: #{downloads.inspect}"
      end
      downloads
    end

    def self.download_files(local_dir, url_hash={})
      debug "Inside download_files"
      url_hash.each_key do |single_url|
        debug "Working on #{single_url}"
        url_hash[single_url].each do |file|
          local_fn = "#{local_dir}/#{file}"

          unless Dir.exist? options[:localdir]
            debug "PWD: #{Dir.pwd}"
            info "Destination directory '#{options[:localdir]}' does not exist!"
            exit 1
          end

          remote_fn = "#{single_url}/#{file}"
          unless File.exist?(local_fn)
            info "Downloading File: #{file}"
            info "#{remote_fn} ==> #{local_fn}"
            http_to_file(local_fn, remote_fn)
            # File.write(local_fn, open(remote_fn).read)
            info "Download Complete for #{file}"
          else
            info "Skipping #{file}, already exists"
          end
        end
      end
    end

    def self.http_to_file(filename,url)
      debug "Inside http_to_file"
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
      info ""
    end

    def self.execute(cmd)
      debug "Inside execute"
      info "Executing: #{cmd}"
      sh("cd #{options[:localdir]} && #{cmd}")
    end

    def self.update_repodata(local_dir)
      puts "Running createrepo for dir '#{local_dir}'"
      sh("createrepo -c /#{local_dir}/.cache -d #{local_dir}")
    end

    go!
  end
end
