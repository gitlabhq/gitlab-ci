#! /usr/bin/env ruby
require 'rubygems'
require 'bundler'
Bundler.require

require 'sinatra'
require 'sinatra/base'
require "sinatra/reloader"
require 'sinatra/activerecord'
require 'will_paginate'
require 'will_paginate/active_record'

$: << File.dirname(__FILE__) + "/lib"
require 'project'
require 'runner'
require 'helper'

class GitlabCi < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end
  register Sinatra::ActiveRecordExtension

  include Helper
  include WillPaginate::Sinatra::Helpers


  set :haml, format: :html5
  set layout: true
  set :database, 'sqlite3:///ci.db'
  set :database_extras, timeout: 1000

  get '/' do
    @projects = Project.all

    haml :index
  end

  get '/projects/new' do
    # add project
    haml :new
  end

  get '/projects/:name' do
    @project = Project.find_by_name(params[:name])
    @builds = @project.builds.order('id DESC').paginate(:page => params[:page], :per_page => 30)

    haml :project
  end

  get '/projects/:name/run' do
    @project = Project.find_by_name(params[:name])
    @build = @project.register_build

    Resque.enqueue(Runner, @build.id)

    redirect project_path(@project)
  end

  get '/projects/:name/edit' do
    @project = Project.find_by_name(params[:name])

    haml :edit
  end

  post '/projects' do
    project_params = params.select {|k,v| Project.attribute_names.include?(k.to_s)}
    @project = Project.new(project_params)

    if @project.save
      Resque.enqueue(Runner, @project.id)
      redirect '/'
    else
      haml :new
    end
  end

  post '/projects/:name' do
    project_params = params.select {|k,v| Project.attribute_names.include?(k.to_s)}
    @project = Project.find_by_name(params[:name])
    @project.update_attributes(project_params)

    if @project.save
      redirect '/'
    else
      haml :new
    end
  end

  post '/projects/:name/build' do
    @project = Project.find_by_name(params[:name])
    @build = @project.register_build(params)

    Resque.enqueue(Runner, @build.id)
  end
end
