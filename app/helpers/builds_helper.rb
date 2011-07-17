module BuildsHelper
  def css_class_for_line(txt)
    case txt[0..2]
      when " ==" then "sbinfo"
      when " !!" then "sbaction"
      when " --" then "sberror"
      when " **" then "sbwarning"
      when " ++" then "sbwtf"
      else ""
    end
  end
end
