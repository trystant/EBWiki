module AnalyticsHelper
  def number_of_incidents_by_day
    line_chart Article.all.group_by_day(:date).count
  end
end
