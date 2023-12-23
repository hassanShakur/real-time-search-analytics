class ArticlesController < ApplicationController
  before_action :set_article, only: %i[show]

  # GET /articles or /articles.json
  def index
    search_term = params[:term].present? ? params[:term] : nil

    # Save the current query to the database after a debounce
    @debounced_query = debounce(1000) { search_term }

    if @debounced_query
      UserQuery.create(query: @debounced_query, user: current_user)
      # dev logging 😅
      # puts "Query saved: #{@debounced_query} ✅✅✅✅✅✅✅✅"
      update_previous_queries(@debounced_query)
    end

    @articles = if @debounced_query
      Article.search(@debounced_query)
    else
      Article.all
    end

    respond_to do |format|
      format.js   # js formatting
      format.html
    end
  end

  def show
  end

  private

  def debounce(time)
    return if time.nil?

    current_time = Time.now.to_f
    @last_called ||= 0.0

    if current_time - @last_called >= time / 1000.0
      @last_called = current_time
      yield
    end
  end

  def update_previous_queries(new_query)
    return unless new_query

    previous_queries = UserQuery.where.not(id: nil)
    previous_queries.each do |query|
      if new_query.include?(query.query) && query.query != new_query
        # If the new query is more complete, delete the previous query
        query.destroy
        # dev logging 😅
        puts "Query deleted: #{query.query} ❌❌❌❌❌❌❌❌"
      elsif query.query.include?(new_query)
        # If the previous query is more complete, stop the loop
        return
      end
    end
  end
end
