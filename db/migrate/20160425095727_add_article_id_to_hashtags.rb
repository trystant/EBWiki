class AddArticleIdToHashtags < ActiveRecord::Migration
  def change
    add_column :hashtags, :article_id, :integer
  end
end
