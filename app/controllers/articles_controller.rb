class ArticlesController < ApplicationController
  before_action :set_article, only: %i[ show ]

  # GET /articles or /articles.json
  def index
    search_term = params[:term].present? ? params[:term] : nil

    # Save the current query to the database
    UserQuery.create(query: search_term, user: current_user) if search_term
    # print query saved
    puts "query saved: #{search_term} ✅✅✅✅✅✅✅✅"

    # Find and update previous queries if the current query is more complete
    update_previous_queries(search_term)

    @articles = if search_term
      Article.search(search_term)
    else
      Article.all
    end

    respond_to do |format|
      format.js   # Add this line to handle JS format
      format.html
    end
  end


  # GET /articles/1 or /articles/1.json
  def show
  end

  # GET /articles/new
  def new
    @article = Article.new
  end

  # POST /articles or /articles.json
  def create
    @article = Article.new(article_params)

    respond_to do |format|
      if @article.save
        format.html { redirect_to article_url(@article), notice: "Article was successfully created." }
        format.json { render :show, status: :created, location: @article }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def article_params
      params.require(:article).permit(:title, :body)
    end

    private

  def update_previous_queries(new_query)
    return unless new_query

    previous_queries = UserQuery.where.not(id: nil)
    previous_queries.each do |query|
      if new_query.include?(query.query) && query.query != new_query
        # If the new query is more complete, delete the previous query
        query.destroy
        puts "query deleted: #{query.query} ❌❌❌❌❌❌❌❌"
      elsif query.query.include?(new_query)
        # If the previous query is more complete, stop the loop
        return
      end
    end
  end
end
