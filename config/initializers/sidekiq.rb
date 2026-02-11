if Rails.env.production?
  begin
    # Fetch the secret you already created
    secrets = SecretsManager.get_secret('blog-app/production/cache')
    
    # Ensure 'url' matches the key you used in the AWS Secrets Manager JSON
    redis_url = secrets['url'] 
    
    # Optional: If you use a password or specific DB, 
    # the URL format is redis://:password@hostname:6379/0
  rescue StandardError => e
    Rails.logger.error "Sidekiq could not fetch Redis URL from Secrets Manager: #{e.message}"
    raise "Sidekiq initialization failed due to missing Redis configuration"
  end
else
  # Local development fallback
  redis_url = ENV.fetch("REDIS_URL", "redis://localhost:6379/0")
end

sidekiq_config = { 
  url: redis_url,
  namespace: "{sidekiq}", 
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
}

Sidekiq.configure_server do |config|
  config.redis = sidekiq_config
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end