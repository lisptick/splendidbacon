class StatusesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :current_project

  respond_to :html
  respond_to :js, :only => [ :index ]

  def index
    @statuses = @project.statuses.page(params[:page])
  end

  def create
    @comment = @project.statuses.new(params[:status])
    @comment.user = current_user
    if @comment.link.present? and !@comment.source.present?
      @comment.source = URI.parse(@comment.link).host
    else
      @comment.source = "Comment"
      @comment.link = nil
    end

    if @comment.save
      flash[:notice] = "Comment saved"
    else
      flash[:alert] = "Comment not saved"
    end

    redirect_to project_path(@project)
  end

  private

  def current_project
    @project = Project.find(params[:project_id])
    raise ActiveRecord::RecordNotFound unless @project.organization.user_ids.include? current_user.id
  end
end
