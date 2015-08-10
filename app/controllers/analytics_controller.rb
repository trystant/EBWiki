class AnalyticsController < ApplicationController
  def show
    @full_width_content = true
  	@visits = Visit.all
  	@views = Ahoy::Event.where(name: '$view' )
  end
end
