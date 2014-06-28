Segmentor
=========

## Disclosure

I use this to get "stuff" out of my seedbox so it's build for that use case in mind.

## Purpose

This is a simple ruby script that will mirror a remote directory on a FTP server to a local folder.
Pretty boring right?

Well, bear with me for a second.

I personally have AT&T and I've noticed that even though my connection bandwidth is about 3.5meg/s I was getting throttle to 1.2megs/ connection to my FTP server. When you have a lot of files to DL that's fine but when you only need one file it kinda sucks. 

With this script we take advantage of threaded segmented downloads so that you can use your full bandwidth on a single file

## How does it work ?

We get the file size, we split it into n even chunks of data and we download each chunks in parallel using threads.

Another watcher thread will monitor the other threads and tell you what's up.

We use Curl and the range option to get the right chunk and cat to merge everything together.

## Requirements

* Ruby
* Linux/Max (tested only on linux but should work on mac)
* ruby-progressbar (gem)
* net-ftp-list (gem)
* curl (system)

## Usage

make sure you got all the requirements installed.

copy base_config.yml to config.yml and update it to your needs

ruby main.rb

## Todo

Right now it mirrors everything. I could be nice to keep a history of what you downloaded already so that you can move it out of your triage dir.
