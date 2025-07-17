require_relative "../lib/dagger_ruby"

message = ARGV[0] || "Hello from Dagger!"

DaggerRuby.connection do |client|
  result = client.container
                 .from("python:alpine")
                 .with_exec(%w[pip install cowsay])
                 .with_exec(["cowsay", message])
                 .stdout

  puts result
end
