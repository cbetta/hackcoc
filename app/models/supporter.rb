class Supporter < ActiveRecord::Base
  validates :name, presence: true
  validates :url, presence: true, url: true
  validates :email, presence: true, email: true, uniqueness: true
  validates :title, presence: true
  validates :company, presence: true
  validates :url, presence: true, if: :is_custom
  validates :hack, presence: true, if: :is_custom
  validates :phone, presence: true, phony_plausible: true, if: :is_custom
  validates :slug, uniqueness: true, if: :is_custom

  after_create :generate_slug

  scope :custom, -> { where(is_custom: true) }
  scope :supporting, -> { where(is_supporter: true) }
  scope :by_vip, -> { order("maintainer DESC, sponsor DESC, id ASC") }

  def generate_access_token
    self.access_token = SecureRandom.urlsafe_base64
    self.access_token_created_on = Time.now
    self.save!
  end

  private

  def generate_slug
    return unless slug.blank?
    sanitized_hack = hack.downcase.gsub(/\W/, ' ').split.join("_")
    self.slug = "#{id}-#{sanitized_hack}"
    self.save!
  end
end
