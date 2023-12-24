# Realtime Search & Analytics

## Overview

This is a simple application that allows you to search for a term from a magnitude of articles and see the results in real time. The application is built using Ruby on Rails, Elasticsearch, and PostgreSQL.

[Elasticsearch](https://www.elastic.co/products/elasticsearch) is a search engine that allows you to search through large amounts of data in real time. It is built on top of [Lucene](https://lucene.apache.org/), a Java based search engine. Elasticsearch is a distributed search engine that allows you to scale horizontally. It is also schema-less, which means you can index data without having to define a schema first. This makes it very fast and can search over **500,000 documents in less than a second**.

I have also made use of [Searchkick](https://github.com/ankane/searchkick) which is a Ruby gem that allows you to easily integrate Elasticsearch into your Rails application. It is very easy to use and has a lot of features that make it very powerful, especially when it comes to querying data.

Live demo: [real-time-search-analytics](https://real-time-search-analytics.onrender.com/)

## Search Analytics

The search analytics algorithm is very simple. It is based how complete the search term is. For example, if you search for `ruby`, the search engine will return all the articles that contain the word `ruby`. However, if you search for `ruby on rails`, the search engine will return all the articles that contains both `ruby` and `on` and `rails`. Here is part of the code that implements this:

```ruby
# path app\controllers\articles_controller.rb
class ArticlesController < ApplicationController
    # ...
    @debounced_query = debounce(1000) { search_term }

    if @debounced_query
      UserQuery.create(query: @debounced_query, user: current_user)
      update_previous_queries(@debounced_query)
    end

    @articles = []

    if @debounced_query
      # use searchkick to search for the query
      @articles = Article.search(@debounced_query, fields: [:title, :body], match: :word_middle)
    else
      @articles = Article.all
    end

    # ...
  end
```

I also made use of a custom `debounce` function to prevent saving the same query multiple times. This is the code for the `debounce` function:

```ruby

# ...
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
        end
      # delete previous queries if the new query is more complete
      elsif new_query.include?(query.query)
        # If the new query is more complete, delete the previous query
        query.destroy
        # dev logging 😅
      elsif query.query.include?(new_query)
        # If the previous query is more complete, stop the loop
        return
      end
    end
    end
```

## Getting Started

### Prerequisites

- Ruby 3.2.2
- Rails 7.1.2
- PostgreSQL 13.3
- Elasticsearch 7.13.4

### Installation

1. Clone the repo

   ```sh
   git clone https://github.com/hassanShakur/real-time-search-analytics
   ```

2. Install dependencies

   ```sh
   bundle install
   ```

3. Create and migrate the database

   ```sh
   rake db:setup
   ```

4. Start the Elasticsearch server
   For this, you can get up and running with [Elastic cloud](https://www.elastic.co/cloud/) or you can install it locally. For local installation, you can follow the instructions [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/install-elasticsearch.html). I have used the cloud version for this project, therefore you can adjust the following parameters in the `config/initilizers/elasticseach.rb` file to match your cloud instance:

   ```ruby
    Elasticsearch::Model.client = Elasticsearch::Client.new(
        api_key: ENV['ELASTIC_API_KEY'],
        cloud_id: ENV['ELASTIC_CLOUD_ID']
    )

    Searchkick.client = Elasticsearch::Client.new(
        api_key: ENV['ELASTIC_API_KEY'],
        cloud_id: ENV['ELASTIC_CLOUD_ID']
    )
   ```

5. Start the Rails server
   For this also ensure that you have the following environment variables set in a `.env` file:

   ```env
    SEARCH_ENGINE_DATABASE_USERNAME=your_username
    SEARCH_ENGINE_DATABASE_PASSWORD=your_password
    ELASTIC_API_KEY=your_api_key
    ELASTIC_CLOUD_ID=your_cloud_id
   ```

   ```sh
    rails s
   ```

   You can optionally run the following command to populate the database with some articles:

   ```sh
    rake db:seed
   ```

6. Open the application in your browser

```sh
 http://localhost:3000
```

## References

- [Elasticsearch](https://www.elastic.co/products/elasticsearch)
- [Searchkick](https://github.com/ankane/searchkick)
- [elasticsearch-rails](https://github.com/elastic/elasticsearch-rails)
- [elasticsearch-model](https://www.rubydoc.info/gems/elasticsearch-model/)
