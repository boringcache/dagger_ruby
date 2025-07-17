require "sinatra"
require "json"

set :port, 4567

get "/" do
  content_type :json
  {
    message: "Hello from Dagger Ruby!",
    timestamp: Time.now.iso8601,
    version: "1.0.0",
  }.to_json
end

get "/health" do
  content_type :json
  { status: "ok" }.to_json
end

get "/info" do
  content_type :json
  {
    ruby_version: RUBY_VERSION,
    sinatra_version: Sinatra::VERSION,
    environment: ENV["RACK_ENV"] || "development",
  }.to_json
end
