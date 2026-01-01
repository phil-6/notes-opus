class Invitation < ApplicationRecord
  belongs_to :inviter, class_name: "User"

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true
  validate :email_not_already_registered, on: :create

  before_validation :generate_token, on: :create
  before_validation :set_expiry, on: :create

  scope :pending, -> { where(accepted_at: nil).where("expires_at > ?", Time.current) }
  scope :expired, -> { where("expires_at <= ?", Time.current) }

  def accepted?
    accepted_at.present?
  end

  def expired?
    expires_at <= Time.current
  end

  def accept!(user)
    return false if accepted? || expired?

    transaction do
      update!(accepted_at: Time.current)
      # Create mutual connections
      inviter.connections_as_user.find_or_create_by!(connected_user: user)
      user.connections_as_user.find_or_create_by!(connected_user: inviter)
    end
    true
  end

  def invitation_url
    Rails.application.routes.url_helpers.new_registration_url(invitation_token: token, host: ENV.fetch("APP_HOST", "localhost:3000"))
  end

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end

  def set_expiry
    self.expires_at ||= 7.days.from_now
  end

  def email_not_already_registered
    if User.exists?(email_address: email_address)
      errors.add(:email_address, :already_registered)
    end
  end
end
