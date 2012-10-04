#! /usr/bin/env ruby
require 'rubygems'
require 'bundler'
Bundler.require

$: << File.dirname(__FILE__) + "/models"
require 'project'

class GitlabCi < Sinatra::Base
  set :haml, format: :html5
  set layout: true

  get '/' do
    @projects = [
      Project.new('GitLab', true),
      Project.new('Diaspora', false),
      Project.new('Rails', true)
    ]
    haml :index
  end

  get '/:id' do
    haml :project
  end

  get '/:id/status' do
    # build status badge
  end

  post '/project' do
    # add project
  end
end
