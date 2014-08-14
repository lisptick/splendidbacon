class NotificationsController < ApplicationController
  before_filter :current_context
  def new
    @context = context
  end

  def create
    @context = context
    @notification = @context.notifications.find_or_create_by_user_id(current_user.id)
    respond_to do |format|
      format.js
      format.html { redirect_to context_url(@context)}
    end
  end
  
  def destroy
    @context = context
    notification = @context.notifications.where(:user_id => current_user.id).first
    notification.destroy if notification
    respond_to do |format|
      format.js
      format.html { redirect_to context_url(@context)}
    end
  end
  
  protected
  
  def current_context
    unless context
      raise ActiveRecord::RecordNotFound
    end
  end

  private
  def context
    if params[:organization_id]
      id = params[:organization_id]
      Organization.find(params[:organization_id])
    else
      id = params[:project_id]
      Project.find(params[:project_id])
    end
  end

  def context_url(context)
    if Project === context
      project_path(context)
    else
      organization_path(context)
    end
  end
end
