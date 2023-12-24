# require 'elasticsearch/model'

class Article < ApplicationRecord
    belongs_to :user
    validates :title, presence: true
    validates :body, presence: true, length: { minimum: 10 }

    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    # regenerating elasticsearch index for docs after updating or deleting
    after_commit on: [:create, :update] do
        __elasticsearch__.index_document
    end

    # this is a third party gem that allows us to search using elasticsearch
    searchkick

    def search_data
        {
            title: title,
            body: body
        }
    end
end


# Index creation right at import time is not encouraged.
# Typically, you would call create_index! asynchronously (e.g. in a cron job)
# However, I am adding it here so that this usage example can run correctly.
# Article.__elasticsearch__.create_index!
# Article.import

# @articles = Article.search('foobar').records
