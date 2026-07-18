require 'rails_helper'

# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:user)).to be_valid
    end

    it 'requires an email' do
      user = build(:user, email: '')

      expect(user).not_to be_valid
    end

    it 'requires a unique email' do
      create(:user, email: 'dup@example.com')
      user = build(:user, email: 'dup@example.com')

      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('has already been taken')
    end
  end

  describe 'callbacks' do
    it 'creates a default account after create' do
      user = create(:user)

      expect(user.accounts.count).to eq(1)
    end
  end

  describe 'associations' do
    it 'destroys dependent sessions, orders, and accounts' do
      user = create(:user)
      create(:session, user: user)
      create(:order, user: user)
      accounts_count = user.accounts.count

      expect { user.destroy }.to change(Session, :count).by(-1)
        .and change(Order, :count).by(-1)
        .and change(Account, :count).by(-accounts_count)
    end
  end
end
