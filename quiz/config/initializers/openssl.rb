module OpenSSL
  module SSL
    remove_const :VERIFY_PEER if Rails.env.development?
    VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE if Rails.env.development?
  end
end
