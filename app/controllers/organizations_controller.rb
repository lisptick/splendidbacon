class OrganizationsController < ApplicationController
  respond_to :html

  before_filter :authenticate_user!
  before_filter :current_organization, :only => [:timeline, :show, :completed, :edit, :update, :destroy, :feed]
  
  def index
    title "Organizations"
    @organizations = current_user.organizations
  end
  
  
  def timeline
    title "#{@organization.name} timeline"
    navigation :timeline
    @on_going_projects = @organization.projects.ongoing.on_time
    @late_projects = @organization.projects.ongoing.late
    if @on_going_projects.empty? && @late_projects.empty?
      no_background!
      render :template => "projects/ghost"
    end
  end

  def show
    title @organization.name
    navigation :dashboard
    no_background!
    @notification = @organization.notifications.where(:user_id => current_user.id).first
    if  params[:search].present?
      @projects = Project.search Riddle::Query.escape(params[:search]), :with => { :organization_id => @organization.id }, :match_mode => :boolean
    else
      @projects = @organization.projects.current
    end
    render :template => "projects/ghost" if @organization.projects.empty?
  end

  def completed
    title "#{@organization.name} Completed Projects"
    navigation :dashboard
    no_background!
  end
  
  def new
    title "New Organization"
    @organization = Organization.new
  end
  
  def create
    authorize! :create_organization, current_user
    @organization = Organization.new(params[:organization])
    if @organization.save
      Membership.create!(:user_id => current_user.id, :organization_id => @organization.id)
      #if the organization is public, all users should be a member
      if @organization.public?
        User.real.all.each do |user|
          user.organizations.find_by_id(@organization.id) ||
             Membership.create(:user_id => user.id, :organization_id => @organization.id)
        end
      end
      flash[:notice] = "Organization was successfully created."
      redirect_to edit_organization_path(@organization)
    else
      respond_with(@organization)
    end
    
  end
  
  def edit
    title "Edit '#{@organization.name}'"
    @invitation = Invitation.new
  end
  
  def update
    authorize! :update_organization, current_user
    if @organization.update_attributes(params[:organization])
      flash[:notice] = "Organization was successfully updated."
    end
    respond_with @organization
  end
  
  def destroy
    authorize! :destroy_organization, current_user
    @organization.destroy
    flash[:notice] = "Organization was successfully deleted."
    cookies.delete(:organization)
    redirect_to root_path
  end

  def feed
      @projects = @organization.projects.where('state!="completed"').all(:order => 'id DESC', :limit => 50)
      respond_to do |format|
        format.rss { render :layout => false }
      end
  end
  
  private

  def current_organization
    @organization = current_user.organizations.readonly(false).find(params[:id])
    cookies[:organization] = @organization.id
  rescue ActiveRecord::RecordNotFound
    cookies.delete(:organization)
    flash.keep
    redirect_to root_path
  end
  
end
