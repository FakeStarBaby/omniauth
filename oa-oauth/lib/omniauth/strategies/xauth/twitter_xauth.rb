require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class TwitterXAuth < OmniAuth::Strategies::XAuth
      def initialize(app, consumer_key=nil, consumer_secret=nil, options={}, &block)
        client_options = {
          :site => 'https://api.twitter.com',
        }
        super(app, :TwitterXAuth, consumer_key, consumer_secret, client_options, options, &block)
      end

      def user_data
        @data ||= MultiJson.decode(@access_token.get('/1/account/verify_credentials.json').body)
      end

      def user_info
        {
          'nickname' => user_data['screen_name'],
          'name' => user_data['name'] || user_data['screen_name'],
          'location' => user_data['location'],
          'image' => user_data['profile_image_url'],
          'description' => user_data['description'],
          'urls' => {
            'Website' => user_data['url'],
            'Twitter' => 'http://twitter.com/' + user_data['screen_name'],
          },
        }
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super,
          {
            'uid' => user_data['id'],
            'user_info' => user_info,
          }
        )
      end

    end
  end
end