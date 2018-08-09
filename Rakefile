desc 'default'
task :default do
  Rake::Task[:rakeup].invoke
end

desc '0.0.0.0:9292'
task :up do
  exec 'bundle exec rackup config.ru -o 0.0.0.0 -p 9292'
end
