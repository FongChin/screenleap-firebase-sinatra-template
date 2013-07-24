require 'rubygems'
require 'rest_client'
require 'sinatra'
require 'json'

get '/' do
  erb :index
end

get '/:id' do
  @firebase = ENV["FBASE_URL"] # replace with your firebase URL
  @roomId = params[:id]
  erb :room
end

post '/screenleap' do
  # replace ENV["SL_ACCOUNT_ID"] and ENV["SL_AUTH_TOKEN"] 
  # with your own screenleap's account_id and auth token
  begin
    response = RestClient.post(
      "https://api.screenleap.com/v2/screen-shares",
      {},
      {:accountid => ENV["SL_ACCOUNT_ID"], :authtoken => ENV["SL_AUTH_TOKEN"] }
    )
    data = response
    return data
  rescue Exception => e
    e.response
  end
end

