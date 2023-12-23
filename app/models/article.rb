# require 'elasticsearch/model'

class Article < ApplicationRecord
    belongs_to :user
    validates :title, presence: true
    validates :body, presence: true, length: { minimum: 10 }

    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    # searchkick
    searchkick

    def search_data
        {
            title: title,
            body: body
        }
    end

    # def self.search(query)
    #     __elasticsearch__.search(
    #         {
    #             query: {
    #                 multi_match: {
    #                     query: query,
    #                     fields: ['title^10', 'body']
    #                 }
    #             },
    #             highlight: {
    #                 pre_tags: ['<mark>'],
    #                 post_tags: ['</mark>'],
    #                 fields: {
    #                     title: {},
    #                     body: {}
    #                 }
    #             }
    #         }
    #     )
    # end

end



# class Article < ActiveRecord::Base
#   include Elasticsearch::Model
#   include Elasticsearch::Model::Callbacks
# end

# Index creation right at import time is not encouraged.
# Typically, you would call create_index! asynchronously (e.g. in a cron job)
# However, we are adding it here so that this usage example can run correctly.
# Article.__elasticsearch__.create_index!
# Article.import

# @articles = Article.search('foobar').records