class ProjectsController < ApplicationController
  respond_to :html

  before_filter :authenticate_user!, :except => [:guest]
  before_filter :current_project, :only => [:show, :edit, :update, :destroy, :enable_guest_access, :disable_guest_access, :feed]
  before_filter :current_organization, :only => [:new, :create]

  def show
    title @project.name
    @comment ||= @project.statuses.new
    @notification = @project.notifications.where(:user_id => current_user.id).first
    @statuses = @project.statuses.page(params[:page])
  end

  def guest
    @project = Project.find(params[:id])
    unless @project.authenticate_guest_access(params[:token])
      redirect_to root_path, :alert => "You're not allowed to view that project. Please check the link."
    else
      title "[Guest access] #{@project.name}"
      render :layout => "guest"
    end
  end

  def new
    title "New project for #{@organization.name}"
    @project = Project.new(:state => :ongoing)
  end

  def create
    authorize! :create_project, current_user, @organization
    @project = @organization.projects.new(params[:project])
    @project.user = current_user
    flash[:notice] = "Project was successfully created." if @project.save
    respond_with @project
  end

  def edit
    title "Edit '#{@project.name}'"
  end

  def update
    authorize! :update, @project
    if @project.update_attributes(params[:project])
      flash[:notice] = "Project was successfully updated."
    end
    respond_with @project
  end

  def destroy
    authorize! :destroy, @project
    @project.destroy
    flash[:notice] = "Project was successfully deleted."
    redirect_to organization_path(@project.organization)
  end

  def enable_guest_access
    @project.enable_guest_access
    flash[:notice] = "Guest access was enabled. Link to the guest view is in the sidebar."
    respond_with @project
  end

  def disable_guest_access
    @project.disable_guest_access
    flash[:notice] = "Guest access was disabled. Guest view can't be viewed anymore."
    respond_with @project
  end

  def feed
      @statuses = @project.statuses.all(:order => 'id DESC', :limit => 50)
      respond_to do |format|
        format.rss { render :layout => false }
      end
  end

  private
  
  def current_project
    @project = Project.find(params[:id])
    unless @project.organization.user_ids.include?(current_user.id)
      raise ActiveRecord::RecordNotFound
    end
    @organization = @project.organization
    cookies[:organization] = @organization.id
  end

  def current_organization
    @organization = current_user.organizations.find(cookies[:organization])
    unless @organization.present?
      flash[:alert] = "You must choose an organization first!"
      redirect_to organizations_path
    end
    
  rescue ActiveRecord::RecordNotFound
    cookies.delete(:organization)
    flash[:alert] = "You must choose an organization first!"
    redirect_to organizations_path
  end

end
