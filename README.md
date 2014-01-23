# Pmirror

[![Build
Status](https://travis-ci.org/adnichols/pmirror.png?branch=master)](https://travis-ci.org/adnichols/pmirror)

pmirror is a tool primarily intended to mirror a subset of files from a
remote http repository. I created the tool because I wanted a way to
mirror just some files from a remote RPM repository to a local
repository. I also wanted to be able to perform operations on the
locally downloaded files once the mirror operation was complete

Was there already a tool out there that does this? Probably, I couldn't
find it. 

## Features

The tool is very new so it only has the bare minimum feature set:

- Specify multiple regex patterns to match against the remote directory
- Specify a list of URL's to look for patterns across, this means you
  can look for the same patterns on multiple urls and aggregate those
  files into one place
- Provides a progressbar download status indicator
- Specify a local directory to download files to
- Specify a command to execute on the local directory once all files are
  downloaded

## Installation

Add this line to your application's Gemfile:

    gem 'pmirror'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pmirror

### Dependencies

This gem makes use of the following other projects

- [methadone](https://github.com/davetron5000/methadone)
- [progressbar](https://github.com/peleteiro/progressbar)
- [nokogiri](http://nokogiri.org/)

## Usage

```
Usage: pmirror [options] url

Options:
    -h, --help                       Show command line help
    -p, --pattern PAT1,PAT2,PAT3     Regex to match files in remote dir, may specify multiple patterns
    -u --url                         One or more URL's to check for files that match the defined patterns
    -l, --localdir DIR               Local directory to mirror files to
    -e, --exec CMD                   Execute command after completion
        --log-level                  Set the logging level to one of [ debug, info, warn, error]
    -c, --config FILE                Config file to read command line options from (yaml)
    -v, --version                    Show version
```

Usage should be pretty self explanatory but here are the details:

`--url` is the remote URL that you want to fetch files from. Right now
this is assumed to be an un-authenticated url. We do not recurse into
directories looking for files. You may specify more than one url and we
will look at each url and download any matching files from that url. If
the same filename is matched across multiple URL's only the first will
be downloaded, subsequent files will see that there is already a local
file with the same name and will not download. 

Example:
```
pmirror --url http://someurl.com    # Single URL
pmirror --url http://someurl.com,http://someotherurl.com # Multiple URLs
```

`--pattern` allows you to specify a comma separated list of patterns to
match on the remote directly. We will iterate over each pattern and
build up the file list to fetch from the remote url. 

Example:
```
pmirror --pattern foo               # Single pattern
pmirror --pattern foo,bar           # Multiple patterns
```

`--localdir` is the location you want files downloaded to. It is also
the directory in which any commands specified with `--exec` will be
performed.

Example:
```
pmirror --localdir /tmp/foo
```

`--exec` is used to perform actions on the download directory. The
envisioned use case right now is simply to run a createrepo when the
downloads are complete. This will change PWD to whatever directory is
specified in `--localdir` and then will run the command you specify.
There is not currently a way to pass the value of `--localdir` into a
command other than to specify `.` in your command. 

Example:
```
pmirror --exec 'createrepo -c .cache -d .'
```

`--log-level` will set the logging level when you run the application.
This enables additional messaging. The most useful log levels right now
are `info` and `debug`. 

`--config` allows you to put all of your command line options into a
YAML formatted configuration file. Unlike the command line, lists of
options here (like pattern: or url:) are YAML lists. Each key must be
the long name of the option to use. There is no default config file. 

Example config:
```
localdir: ../foo
pattern:
  - ^floo.*
  - ^mah.*
url:
  - http://localhost:55555
  - http://localhost:55555
```

`--version` provides the version info

`--help` should be self explanatory

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add tests for your new feature to pmirror.feature
4. Run tests (`rake`)
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create new Pull Request
