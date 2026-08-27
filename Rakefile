# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create do |task|
  task.framework = 'require_relative "./test/test_helper"'
end

require "rubocop/rake_task"

RuboCop::RakeTask.new

desc "Compile every Ruby source file"
task :syntax do
  FileList["{lib,test,examples}/**/*.rb"].each do |path|
    RubyVM::InstructionSequence.compile_file(path)
  end
end

task default: %i[syntax test rubocop]
