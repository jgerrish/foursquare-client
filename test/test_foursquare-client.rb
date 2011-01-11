require 'helper'
require 'fakeweb'

FakeWeb.allow_net_connect = false

class TestFoursquareClient < Test::Unit::TestCase
  def setup
    @foursquare_access_token = "aaaa"

    # users endpoint uris
    FakeWeb.register_uri(:get, 'https://api.foursquare.com/v2/users/self?oauth_token=aaaa',
                         :response => fixture_file('foursquare_user_v2.json'))
    FakeWeb.register_uri(:get, 'https://api.foursquare.com/v2/users/1?oauth_token=aaaa',
                         :response => fixture_file('foursquare_user_v2.json'))
    # checkins endpoint uris
    FakeWeb.register_uri(:get, 'https://api.foursquare.com/v2/checkins/aaaaaaaaaaaaaaaaaaaaaaaa?oauth_token=aaaa',
                         :response => fixture_file('foursquare_checkins_v2.json'))
    # venues endpoint uris
    FakeWeb.register_uri(:get, 'https://api.foursquare.com/v2/venues/4a778ddff964a520cae41fe3?oauth_token=aaaa',
                         :response => fixture_file('foursquare_venues_v2.json'))
    # friends endpoint uris
    FakeWeb.register_uri(:get, 'https://api.foursquare.com/v2/users/self/friends?oauth_token=aaaa',
                         :response => fixture_file('foursquare_users_self_friends_v2.json'))
    FakeWeb.register_uri(:get, 'https://api.foursquare.com/v2/users/1/friends?oauth_token=aaaa',
                         :response => fixture_file('foursquare_users_self_friends_v2.json'))

    # Code 400 test for bad user id
    FakeWeb.register_uri(:get, 'https://api.foursquare.com/v2/users/baduserid?oauth_token=aaaa',
                         :response => fixture_file('foursquare_bad_user_id_v2.json'))

    # Test code 401 unauthorized
    FakeWeb.register_uri(:get, 'https://api.foursquare.com/v2/users/self?oauth_token=badtoken',
                         :response => fixture_file('foursquare_bad_oauth_v2.json'))

  end

  # Test the users method
  def test_foursquare_users
    # Test retrieving the current user associated with the oauth2 access token
    user = foursquare.users
    assert user
    assert_equal "1", user.id

    # Test retrieving a specific user
    user = foursquare.users("1")
    assert user
    assert_equal "1", user.id
  end

  # Test the checkins method
  def test_foursquare_checkins
    # Test retrieving a specific checkin id
    checkin_id = "aaaaaaaaaaaaaaaaaaaaaaaa"
    checkins = foursquare.checkins(checkin_id)
    assert checkins
    assert_equal checkin_id, checkins.id
  end

  # Test the venues method
  def test_foursquare_venues
    # Test retrieving a specific venue id
    venue_id = "4a778ddff964a520cae41fe3"
    venues = foursquare.venues(venue_id)
    assert venues
    assert_equal venue_id, venues.id
  end

  # Test the friends method
  def test_foursquare_friends
    # Test retrieving the current user's friends
    friends = foursquare.friends
    assert friends
    assert_equal 2, friends.count
    assert_equal "1", friends[0].id
    assert_equal "2", friends[1].id

    # Test retrieving a specific user's friends
    self_id = "1"
    friends = foursquare.friends(self_id)
    assert friends
    assert_equal 2, friends.count
    assert_equal "1", friends[0].id
    assert_equal "2", friends[1].id
  end

  def test_foursquare_bad_user_id
    assert_raise Foursquare::BadRequest do
      user = foursquare.users("baduserid")
    end
  end

  def test_foursquare_bad_oauth
    fs = Foursquare::Client.new("badtoken")
    assert_raise Foursquare::Unauthorized do
      user = fs.users
    end
  end

end
