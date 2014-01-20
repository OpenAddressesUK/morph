class User < Owner
  # TODO Add :omniauthable
  devise :trackable, :omniauthable, :omniauth_providers => [:github]

  # Using American spelling to mirror GitHub naming
  def organizations
    octokit_client.organizations.map {|data| Organization.find_or_create(data.id, data.login) }
  end

  def octokit_client
    Octokit::Client.new :access_token => access_token
  end

  def self.find_for_github_oauth(auth, signed_in_resource=nil)
    user = User.find_or_create_by(:provider => auth.provider, :uid => auth.uid)
    user.update_attributes(nickname: auth.info.nickname, name:auth.info.name,
      access_token: auth.credentials.token,
      gravatar_id: auth.extra.raw_info.gravatar_id,
      blog: auth.extra.raw_info.blog,
      company: auth.extra.raw_info.company, email:auth.info.email)
    user
  end

  def refresh_info_from_github!
    user = Octokit.user(nickname)
    update_attributes(name:user.name,
        # image: auth.info.image,
        gravatar_id: user.gravatar_id,
        blog: user.blog,
        company: user.company,
        email: user.email)
  end
end
