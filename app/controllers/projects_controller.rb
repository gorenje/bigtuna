class ProjectsController < ApplicationController
  before_filter :locate_project, :only => [:show, :build, :edit, :update, :remove, :destroy, :arrange, :feed]
  respond_to :js, :only => [:index, :show]

  def index
    @projects = Project.order("position ASC")
    respond_to do |format|
      format.cctray { render :action => 'index_cctray', :layout => false }
      format.all { render }
    end
  end

  def show
    respond_to do |format|
      format.png do
        send_data(File.read(File.join(Rails.root, "public", "images",
                                      build_image_for(@project.last_complete_build))),
                  :type => 'image/png', :disposition => 'inline')
      end

      format.all do
        @builds = @project.builds.order("created_at DESC").
          limit(@project.max_builds).includes(:project, :parts).all
        render
      end
    end
  end

  def feed
    @builds = @project.builds.order("created_at DESC").limit(@project.max_builds)
    respond_to do |format|
      format.atom
    end
  end

  def build
    @project.build!
    redirect_to(project_path(@project))
  rescue BigTuna::VCS::Error => e
    flash[:error] = e.message
    redirect_to project_path(@project)
  end

  def new
    @project = Project.new
    {
      :n => :name,
      :r => :vcs_source,
      :b => :vcs_branch,
      :m => :max_builds,
      :h => :hook_name
    }.each do |key, method_name|
      @project.send("#{method_name}=", params[key]) if params[key]
    end
  end

  def create
    @project = Project.new(params[:project])
    if @project.save
      redirect_to edit_project_path(@project)
    else
      render :new
    end
  end

  def edit
  end

  def update
    @project.update_attributes!(params[:project])
    redirect_to edit_project_path(@project)
  end

  def remove
  end

  def destroy
    @project.destroy
    redirect_to projects_path
  end

  def arrange
    if params[:up]
      @project.move_higher
    elsif params[:down]
      @project.move_lower
    end
    redirect_to projects_path
  end

  private

  def locate_project
    @project = Project.find(params[:id])
  end

  def build_image_for(build)
    case build.status.to_s
    when Build::STATUS_OK     then 'stable.png'
    when Build::STATUS_FAILED then 'unstable.png'
    else 'unknown.png'
    end
  end
end
