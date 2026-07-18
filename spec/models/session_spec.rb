require 'rails_helper'

# == Schema Information
#
# Table name: sessions
#
#  id         :uuid             not null, primary key
#  expires_at :datetime         not null
#  token      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :uuid             not null
#
# Indexes
#
#  index_sessions_on_token    (token) UNIQUE
#  index_sessions_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
RSpec.describe Session, type: :model do
  describe 'callbacks' do
    it 'generates a token before create' do
      session = create(:session)

      expect(session.token).to be_present
    end

    it 'defaults expires_at to 30 days from now' do
      session = create(:session)

      expect(session.expires_at).to be_within(1.minute).of(30.days.from_now)
    end

    it 'does not overwrite an explicitly set expires_at' do
      expires_at = 1.day.from_now
      session = create(:session, expires_at: expires_at)

      expect(session.expires_at).to be_within(1.second).of(expires_at)
    end
  end

  describe '.active' do
    it 'includes sessions that have not expired' do
      active_session = create(:session, expires_at: 1.day.from_now)

      expect(Session.active).to include(active_session)
    end

    it 'excludes sessions that have expired' do
      expired_session = create(:session, expires_at: 1.day.ago)

      expect(Session.active).not_to include(expired_session)
    end
  end

  describe '#expired?' do
    it 'is true when expires_at is in the past' do
      session = create(:session, expires_at: 1.day.ago)

      expect(session).to be_expired
    end

    it 'is false when expires_at is in the future' do
      session = create(:session, expires_at: 1.day.from_now)

      expect(session).not_to be_expired
    end
  end
end
