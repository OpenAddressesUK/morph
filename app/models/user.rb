class User < ActiveRecord::Base
  # TODO Add :omniauthable
  devise :trackable, :omniauthable, :omniauth_providers => [:github]

  extend FriendlyId
  friendly_id :nickname, use: :finders

  def self.find_for_github_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user
      user = User.create(nickname: auth.info.nickname, name:auth.info.name,
        provider:auth.provider, uid:auth.uid, access_token: auth.credentials.token)
    end
    user
  end
end