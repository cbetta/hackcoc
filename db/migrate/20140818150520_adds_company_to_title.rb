class AddsCompanyToTitle < ActiveRecord::Migration
  def change
    add_column :supporters, :company, :string
  end
end
