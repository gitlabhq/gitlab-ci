#! /usr/bin/env ruby
require 'rubygems'
require 'bundler'
Bundler.require

require 'sinatra'
require 'sinatra/base'
require "sinatra/reloader"
require 'sinatra/activerecord'

$: << File.dirname(__FILE__) + "/lib"
require 'project'
require 'runner'
require 'helper'

class GitlabCi < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  include Helper

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

  get '/projects/:name' do
    @project = Project.find_by_name(params[:name])
    @builds = @project.builds.order('id DESC')

    haml :project
  end

  get '/projects/:name/edit' do
    @project = Project.find_by_name(params[:name])

    haml :edit
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
end
