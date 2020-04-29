require 'digest/sha1'
# require 'RFC822'
require 'gravtastic'
#include Gravtastic
require 'csv'


class User < ActiveRecord::Base
  include RailsSettings::Extend
  
  RFC822_valid = begin
    qtext = '[^\\x0d\\x22\\x5c\\x80-\\xff]'
    dtext = '[^\\x0d\\x5b-\\x5d\\x80-\\xff]'
    atom = '[^\\x00-\\x20\\x22\\x28\\x29\\x2c\\x2e\\x3a-' +
      '\\x3c\\x3e\\x40\\x5b-\\x5d\\x7f-\\xff]+'
    quoted_pair = '\\x5c[\\x00-\\x7f]'
    domain_literal = "\\x5b(?:#{dtext}|#{quoted_pair})*\\x5d"
    quoted_string = "\\x22(?:#{qtext}|#{quoted_pair})*\\x22"
    domain_ref = atom
    sub_domain = "(?:#{domain_ref}|#{domain_literal})"
    word = "(?:#{atom}|#{quoted_string})"
    domain = "#{sub_domain}(?:\\x2e#{sub_domain})*"
    local_part = "#{word}(?:\\x2e#{word})*"
    addr_spec = Regexp.new("#{local_part}\\x40#{domain}", nil, 'n')
    pattern = /\A#{addr_spec}\z/
  end
  
  has_and_belongs_to_many :roles
  has_many :rights, through: :roles
  
  
  has_one :user_attribute
  has_one :user_live_edit, :autosave => true

  # has_many :orders
  include Gravtastic

  gravtastic :name
  
  # abbreviated for clarity

  validates_presence_of     :name
  validates_uniqueness_of   :name

  validates_format_of :name,
    with: RFC822_valid,
    message: 'must be a valid email address. i.e. user@doman.com'

  attr_accessor :password_confirmation
  validates_confirmation_of :password

  validate :password_non_blank

  #accepts_nested_attributes_for :user_attribute, :allow_destroy => true

  def self.authenticate(name, password)
    @user = self.find_by_name(name)
    
    fail_count_max = (Settings.fail_count_max || 3) rescue 3
    
    return @user, false if @user and (@user and (@user.auth_fail_count.to_i >= fail_count_max))
    
    logged_in = false
    
    if (@user and (@user.auth_fail_count.to_i < fail_count_max))
      expected_password = encrypted_password(password, @user.salt)
      if @user.hashed_password != expected_password
        @user.auth_fail_count = @user.auth_fail_count.to_i + 1
        @user.save
      else
        @user.auth_fail_count = 0
        @user.save
        logged_in = true
      end
    end
    return @user, logged_in
  end

  def full_name
    #user_attributes=UserAttribute.where(:user_id => self.id)
    if self.user_attribute.nil? then
      return(self.name)
    else if self.user_attribute.first_name.nil? or self.user_attribute.last_name.nil? then
        return(self.name)
      else
        return(self.user_attribute.first_name + " " + self.user_attribute.last_name)
      end
    end
  end
  
  def initials
    #user_attributes=UserAttribute.where(:user_id => self.id)
    if self.user_attribute.nil? then
      return(self.name.first.capitalize)
    else if self.user_attribute.first_name.nil? or self.user_attribute.last_name.nil? then
        return(self.name.first.capitalize)
      else
        return(self.user_attribute.first_name.first.capitalize  + self.user_attribute.last_name.first.capitalize)
      end
    end
  end

  
  def is_admin? 
    self.roles.where(:name=>"Admin").size > 0
  end
  
  # Based on Admin Role or Manager role.  Application Specific
  def is_manager? 
    self.roles.where(:name=>"Admin").size > 0 or self.roles.where(:name=>"Manager").size > 0
  end
  
  def has_role?(role)
    self.roles.where(:name=>"Admin").size > 0 or self.roles.where(:name=>role).size > 0
  end
  
  def has_permission (the_action_name,the_controller_name)

    if self.roles.detect{|role|
        role.rights.detect{|right|
          ((right.action == the_action_name)|(right.action == "*")|(right.action.include? the_action_name)) && right.controller == the_controller_name
        }
      }
      return true
    else
      return false
    end
  end
  
  
  def create_reset_code
    @reset = true
    self.attributes = {password_reset_code: Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )}
    save(validate: false)
  end

  def create_activation_code
    @created=true
    self.attributes = {activation_code: Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )}
    save(validate: false)
  end

  def not_activated?
    not self.activation_code.nil?
  end

  def recently_reset?
    @reset
  end

  def recently_activated?
    @activated
  end

  def recently_created?
    @created
  end

  def lost_activation_code?
    @lost_activation_code
  end

  def reset_activation_code
    @losavest_activation_code=true
    save(validate: false)
  end 
  
  def resend_activation_code
    @lost_activation_code=true
  end
  
  def delete_reset_code
    self.attributes = {password_reset_code: nil}
    save(validate: false)
  end

  def delete_activation_code
    @activated=true
    self.attributes = {activation_code: nil, activated_at: Time.now}
    save(validate: false)
  end
  # 'password' is a virtual attribute
  def password
    @password
  end

  def reset
    @reset
  end

  def activated
    @activated
  end

  def created
    @created
  end

  def lost_activation_code
    @lost_activation_code
  end

  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = User.encrypted_password(self.password, self.salt)
    self.auth_fail_count = 0
  end


  def after_destroy
    if User.count.zero?
      raise "Can't delete last user"
    end
  end
  
  def self.to_csv
    # attributes = %w{id email name}

    CSV.generate(headers: true) do |csv|
      csv << ["Firstname", "Lastname", "Email"]

      # data rows
      all.each do |user|
        #  csv << user.attributes.values_at(*column_names)
        csv << [user.user_attribute.first_name, user.user_attribute.last_name, user.name]

      end
      
    end
    
  
  end

  def self.get_active
    @user_list = []
    @session_list = ActiveRecord::SessionStore::Session.all
    @session_list.each do |a_session| 
      @user = (a_session.data["user_id"].nil? ? nil : User.find(a_session.data["user_id"])) rescue nil
      @user_list << {:user=> @user, :session=>a_session.data} if not @user.nil?
    end 
    return @user_list
  end

  #  def name
  #    "#{first_name} #{last_name}"
  #  end
  
  

  private

  def password_non_blank
    errors.add(:password, "Missing password") if hashed_password.blank?
  end



  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end



  def self.encrypted_password(password, salt)
    string_to_hash = password + "wibble" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end


end