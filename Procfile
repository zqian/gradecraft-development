web: bundle exec puma -p 8888
redis: redis-server --port 7372
bg: bundle exec sidekiq --config ./config/sidekiq.yml
mongo: bundle exec mongod --dbpath=/Users/zqian/data/db --rest