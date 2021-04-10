module Auth
  module Model::OauthUser
    extend ActiveSupport::Concern

    included do
      #t.index [:uid, :provider], unique: true
      attribute :type, :string
      attribute :provider, :string
      attribute :uid, :string
      attribute :unionid, :string, index: true
      attribute :app_id, :string
      attribute :name, :string
      attribute :avatar_url, :string
      attribute :state, :string
      attribute :access_token, :string
      attribute :expires_at, :datetime
      attribute :refresh_token, :string
      attribute :extra, :json, default: {}

      belongs_to :account, optional: true, inverse_of: :oauth_users
      belongs_to :user, optional: true
      has_one :same_oauth_user, -> (o){ where.not(id: o.id).where.not(unionid: nil).where.not(user_id: nil) }, class_name: self.name, foreign_key: :unionid, primary_key: :unionid
      has_many :same_oauth_users, -> (o){ where.not(id: o.id).where.not(unionid: nil) }, class_name: self.name, foreign_key: :unionid, primary_key: :unionid

      validates :provider, presence: true
      validates :uid, presence: true

      before_validation do
        # todo better user sync logic
        self.user = self.account&.user if account_id_changed?
      end
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
