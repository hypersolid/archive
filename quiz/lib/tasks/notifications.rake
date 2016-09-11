namespace :notifications do
  desc "Send various notification emails"

  task :final => :environment do
    t = Tournament.where(['ends_at between ? and ?',Time.now - 1.hour, Time.now]).first
    t.send_final_summary if t
  end

  task :invite_wingmen => :environment do
    Tournament.current.send_invite_wingmen
  end

end
