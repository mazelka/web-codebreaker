
require 'bundler/setup'
require 'spec_helper'
require_relative '../lib/racker.rb'

RSpec.describe Racker do
  path = File.expand_path('..', __dir__) + '/lib/storage/statistics_test.yaml'
  StatisticsHelper::PATH_TO_STATISTICS = path

  def app
    Rack::Builder.parse_file('config.ru').first
  end

  after(:each) do
    File.delete(path) if File.file?(path)
  end

  context 'session_id' do
    it 'sets cookies with session' do
      get '/menu'
      expect(last_request.session.key?(:session_id)).to be true
    end
  end

  context 'path' do
    it 'navigates to menu' do
      get '/menu'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('Start the game!')
    end

    it 'navigates to rules' do
      get '/rules'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('Rules:')
    end

    it 'navigates to statistics' do
      get '/statistics'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('Top of Players:')
    end

    it 'shows 404 if page does not exist' do
      get '/not_exists'
      expect(last_response.status).to eq(404)
      expect(last_response.body).to include('Not Found')
    end

    context 'redirect' do
      it 'redirects to menu from win if game is not saved' do
        get '/win'
        follow_redirect!
        expect(last_response.status).to eq(200)
        expect(last_request.url).to include('/menu')
      end

      it 'redirects to menu from lose if game is not saved' do
        get '/lose'
        follow_redirect!
        expect(last_response.status).to eq(200)
        expect(last_request.url).to include('/menu')
      end
    end

    context 'lose game' do
      session_id = 'b8f6930520a0b876e2dc1bd8d00bb2fa393c6246a6dc21482b6fa00eaab375a0'
      rack_session = 'BAh7CkkiD3Nlc3Npb25faWQGOgZFVEkiRWI4ZjY5MzA1MjBhMGI4NzZlMmRj%0AMWJkOGQwMGJiMmZhMzkzYzYyNDZhNmRjMjE0ODJiNmZhMDBlYWFiMzc1YTAG%0AOwBGSSIJaW5pdAY7AEZUSSIJZ2FtZQY7AEZJIgIDAS0tLSAhcnVieS9vYmpl%0AY3Q6R2FtZQpzdGF0czogIXJ1Ynkvb2JqZWN0OkdhbWVTdGF0aXN0aWMKICBu%0AYW1lOiBuYW5hbmEKICBhdHRlbXB0c191c2VkOiAxMAogIGhpbnRzX3VzZWQ6%0AIDAKICBkYXRlOiAyMDE5LTA2LTA1IDE4OjU0CiAgZGlmZmljdWx0eTogMgog%0AIGF0dGVtcHRzX3RvdGFsOiAxMAogIGhpbnRzX3RvdGFsOiAxCndvbjogZmFs%0Ac2UKc2VjcmV0X2NvZGU6Ci0gNAotIDYKLSA2Ci0gMwphdmFpbGFibGVfaGlu%0AdHM6Ci0gNAotIDYKLSA2Ci0gMwoGOwBUSSILcmVzdWx0BjsARlsASSIKaGlu%0AdHMGOwBGWwA%3D%0A--9b83a468d3db48f8e766467a6801521fec4fc342'
      let(:env) { { 'HTTP_COOKIE' => "rack.session=#{rack_session} " } }
      let(:env) { { 'rack.session' => { 'session_id' => session_id, 'game' => "--- !ruby/object:Game\nstats: !ruby/object:GameStatistic\n  name: nanana\n  attempts_used: 10\n  hints_used: 0\n  date: 2019-06-05 18:54\n  difficulty: 2\n  attempts_total: 10\n  hints_total: 1\nwon: false\nsecret_code:\n- 4\n- 6\n- 6\n- 3\navailable_hints:\n- 4\n- 6\n- 6\n- 3\n", 'result' => [], 'hints' => [] } } }

      it 'shows lose' do
        get '/lose', {}, env
        expect(last_response.status).to eq(200)
        expect(last_request.url).to include('/lose')
        expect(last_response.body).to include('Oops, nanana! You lose the game!')
      end
    end

    context 'win game' do
      session_id = 'bed266c6ebe450dff8637545f671342b12dbf091d02058984b4452cc48bfc574'
      rack_session = 'BAh7CkkiD3Nlc3Npb25faWQGOgZFVEkiRWJlZDI2NmM2ZWJlNDUwZGZmODYz%0ANzU0NWY2NzEzNDJiMTJkYmYwOTFkMDIwNTg5ODRiNDQ1MmNjNDhiZmM1NzQG%0AOwBGSSIJaW5pdAY7AEZUSSIJZ2FtZQY7AEZJIgH7LS0tICFydWJ5L29iamVj%0AdDpHYW1lCnN0YXRzOiAhcnVieS9vYmplY3Q6R2FtZVN0YXRpc3RpYwogIG5h%0AbWU6IEthc2hhCiAgYXR0ZW1wdHNfdXNlZDogMgogIGhpbnRzX3VzZWQ6IDEK%0AICBkYXRlOiAyMDE5LTA2LTA2IDEwOjMzCiAgZGlmZmljdWx0eTogMwogIGF0%0AdGVtcHRzX3RvdGFsOiA1CiAgaGludHNfdG90YWw6IDEKd29uOiB0cnVlCnNl%0AY3JldF9jb2RlOgotIDEKLSAxCi0gMQotIDIKYXZhaWxhYmxlX2hpbnRzOgot%0AIDEKLSAxCi0gMgoGOwBUSSILcmVzdWx0BjsARlsJSSIGKwY7AFRJIgYrBjsA%0AVEkiBisGOwBUSSIGKwY7AFRJIgpoaW50cwY7AEZbBmkG%0A--a95e154ad955d7ed6746393ed9f9033bd753365f'
      let(:env) { { 'HTTP_COOKIE' => "rack.session=#{rack_session} " } }
      let(:env) { { 'rack.session' => { 'session_id' => session_id, 'game' => "--- !ruby/object:Game\nstats: !ruby/object:GameStatistic\n  name: Kasha\n  attempts_used: 2\n  hints_used: 1\n  date: 2019-06-06 10:33\n  difficulty: 3\n  attempts_total: 5\n  hints_total: 1\nwon: true\nsecret_code:\n- 1\n- 1\n- 1\n- 2\navailable_hints:\n- 1\n- 1\n- 2\n", 'result' => ['+', '+', '+', '+'], 'hints' => [1] } } }

      it 'shows win' do
        get '/win', {}, env
        expect(last_response.status).to eq(200)
        expect(last_request.url).to include('/win')
        expect(last_response.body).to include('Congratulations, Kasha ! You won the game!')
      end
    end

    context 'submit answer' do
      session_id = 'bed266c6ebe450dff8637545f671342b12dbf091d02058984b4452cc48bfc574'
      rack_session = 'BAh7CkkiD3Nlc3Npb25faWQGOgZFVEkiRWJlZDI2NmM2ZWJlNDUwZGZmODYz%0ANzU0NWY2NzEzNDJiMTJkYmYwOTFkMDIwNTg5ODRiNDQ1MmNjNDhiZmM1NzQG%0AOwBGSSIJaW5pdAY7AEZUSSIJZ2FtZQY7AEZJIgH7LS0tICFydWJ5L29iamVj%0AdDpHYW1lCnN0YXRzOiAhcnVieS9vYmplY3Q6R2FtZVN0YXRpc3RpYwogIG5h%0AbWU6IEthc2hhCiAgYXR0ZW1wdHNfdXNlZDogMgogIGhpbnRzX3VzZWQ6IDEK%0AICBkYXRlOiAyMDE5LTA2LTA2IDEwOjMzCiAgZGlmZmljdWx0eTogMwogIGF0%0AdGVtcHRzX3RvdGFsOiA1CiAgaGludHNfdG90YWw6IDEKd29uOiB0cnVlCnNl%0AY3JldF9jb2RlOgotIDEKLSAxCi0gMQotIDIKYXZhaWxhYmxlX2hpbnRzOgot%0AIDEKLSAxCi0gMgoGOwBUSSILcmVzdWx0BjsARlsJSSIGKwY7AFRJIgYrBjsA%0AVEkiBisGOwBUSSIGKwY7AFRJIgpoaW50cwY7AEZbBmkG%0A--a95e154ad955d7ed6746393ed9f9033bd753365f'
      let(:env) { { 'HTTP_COOKIE' => "rack.session=#{rack_session} " } }
      let(:env) { { 'rack.session' => { 'session_id' => session_id, 'game' => "--- !ruby/object:Game\nstats: !ruby/object:GameStatistic\n  name: Kasha\n  attempts_used: 2\n  hints_used: 1\n  date: 2019-06-06 10:33\n  difficulty: 3\n  attempts_total: 5\n  hints_total: 1\nwon: false\nsecret_code:\n- 1\n- 1\n- 1\n- 2\navailable_hints:\n- 1\n- 1\n- 2\n", 'result' => ['+', '+', '+', '-'], 'hints' => [1] } } }

      it 'requests for /submit_answer' do
        get '/submit_answer', { 'number' => '1321' }, env
        follow_redirect!
        expect(last_response.status).to eq(200)
        expect(last_request.url).to include('/game')
        expect(last_response.body).to include('Submit')
      end
    end

    context 'show hint' do
      session_id = 'bed266c6ebe450dff8637545f671342b12dbf091d02058984b4452cc48bfc574'
      rack_session = 'BAh7CkkiD3Nlc3Npb25faWQGOgZFVEkiRWJlZDI2NmM2ZWJlNDUwZGZmODYz%0ANzU0NWY2NzEzNDJiMTJkYmYwOTFkMDIwNTg5ODRiNDQ1MmNjNDhiZmM1NzQG%0AOwBGSSIJaW5pdAY7AEZUSSIJZ2FtZQY7AEZJIgH7LS0tICFydWJ5L29iamVj%0AdDpHYW1lCnN0YXRzOiAhcnVieS9vYmplY3Q6R2FtZVN0YXRpc3RpYwogIG5h%0AbWU6IEthc2hhCiAgYXR0ZW1wdHNfdXNlZDogMgogIGhpbnRzX3VzZWQ6IDEK%0AICBkYXRlOiAyMDE5LTA2LTA2IDEwOjMzCiAgZGlmZmljdWx0eTogMwogIGF0%0AdGVtcHRzX3RvdGFsOiA1CiAgaGludHNfdG90YWw6IDEKd29uOiB0cnVlCnNl%0AY3JldF9jb2RlOgotIDEKLSAxCi0gMQotIDIKYXZhaWxhYmxlX2hpbnRzOgot%0AIDEKLSAxCi0gMgoGOwBUSSILcmVzdWx0BjsARlsJSSIGKwY7AFRJIgYrBjsA%0AVEkiBisGOwBUSSIGKwY7AFRJIgpoaW50cwY7AEZbBmkG%0A--a95e154ad955d7ed6746393ed9f9033bd753365f'
      let(:env) { { 'HTTP_COOKIE' => "rack.session=#{rack_session} " } }
      let(:env) { { 'rack.session' => { 'session_id' => session_id, 'game' => "--- !ruby/object:Game\nstats: !ruby/object:GameStatistic\n  name: Kasha\n  attempts_used: 2\n  hints_used: 0\n  date: 2019-06-06 10:33\n  difficulty: 3\n  attempts_total: 5\n  hints_total: 1\nwon: false\nsecret_code:\n- 1\n- 1\n- 1\n- 1\navailable_hints:\n- 1\n- 1\n- 1\n", 'result' => ['+', '+', '+', '-'], 'hints' => [] } } }

      it 'request for /show_hint' do
        get '/show_hint', {}, env
        follow_redirect!
        expect(last_response.status).to eq(200)
        expect(last_request.url).to include('/game')
        expect(last_response.body).to include("<span class=\"badge badge-light\">1</span>")
      end
    end

    context 'without game' do
      session_id = 'bed266c6ebe450dff8637545f671342b12dbf091d02058984b4452cc48bfc574'
      rack_session = 'BAh7CkkiD3Nlc3Npb25faWQGOgZFVEkiRWJlZDI2NmM2ZWJlNDUwZGZmODYz%0ANzU0NWY2NzEzNDJiMTJkYmYwOTFkMDIwNTg5ODRiNDQ1MmNjNDhiZmM1NzQG%0AOwBGSSIJaW5pdAY7AEZUSSIJZ2FtZQY7AEZJIgH7LS0tICFydWJ5L29iamVj%0AdDpHYW1lCnN0YXRzOiAhcnVieS9vYmplY3Q6R2FtZVN0YXRpc3RpYwogIG5h%0AbWU6IEthc2hhCiAgYXR0ZW1wdHNfdXNlZDogMgogIGhpbnRzX3VzZWQ6IDEK%0AICBkYXRlOiAyMDE5LTA2LTA2IDEwOjMzCiAgZGlmZmljdWx0eTogMwogIGF0%0AdGVtcHRzX3RvdGFsOiA1CiAgaGludHNfdG90YWw6IDEKd29uOiB0cnVlCnNl%0AY3JldF9jb2RlOgotIDEKLSAxCi0gMQotIDIKYXZhaWxhYmxlX2hpbnRzOgot%0AIDEKLSAxCi0gMgoGOwBUSSILcmVzdWx0BjsARlsJSSIGKwY7AFRJIgYrBjsA%0AVEkiBisGOwBUSSIGKwY7AFRJIgpoaW50cwY7AEZbBmkG%0A--a95e154ad955d7ed6746393ed9f9033bd753365f'
      let(:env) { { 'HTTP_COOKIE' => "rack.session=#{rack_session} " } }
      let(:env) { { 'rack.session' => { 'session_id' => session_id, 'hints' => [] } } }

      it 'redirects to menu if submits wihtout game' do
        get '/submit_answer', { 'number' => '1321' }, env
        follow_redirect!
        expect(last_response.status).to eq(200)
        expect(last_request.url).to include('/menu')
        expect(last_response.body).to include('Start the game!')
      end
    end

    context 'last attempt' do
      session_id = 'bed266c6ebe450dff8637545f671342b12dbf091d02058984b4452cc48bfc574'
      rack_session = 'BAh7CkkiD3Nlc3Npb25faWQGOgZFVEkiRWJlZDI2NmM2ZWJlNDUwZGZmODYz%0ANzU0NWY2NzEzNDJiMTJkYmYwOTFkMDIwNTg5ODRiNDQ1MmNjNDhiZmM1NzQG%0AOwBGSSIJaW5pdAY7AEZUSSIJZ2FtZQY7AEZJIgH7LS0tICFydWJ5L29iamVj%0AdDpHYW1lCnN0YXRzOiAhcnVieS9vYmplY3Q6R2FtZVN0YXRpc3RpYwogIG5h%0AbWU6IEthc2hhCiAgYXR0ZW1wdHNfdXNlZDogMgogIGhpbnRzX3VzZWQ6IDEK%0AICBkYXRlOiAyMDE5LTA2LTA2IDEwOjMzCiAgZGlmZmljdWx0eTogMwogIGF0%0AdGVtcHRzX3RvdGFsOiA1CiAgaGludHNfdG90YWw6IDEKd29uOiB0cnVlCnNl%0AY3JldF9jb2RlOgotIDEKLSAxCi0gMQotIDIKYXZhaWxhYmxlX2hpbnRzOgot%0AIDEKLSAxCi0gMgoGOwBUSSILcmVzdWx0BjsARlsJSSIGKwY7AFRJIgYrBjsA%0AVEkiBisGOwBUSSIGKwY7AFRJIgpoaW50cwY7AEZbBmkG%0A--a95e154ad955d7ed6746393ed9f9033bd753365f'
      let(:env) { { 'HTTP_COOKIE' => "rack.session=#{rack_session} " } }
      let(:env) { { 'rack.session' => { 'session_id' => session_id, 'game' => "--- !ruby/object:Game\nstats: !ruby/object:GameStatistic\n  name: Kasha\n  attempts_used: 4\n  hints_used: 0\n  date: 2019-06-06 10:33\n  difficulty: 3\n  attempts_total: 5\n  hints_total: 1\nwon: false\nsecret_code:\n- 1\n- 1\n- 1\n- 1\navailable_hints:\n- 1\n- 1\n- 1\n", 'result' => ['+', '+', '+', '-'], 'hints' => [] } } }

      it 'redirects to win with correct attempt' do
        get '/submit_answer', { 'number' => '1111' }, env
        follow_redirect!
        expect(last_response.status).to eq(200)
        expect(last_request.url).to include('/win')
      end

      it 'redirects to lose with correct attempt' do
        get '/submit_answer', { 'number' => '1101' }, env
        follow_redirect!
        expect(last_response.status).to eq(200)
        expect(last_request.url).to include('/lose')
      end
    end

    context 'statistics' do
      session_id = 'bed266c6ebe450dff8637545f671342b12dbf091d02058984b4452cc48bfc574'
      rack_session = 'BAh7CkkiD3Nlc3Npb25faWQGOgZFVEkiRWJlZDI2NmM2ZWJlNDUwZGZmODYz%0ANzU0NWY2NzEzNDJiMTJkYmYwOTFkMDIwNTg5ODRiNDQ1MmNjNDhiZmM1NzQG%0AOwBGSSIJaW5pdAY7AEZUSSIJZ2FtZQY7AEZJIgH7LS0tICFydWJ5L29iamVj%0AdDpHYW1lCnN0YXRzOiAhcnVieS9vYmplY3Q6R2FtZVN0YXRpc3RpYwogIG5h%0AbWU6IEthc2hhCiAgYXR0ZW1wdHNfdXNlZDogMgogIGhpbnRzX3VzZWQ6IDEK%0AICBkYXRlOiAyMDE5LTA2LTA2IDEwOjMzCiAgZGlmZmljdWx0eTogMwogIGF0%0AdGVtcHRzX3RvdGFsOiA1CiAgaGludHNfdG90YWw6IDEKd29uOiB0cnVlCnNl%0AY3JldF9jb2RlOgotIDEKLSAxCi0gMQotIDIKYXZhaWxhYmxlX2hpbnRzOgot%0AIDEKLSAxCi0gMgoGOwBUSSILcmVzdWx0BjsARlsJSSIGKwY7AFRJIgYrBjsA%0AVEkiBisGOwBUSSIGKwY7AFRJIgpoaW50cwY7AEZbBmkG%0A--a95e154ad955d7ed6746393ed9f9033bd753365f'
      let(:env) { { 'HTTP_COOKIE' => "rack.session=#{rack_session} " } }
      let(:env) { { 'rack.session' => { 'session_id' => session_id, 'game' => "--- !ruby/object:Game\nstats: !ruby/object:GameStatistic\n  name: Test_name_for_statistic\n  attempts_used: 4\n  hints_used: 0\n  date: 2019-06-06 10:33\n  difficulty: 3\n  attempts_total: 5\n  hints_total: 1\nwon: false\nsecret_code:\n- 1\n- 1\n- 1\n- 1\navailable_hints:\n- 1\n- 1\n- 1\n", 'result' => ['+', '+', '+', '-'], 'hints' => [] } } }

      it 'shows just lose game on statistics' do
        get '/submit_answer', { 'number' => '1101' }, env
        follow_redirect!
        get '/statistics', {}, env
        expect(last_response.status).to eq(200)
        expect(last_request.url).to include('/statistics')
        expect(last_response.body).to include('Test_name_for_statistic')
      end
    end
  end
end
