ENV["RACK_ENV"] ||= "development"
require 'sinatra/base'
require_relative 'data_mapper_setup'
require 'sinatra/flash'


class BookmarkManager < Sinatra::Base
  use Rack::MethodOverride

  enable :sessions
  set :session_secret, 'super secret'
  register Sinatra::Flash

  helpers do
    def current_user
      @current_user ||= User.get(session[:user_id])
    end
  end

  get '/' do
    erb :'home'
  end

  get '/users/new' do
    @user = User.new
    erb :'users/new'
  end

  post '/users' do
    @user = User.create(email: params[:email], password: params[:password], password_confirmation: params[:password_confirmation])
    if @user.save
      session[:user_id] = @user.id
      redirect '/links'
    else
      flash.now[:errors] = @user.errors.full_messages
      erb :'users/new'
    end
  end

  get '/sessions/new' do
    erb :'sessions/new'
  end

  post '/sessions' do
    user= User.authenticate(params[:email], params[:password])
    if user
      session[:user_id]= user.id
      redirect to('/links')
    else
      flash.now[:errors] = ['The Email or password is incorrect']
      erb :'sessions/new'
    end
  end

  delete '/sessions' do
    session[:user_id] = nil
    flash.keep[:notice] = 'goodbye!'
    redirect to '/links'
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
