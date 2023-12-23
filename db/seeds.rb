# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# generate 30 fake articles
# 30.times do
#     Article.create(
#         title: Faker::Book.title,
#         body: Faker::Lorem.paragraph(sentence_count: 2, supplemental: false, random_sentences_to_add: 4),
#         user_id: 1
#     )
#     end
30.times do
  Article.create(
    title: Faker::Movie.quote,
    body: Faker::Quote.famous_last_words,
    user_id: 1
  )
end

Article.reindex
