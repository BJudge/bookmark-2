ENV["RACK_ENV"] ||= "development"
require 'sinatra/base'
require_relative 'data_mapper_setup'


class BookmarkManager < Sinatra::Base

  enable :sessions
  set :session_secret, 'super secret'

  helpers do
    def current_user
      @current_user ||= User.get(session[:user_id])
    end
  end

  get '/' do
    erb :'home'
  end

  get '/users/new' do
    erb :'users/new'
  end

  post '/users' do
    user = User.create(email: params[:email], password: params[:password], password_confirmation: params[:password_confirmation])
    session[:user_id] = user.id
    redirect '/links'
  end

  get '/links' do
    @links = Link.all
    erb :'links/index'
    end

    get '/links/new' do
      erb :'links/new'
    end

    post '/links' do
      link = Link.create(url: params[:url], title: params[:title])
      params[:tags].split.each do |tag|
        link.tags << Tag.create(name: tag)
      end
      link.save
      redirect '/links'
    end

    get '/tags/:name' do
      tag = Tag.first(name: params[:name])
      @links = tag ? tag.links : []
      erb :'links/index'
    end

end
