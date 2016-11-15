class AddMaintainerAndSponsors < ActiveRecord::Migration[5.0]
  def change
    add_column :supporters, :maintainer, :boolean, default: false
    add_column :supporters, :sponsor, :boolean, default: false
  end
end
