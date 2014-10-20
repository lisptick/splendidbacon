class PagesController < ApplicationController
  layout "homepage"

  before_filter :set_format

  def home
    if user_signed_in?
      flash.keep
      if organization_id = cookies[:organization] and organization_id
        redirect_to organization_path(organization_id)
      end
      if current_user.organizations.empty? and can? :create_organization, current_user
        redirect_to new_organization_path
      elsif !current_user.organizations.empty?
        redirect_to organization_path(current_user.organizations.first)
      end
    end
  end

  private

  def set_format
    request.format = :html if request.format.to_s.include? '*/*'
  end
end
