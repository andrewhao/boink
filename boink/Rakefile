# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'
require 'fileutils'

Boink::Application.load_tasks
namespace :camera do 
  desc 'Execute a camera snap.'
  task :snap do |t, args|
    filename = ENV['FILENAME'] || 'boink_%n.jpg'
    interval_sec = ENV['INTERVAL_SEC'] || 0
    num_frames = ENV['NUM_FRAMES'] || 1
    sh "gphoto2 --capture-image-and-download --filename \"#{filename}\" --force-overwrite --interval #{interval_sec} --frames #{num_frames}"
  end
end