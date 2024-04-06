class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, :phone, :date_of_birth, :gender, :address, presence: true

  # Enum gender
  enum gender: { male: 1, female: 2, other: 3 }

  def self.build_user_objects_from_json(result)
    users = []
    result.each do |user|
      users << User.new(user)
    end

    users
  end
end
