require 'hashie'
require 'httparty'

module Foursquare
  # Client for the v2 Foursquare API
  class Client
    include HTTParty
    FORMAT = 'json'

    # Initialize the Foursquare client with an oauth2 access token
    # and optional base endpoint URI
    def initialize(oauth_token, uri = 'https://api.foursquare.com/v2')
      @oauth_token = oauth_token
      self.class.base_uri uri
    end

    # Return a Foursquare user.
    # If the optional user_id is given, return the user info for the user-id.
    # If no argument is given, return the user info for the current user.
    def users(user_id = nil)
      if user_id
        url = '/users/' + user_id
      else
        url = '/users/self'
      end
      response = get(url)
      response.user
    end

    # Return checkin info for the given checkin id
    def checkins(checkin_id)
      if checkin_id
        url = '/checkins/' + checkin_id
      end
      response = get(url)
      response.checkin
    end

    # Return venue info for the given venue id
    def venues(venue_id)
      if venue_id
        url = '/venues/' + venue_id.to_s
      end
      response = get(url)
      response.venue
    end

    # Return a list of friends for the given user_id
    # If no user_id is given, return the current user's friends
    def friends(user_id = nil)
      if user_id
        url = '/users/' + user_id + '/friends'
      else
        url = '/users/self/friends'
      end
      response = get(url)
      response.friends.items
    end

    private

    def parse_response(response)
      raise_errors(response)
      response.response
    end

    def get(url)
      result = self.class.get(url, :query => { :oauth_token => @oauth_token } )
      result = Hashie::Mash.new(result)
      parse_response(result)
    end

    def raise_errors(response)
      message = "(#{response.meta.code}): #{response.meta.errorDetail}"
      case response.meta.code.to_i
      when 400
        raise BadRequest, message
      when 401
        raise Unauthorized, message
      when 403
        raise General, message
      when 404
        raise NotFound, message
      when 500
        raise InternalError, message
      when 502..503
        raise Unavailable, message
      end
    end  
  end

  class BadRequest        < StandardError; end
  class Unauthorized      < StandardError; end
  class General           < StandardError; end
  class Unavailable       < StandardError; end
  class InternalError     < StandardError; end
  class NotFound          < StandardError; end
end
