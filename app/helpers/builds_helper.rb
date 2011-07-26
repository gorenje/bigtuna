module BuildsHelper
  # collect lines of "63 tests, 159 assertions, 0 failures, 0 errors" and sum together..
  def match_test_summary_line(txt, totals)
    if txt =~ /([0-9]+) tests, ([0-9]+) assertions, ([0-9]+) failures, ([0-9]+) errors/
      [totals[0] + $1.to_i, totals[1] + $2.to_i, totals[2] + $3.to_i, totals[3] + $4.to_i]
    else
      totals
    end
  end

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
