require "digest/md5"

class Playspan
  def self.config
    @config ||= YAML::load(File.open("#{Rails.root}/config/playspan.yml"))[Rails.env]
  end

  # MD5 hash of concatenated fields: userid,adminPwd,merchAuthPhrase,currency,amount,merchtrans
  def self.hash(userid, currency, amount, merchtrans)
    Digest::MD5.hexdigest("#{userid}#{config['adminPwd']}#{config['merchAuthPhrase']}#{currency}#{amount}#{merchtrans}")
  end

  def self.valid_params?(params)
    params[:hash] == self.postback_hash(params)
  end

  # MD5 hash of concatenated fields:
  # dtdatetime,login,adminpwd,merchAuthPhrase,userid,commtype,set_amount,amount,sepamount,currency,sn,mirror,pbctrans, developerid,appid,virtualamount,virtualcurrency
  def self.postback_hash(params)
    Digest::MD5.hexdigest("#{params[:dtdatetime]}#{config['login']}#{config['adminPwd']}#{config['merchAuthPhrase']}#{params[:userid]}#{params[:commtype]}#{params[:set_amount]}#{params[:amount]}#{params[:sepamount]}#{params[:currency]}#{config['sn']}#{params[:mirror]}#{params[:pbctrans]}#{params[:developerid]}#{params[:appid]}#{params[:virtualamount]}#{params[:virtualcurrency]}")
  end
end