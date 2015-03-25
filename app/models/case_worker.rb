class CaseWorker < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, # :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  has_many :case_worker_claims, dependent: :destroy
  has_many :claims, through: :case_worker_claims
end
