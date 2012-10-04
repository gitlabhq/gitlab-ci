#! /usr/bin/env ruby
require 'rubygems'
require 'bundler'
Bundler.require

require 'sinatra'
require 'sinatra/activerecord'

$: << File.dirname(__FILE__) + "/lib"
require 'project'
require 'runner'

class GitlabCi < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  set :haml, format: :html5
  set layout: true
  set :database, 'sqlite3:///ci.db'

  get '/' do
    @projects = Project.all

    @projects.each do |project|
      Runner.new(project).run
    end

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
    project_params = params.select {|k,v| Project.attribute_names.include?(k.to_s)}
    @project = Project.new(project_params)

    if @project.save
      redirect '/'
    else
      haml :new
    end
  end
end
