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
    -p, --pattern PAT1,PAT2,PAT3     Regex to match files in remote dir,
may specify multiple patterns
    -l, --localdir DIR               Local directory to mirror files to
    -e, --exec CMD                   Execute command after completion
    -d, --debug                      Enable debugging
    -v, --version                    Show version
```

Usage should be pretty self explanatory but here are the details:

`url` is the remote URL that you want to fetch files from. Right now
this is assumed to be an un-authenticated url. We do not recurse into
directories looking for files.

`--pattern` allows you to specify a comma separated list of patterns to
match on the remote directly. We will iterate over each pattern and
build up the file list to fetch from the remote url. 

`--localdir` is the location you want files downloaded to. It is also
the directory in which any commands specified with `--exec` will be
performed.

`--exec` is used to perform actions on the download directory. The
envisioned use case right now is simply to run a createrepo when the
downloads are complete. This will change PWD to whatever directory is
specified in `--localdir` and then will run the command you specify.
There is not currently a way to pass the value of `--localdir` into a
command other than to specify `.` in your command. 

`--debug` would enable some extra output

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
