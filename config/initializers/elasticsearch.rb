Elasticsearch::Model.client = Elasticsearch::Client.new(
    api_key: ENV['ELASTIC_API_KEY'],
    cloud_id: ENV['ELASTIC_CLOUD_ID']
)

Searchkick.client = Elasticsearch::Client.new(
    api_key: ENV['ELASTIC_API_KEY'],
    cloud_id: ENV['ELASTIC_CLOUD_ID']
)
