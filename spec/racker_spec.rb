
require 'bundler/setup'
require 'spec_helper'
require_relative '../lib/racker.rb'

RSpec.describe Racker do
  def app
    Rack::Builder.parse_file('config.ru').first
  end

  context 'session_id' do
    let(:user_name) { 'John Doe' }
    let(:env) { { 'HTTP_COOKIE' => "user_name=#{user_name}" } }

    it 'returns ok status' do
      get '/menu', {}, env
      expect(last_response.body).to include(user_name)
    end
  end
end
