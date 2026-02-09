require 'aws-sdk-secretsmanager'
require 'json'

module SecretsManager
  def self.get_secret(secret_name, region = 'ap-south-1')
    client = Aws::SecretsManager::Client.new(region: region)
    
    begin
      response = client.get_secret_value(secret_id: secret_name)
      
      # Parse the secret string
      if response.secret_string
        JSON.parse(response.secret_string)
      else
        # Decode binary secret if needed
        Base64.decode64(response.secret_binary)
      end
    rescue Aws::SecretsManager::Errors::ServiceError => e
      Rails.logger.error("Error retrieving secret #{secret_name}: #{e.message}")
      raise
    end
  end
end