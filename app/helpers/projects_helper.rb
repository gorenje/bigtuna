module ProjectsHelper
  def format_time(time, format = :iso)
    I18n.l time, :format => format
  end

  # Re-map our project statuses to match the project statuses recognized
  # by CCTray.Net
  def map_to_cctray_build_status(project_status)
    case project_status.to_s
    when Build::STATUS_OK then 'Success'
    when Build::STATUS_FAILED then 'Failure'
    else 'Unknown'
    end
  end

  # Re-map our build activities to match the build activities recognized
  # by CCTray.Net
  def map_to_cctray_project_activity(builder_state)
    case builder_state.to_s
    when Build::STATUS_IN_QUEUE then 'Building'
    when Build::STATUS_PROGRESS then 'Building'
    when Build::STATUS_OK then 'Sleeping'
    else 'Unknown'
    end
  end

  def list_of_git_branches(project)
    options_for_select(`git ls-remote #{project.vcs_source}`.split.
      select { |a| a =~ /refs\/heads/ }.
                       collect { |a| a.gsub( /refs\/heads\//, '') }.
                       sort_by { |a| a =~ /issue_([0-9]+)/ ? $1.to_i : 0 },
                       project.vcs_branch)
  end
end
