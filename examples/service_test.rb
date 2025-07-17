require_relative "../lib/dagger_ruby"

DaggerRuby.connection do |client|
  cache = client.cache_volume("bundle-cache")
  app_dir = client.host.directory(File.join(__dir__, "dummy_app"))

  puts "🚀 Testing Ruby app..."

  container = client.container
                    .from("ruby:3.4.4")
                    .with_mounted_cache("/usr/local/bundle", cache)
                    .with_directory("/app", app_dir)
                    .with_workdir("/app")
                    .with_exec(%w[bundle install])

  puts "✅ Dependencies installed"

  syntax_check = container
                 .with_exec(["ruby", "-c", "app.rb"])
                 .stdout

  puts "✅ Syntax check: #{syntax_check.strip}"

  app_info = container
             .with_exec(["ruby", "-e", "
      require_relative 'app'
      puts 'App loaded successfully'
      puts 'Sinatra version: ' + Sinatra::VERSION
      puts 'Ruby version: ' + RUBY_VERSION
      puts 'Routes: /, /health, /info'
    "])
             .stdout

  puts "📊 App info:"
  puts app_info

  puts "🌐 Testing HTTP endpoint..."

  http_test = container
              .with_exec(["sh", "-c", "
      (timeout 8 bundle exec rackup config.ru --host 0.0.0.0 --port 4567 >/dev/null 2>&1 &)
      sleep 3
      curl -s http://localhost:4567/info 2>/dev/null || echo '{\"status\":\"service_not_ready\"}'
    "])
              .stdout

  puts "📡 /info endpoint response:"
  puts http_test.strip
end
