require './lib/racker'
use Rack::Reloader
use Rack::Static, urls: ['/assets'], root: 'codebreaker-web-template'
use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :expire_after => 2592000,
                           :secret => 'change_me',
                           :old_secret => 'also_change_me'
run Racker
