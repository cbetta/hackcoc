class AddSecretIdToSupporter < ActiveRecord::Migration[5.0]
  def change
    add_column :supporters, :access_token, :string
    add_column :supporters, :access_token_created_on, :datetime
  end
end
