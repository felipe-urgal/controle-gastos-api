require "securerandom"
require "digest"

class SessionTokenService
  def self.generate_token
    SecureRandom.hex(32)
  end

  def self.digest(token)
    Digest::SHA256.hexdigest(token)
  end
end
