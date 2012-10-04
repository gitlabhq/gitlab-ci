#! /usr/bin/env ruby
require 'rubygems'
require 'bundler'
Bundler.require

require 'sinatra'
require 'sinatra/activerecord'

$: << File.dirname(__FILE__) + "/models"
require 'project'

class GitlabCi < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  set :haml, format: :html5
  set layout: true
  set :database, 'sqlite3:///ci.db'

  get '/' do
    @projects = Project.all

    haml :index
  end

  get '/:id' do
    haml :project
  end

  get '/:id/status' do
    # build status badge
  end

  get '/projects/new' do
    # add project
    haml :new
  end

  post '/projects' do
    # add project
  end
end
