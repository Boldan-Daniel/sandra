require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe 'confirmation_email' do
    let(:user) { create(:user) }
    let(:mail) { UserMailer.confirmation_email(user) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Confirm your Account!')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['daniel@sandra.app'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Hello')
    end
  end

  describe '#reset_password' do
    let(:daniel) { create(:user, :reset_password) }
    let(:mail)   { UserMailer.reset_password(daniel) }

    it 'renders the header' do
      expect(mail.subject).to eq 'Reset your password'
      expect(mail.to).to eq [daniel.email]
      expect(mail.from).to eq ['daniel@sandra.app']
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Use the link below to reset your password')
    end
  end
end
