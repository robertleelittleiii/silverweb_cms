class PageTemplate < ActiveRecord::Base
  
    versioned only: [:title, :description, :body]

  
  
end
