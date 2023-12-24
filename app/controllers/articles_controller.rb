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
      puts "Query saved: #{@debounced_query} ✅✅✅✅✅✅✅✅"
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

  # display the query analytics
  def analytics
    puts "Current user: #{current_user.email}"
    # select all queries from the current user
    @user_queries = UserQuery.where(user: current_user)
  end

  def show
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)
    @article.user = current_user

    if @article.save
      redirect_to @article, notice: 'Article was successfully created.'
    else
      render :new
    end
  end

  private

  def set_article
    @article = Article.find(params[:id])
  end

  def article_params
    # Use require and permit to whitelist the allowed attributes
    params.require(:article).permit(:title, :body)
  end

  # Debounce function to prevent saving the same query multiple times
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
    found_matches = 0
    previous_queries.each do |query|
      # delete extra matches if more than 1 exact match is found
      if query.query == new_query
        found_matches += 1
        if found_matches > 1
          query.destroy
          # dev logging 😅
          puts "Query deleted: #{query.query} ❌❌❌❌❌❌❌❌"
        end
      # delete previous queries if the new query is more complete 
      elsif new_query.include?(query.query)
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
