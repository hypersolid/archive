class EmailFallback < ActiveRecord::Base

  def self.proxy(method_name, *args)
    fallback = EmailFallback.new(:token => Devise.friendly_token)
    mail = Notifier.send(method_name, *args << fallback)
    params = {:from => mail.from.join(','), :to => mail.to.join(','), :subject => mail.subject, :body => mail.body.raw_source}
    fallback.update_attributes params
    mail.deliver
    fallback
  end

end
