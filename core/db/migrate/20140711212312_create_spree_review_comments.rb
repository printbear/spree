class CreateSpreeReviewComments < ActiveRecord::Migration
  def change
    create_table :spree_review_comments do |t|
      t.references :user, index: true
      t.references :order, index: true
      t.text :comment
      t.string :previous_state
      t.string :new_state

      t.timestamps
    end
  end
end
