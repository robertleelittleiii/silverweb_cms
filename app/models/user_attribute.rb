class UserAttribute < ActiveRecord::Base
    belongs_to :user, optional: true



end

