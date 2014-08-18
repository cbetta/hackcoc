class Supporter < ActiveRecord::Base
  validates :name, presence: true
  validates :url, presence: true, url: true
  validates :email, presence: true, email: true
  validates :title, presence: true
  validates :company, presence: true
  validates :url, presence: true, if: :is_custom
  validates :hack, presence: true, if: :is_custom
  validates :phone, presence: true, if: :is_custom
  validates :slug, uniqueness: true, if: :is_custom

  after_create :generate_slug

  private

  def generate_slug
    return unless slug.blank?
    sanitized_hack = hack.downcase.gsub(/\W/, ' ').split.join("_")
    self.slug = "#{id}-#{sanitized_hack}"
    self.save!
  end
end
