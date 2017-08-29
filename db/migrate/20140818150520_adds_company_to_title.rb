class AddsCompanyToTitle < ActiveRecord::Migration[4.2]
  def change
    add_column :supporters, :company, :string
  end
end
