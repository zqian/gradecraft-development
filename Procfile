web: bundle exec puma -p $PORT
redis: redis-server --port 6379
bg: bundle exec sidekiq --config ./config/sidekiq.yml
mongo: bundle exec mongod --dbpath=$MONGO_PATH --rest

