if Rails.env.production?
  begin
    secrets = SecretsManager.get_secret('blog-app/production/cache')
    # We use the clean URL from Secrets Manager
    redis_url = secrets['url']
    # SSL/TLS is mandatory for ElastiCache Serverless
    ssl_options = { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  rescue StandardError => e
    Rails.logger.error "Sidekiq could not fetch Redis URL from Secrets Manager: #{e.message}"
    raise "Sidekiq initialization failed due to missing Redis configuration"
  end
else
  redis_url   = ENV.fetch("REDIS_URL", "redis://localhost:6379/0")
  ssl_options = {} # or omit ssl_params entirely in non‑production
end

sidekiq_config = {
  url: redis_url,
  ssl_params: ssl_options,
  custom: {
    tag: "sidekiq"
  }
}

Sidekiq.configure_server do |config|
  config.redis = sidekiq_config
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end