class Valuation < ApplicationRecord
  include Monetizable

  belongs_to :account
  validates :account, :date, :value, presence: true
  after_commit :sync_account
  monetize :value

  scope :in_period, ->(period) { period.date_range.nil? ? all : where(date: period.date_range) }

  def self.to_series(account, period = Period.all)
    MoneySeries.new(
      in_period(period).order(:date),
      { trend_type: account.classification, amount_accessor: :value }
    )
  end

  private
    def sync_account
      self.account.sync_later
    end
end