class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_location
  
  def current_location
    return @current_location if @current_location

    @current_location ||= (
      query = params[:search][:query].to_s.strip rescue nil
      Location.new query unless query.blank? rescue nil
    )

    @current_location ||= Location.find(params[:location_id]) unless params[:location_id].blank? rescue nil

    @current_location ||= Location.new(session[:location_address]) if session[:location_address] rescue nil

    @current_location ||= (
      @client_ip = request.remote_ip
      @client_ip = request.env["HTTP_X_FORWARDED_FOR"] if @client_ip.blank?
      Location.new @client_ip unless @client_ip.blank? rescue nil
    )

    set_current_location @current_location

    @current_location
  end

  def set_current_location location
    @current_location = location
    session[:location_address] = location.address rescue nil
  end
end
