#! /usr/bin/env ruby
require 'rubygems'
require 'bundler'
Bundler.require

require 'sinatra'
require 'sinatra/base'
require "sinatra/reloader"
require 'sinatra/activerecord'
require 'sinatra/respond_to'

require 'will_paginate'
require 'will_paginate/active_record'

# Include to load path
$: << File.dirname(__FILE__) + "/lib"

# Settings & db
require 'settings'

# Libs
require 'project'
require 'user'
require 'runner'
require 'helper'

class GitlabCi < Sinatra::Base
  TOKEN = 'c93d3bf7a7c4afe94X64e30c2ce39f4f'

  configure :development do
    register Sinatra::Reloader
  end

  register Sinatra::ActiveRecordExtension
  register Sinatra::RespondTo

  include Helper
  include WillPaginate::Sinatra::Helpers

  register do
    def auth (type)
      condition do
        redirect "/login" unless send("is_#{type}?")
      end
    end
  end

  helpers do
    def is_user?
      @user != nil
    end
  end

  before do
    @user = User.find_by_id(session[:user_id])
  end

  set :sessions => true
  set :haml, format: :html5
  set layout: true
  set :database, Settings.db_url

  get '/' do
    @projects = Project.all

    haml :index
  end

  get '/projects/new' do
    @project = Project.new

    haml :new
  end

  get '/projects/:name' do
    @project = Project.find_by_name(params[:name])
    @builds = @project.builds.order('id DESC').paginate(:page => params[:page], :per_page => 10)

    haml :project
  end

  get '/projects/:name/run', auth: 'user' do
    @project = Project.find_by_name(params[:name])
    @build = @project.register_build

    Resque.enqueue(Runner, @build.id)

    redirect build_path(@build)
  end

  get '/projects/:name/edit', auth: 'user' do
    @project = Project.find_by_name(params[:name])

    haml :edit
  end

  get '/builds/:id' do
    @build = Build.find(params[:id])
    @project = @build.project

    respond_to do |format|
      format.html { haml :build }
      format.js   { haml :build }
    end
  end

  post '/projects', auth: 'user' do
    @project = Project.new(params[:project])

    if @project.save
      Resque.enqueue(Runner, @project.id)
      redirect '/'
    else
      haml :new
    end
  end

  post '/projects/:name', auth: 'user' do
    @project = Project.find_by_name(params[:name])
    @project.update_attributes(params[:project])

    if @project.save
      redirect '/'
    else
      haml :new
    end
  end

  post '/projects/:name/build' do
    if params[:token] == TOKEN
      @project = Project.find_by_name(params[:name])
      @build = @project.register_build(params)
      Resque.enqueue(Runner, @build.id)
      status 200
    else
      status 403
    end
  end

  get "/login" do
    haml :login
  end

  post "/login" do
    user = User.authenticate(params['email'], params['password'])

    session[:user_id] = user.id if user
    redirect '/'
  end

  get "/logout" do
    session[:user_id] = nil
    redirect '/'
  end
end
