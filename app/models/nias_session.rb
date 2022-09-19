class NiasSession < ApplicationRecord
  belongs_to :user, optional: true

  validates :session_index, presence: true
  validates :subject_id, presence: true
  validates :subject_id_format, presence: true
  validates :user_type, presence: true
  validates :login_status, presence: true

  enum user_type: [:local, :non_local]
  enum login_status: [:authenticated, :login_denied, :login_finished]
  enum logout_status: [:requested, :logout_denied, :logout_finished ]
end
