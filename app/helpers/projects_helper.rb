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
    when Build::STATUS_IN_QUEUE then 'CheckingModifications'
    when Build::STATUS_PROGRESS then 'Building'
    when Build::STATUS_OK then 'Sleeping'
    else 'Unknown'
    end
  end
end
