require_relative "../lib/dagger_ruby"

DaggerRuby.connection do |client|
  cache = client.cache_volume("bundle-cache")
  app_dir = client.host.directory(File.join(__dir__, "dummy_app"))

  puts "Building Ruby Sinatra application..."

  container = client.container
    .from("ruby:3.4.4")
    .with_mounted_cache("/usr/local/bundle", cache)
    .with_directory("/app", app_dir)
    .with_workdir("/app")
    .with_exec([ "bundle", "install" ])

  puts "✅ Dependencies installed with bundle install"

  syntax_check = container
    .with_exec([ "ruby", "-c", "app.rb" ])
    .stdout

  puts "✅ App syntax check passed: #{syntax_check.strip}"

  dependency_check = container
    .with_exec([ "ruby", "-e", "require_relative 'app'; puts 'Dependencies loaded successfully'" ])
    .stdout

  puts "✅ Dependencies check: #{dependency_check.strip}"

  startup_test = container
    .with_exec([ "timeout", "5", "ruby", "-e", "
      require_relative 'app'
      puts 'App can start successfully'
      puts 'Sinatra version: ' + Sinatra::VERSION
      puts 'Ruby version: ' + RUBY_VERSION
    " ])
    .stdout

  puts "✅ Startup test results:"
  puts startup_test

  puts "📦 Container is ready for deployment!"
  puts "   To run: docker run -p 4567:4567 <image>"
  puts "   Endpoints available:"
  puts "   - GET / (welcome message)"
  puts "   - GET /health (health check)"
  puts "   - GET /info (app info)"

  container_id = container.id
  puts "🆔 Container ID: #{container_id}"
end
