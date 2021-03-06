module Auth
  module Model::OauthUser
    extend ActiveSupport::Concern

    included do
      #t.index [:uid, :provider], unique: true
      attribute :type, :string
      attribute :provider, :string
      attribute :uid, :string
      attribute :unionid, :string, index: true
      attribute :appid, :string
      attribute :name, :string
      attribute :avatar_url, :string
      attribute :state, :string
      attribute :access_token, :string
      attribute :expires_at, :datetime
      attribute :refresh_token, :string
      attribute :extra, :json, default: {}

      belongs_to :account, optional: true, inverse_of: :oauth_users
      has_one :user, through: :account
      has_many :authorized_tokens, through: :account
      has_one :same_oauth_user, -> (o){ where.not(id: o.id).where.not(unionid: nil).where.not(account_id: nil) }, class_name: self.name, foreign_key: :unionid, primary_key: :unionid
      has_many :same_oauth_users, -> (o){ where.not(id: o.id).where.not(unionid: nil) }, class_name: self.name, foreign_key: :unionid, primary_key: :unionid

      validates :provider, presence: true
      validates :uid, presence: true

      after_save_commit :sync_to_user, if: -> { (saved_changes.keys & ['name', 'avatar_url']) && avatar_url.present? }
    end

    def sync_to_user
      UserCopyAvatarJob.perform_later(self)
    end

    def save_info(info_params)
    end

    def strategy
    end

    def generate_auth_token(**options)
      JwtHelper.generate_jwt_token(id, password_digest, options)
    end

    def refresh_token!
      client = strategy
      token = OAuth2::AccessToken.new client, self.access_token, { expires_at: self.expires_at.to_i, refresh_token: self.refresh_token }
      token.refresh!
    end

  end
end
