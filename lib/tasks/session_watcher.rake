require 'rake'

namespace :session_watcher do
  desc "Clear inactive users in system"
  task :clear_inactive => :environment do
    puts("Removing inactive sessions ==> Started: @#{Time.now}")
    puts("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")
 
    global_timeout = Settings.login_time_out.to_i
    session_list = ActiveRecord::SessionStore::Session.where("updated_at < ?",global_timeout.minutes.ago)

    session_list.each do |a_session|
      if not a_session.data["user_id"].nil? then
        user = User.find(a_session.data["user_id"])
        user.user_live_edit.current_type = ""
        user.user_live_edit.current_action = ""
        user.user_live_edit.current_id = 0
        user.user_live_edit.current_field = ""
        user.user_live_edit.save 
      end
      a_session.delete
      puts("Session for user #{user.full_name rescue "a user"} closed due to inactivity. ("+ global_timeout.to_s+" minute[s])")
    end
        
    puts("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")
    puts("Removing inactive sessions complete. Ended @#{Time.now}")
  end

  desc "Kill all sessions -- for system maintenance"
  task :system_maintenance => :environment do
    
    session_list = ActiveRecord::SessionStore::Session.all
    session_list.each do |a_session|
      if not a_session.data["user_id"].nil? then
        user = User.find(a_session.data["user_id"]) rescue []
      end
      a_session.delete
      puts("Sessions Forceably Cleared.")
    end
    

    time_items = "0:0:9".split(":") # 10 min window for update
     
    up_time = Time.now.utc + time_items[0].to_i.days + time_items[1].to_i.hours + time_items[2].to_i.minutes 
    out_time =   up_time.strftime("%m/%d/%Y %I:%M %p UTC")   #=> "6/9/2016 10:25 AM"

    FileUtils.mv  'public/index.off',  'public/index.html' rescue puts "index.off not found (moved by other process)"
    File.write('public/splash/waittime.js', "// Auto written by silverweb_cms \n\r \n\r var TargetDate = \"#{out_time}\"; \n")    
  end
  
  desc "Enable Site -- for system maintenance"
  task :site_on => :environment do
    FileUtils.mv  'public/index.html',  'public/index.off' rescue puts "index.index not found (moved by other process)"
  end

end
  

 