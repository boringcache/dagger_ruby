require_relative "../lib/dagger_ruby"

DaggerRuby.connection do |client|
  puts "🌐 Service binding example..."

  redis = client.container
                .from("redis:alpine")
                .with_exposed_port(6379)
                .as_service

  result = client.container
                 .from("alpine:latest")
                 .with_exec(%w[apk add redis])
                 .with_service_binding("redis", redis)
                 .with_exec(["redis-cli", "-h", "redis", "ping"])
                 .stdout

  puts "📡 Redis response: #{result.strip}"
  puts "✅ Service binding works!"
end
