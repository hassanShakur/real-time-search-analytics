class CreateUserQueries < ActiveRecord::Migration[7.1]
  def change
    create_table :user_queries do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :query

      t.timestamps
    end
  end
end
