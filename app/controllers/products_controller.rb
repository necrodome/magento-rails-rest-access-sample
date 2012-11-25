class ProductsController < ApplicationController
  CONSUMER_KEY = "wt587n7q7tbi88towihn6x5z0gsmll5w"
  CONSUMER_SECRET = "qyevohicp51ha34xuk9vzojjm1tfufzg"

  def index
    # This is checking the session for access token
    # You can use a database table as well.
    if session[:access_token].blank?
      request_token = consumer.get_request_token(:oauth_callback => oauth_url)
      # Let's save request token as we will need it when magento returns back
      session[:request_token] = request_token.token
      session[:request_token_secret] = request_token.secret
      redirect_to request_token.authorize_url and return
    end

    # We have our access token, so we can query the Magento API
    render :text => session[:access_token].get('/api/rest/products').body
  end

  # Oauth dance
  # This is the callback url for oauth, defined in routes file
  def oauth
    request_token = OAuth::RequestToken.new(consumer, session[:request_token], session[:request_token_secret])
    puts request_token.inspect
    access_token = request_token.get_access_token( :oauth_verifier => params[:oauth_verifier] )
    # Let's save the access token
    session[:access_token] = access_token
    redirect_to :action => "index"
  end


  private
  def consumer
    @consumer ||= OAuth::Consumer.new(CONSUMER_KEY, CONSUMER_SECRET,
                               :site => "http://192.168.1.107/magento",
                               :request_token_path => "/index.php/oauth/initiate",
                               :authorize_path => "/index.php/admin/oauth_authorize",
                               :access_token_path => "/index.php/oauth/token",
                               :http_method => :get)
  end

end
