class CalendarController < ApplicationController
respond_to :json

  def get_events
    @articles = Article.all
    events = []
    @articles.each do |article|
      events << {:url => "#{article_path(article)}", :id => article.id, :title => "#{article.title}", :start => "#{article.date}",:end => "#{article.date}" }
    end
    render :text => events.to_json
  end

  def index
  end

end
