class SpellingController < ApplicationController
  include SilverwebCms::Spelling
  skip_before_filter  :verify_authenticity_token

  def index
    headers["Content-Type"] = "text/plain"
    headers["charset"] = "utf-8"
    suggestions = check_spelling(params[:text], params[:method], params[:lang])
    results = {"id" => nil, "result" => suggestions, 'error' => nil}
    render :json => suggestions
  end
  
  protected

  def authorize
    return true
  end

  def authenticate
    return true
  end

end