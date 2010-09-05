require File.expand_path('../test_helper', __FILE__)

class HttpPurgeTest < Test::Unit::TestCase
  test 'purges entries on PURGE requests' do
    respond_with do |request, response|
      case request.url
      when 'http://example.com/foo'
        response.headers.merge!('Cache-Control' => 'public, max-age=500')
      end
    end
    
    get 'http://example.com/foo'
    assert_cached 'http://example.com/foo'

    purge 'http://example.com/foo'
    assert_not_cached 'http://example.com/foo'
  end
end