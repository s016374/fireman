require 'sinatra'
require 'rufus-scheduler'
require "rdiscount"
require_relative 'dm'

class App < Sinatra::Base
  use Rack::Auth::Basic, "Protected Area" do |username, password|
    username == 'username' && password == 'username'
  end

  configure :production, :development do
    enable :logging
    set :views, 'views'
  end

  helpers DM::TestHelper, DM::Monitor

  scheduler = Rufus::Scheduler.new

  # Run cases every 30m
  # scheduler.every '30m' do
  #   Check.new.http_request
  # end

  # index
  get '/' do
    erb :index
  end

  # get login user sid(String)
  get '/get/cookie/:username/:password/:env' do
    session = get_login_session params['username'], params['password'], params['env'], false
    logger.info "get params: #{params.inspect}\nget session: #{session}"
    session.to_s
  end

  # get login session(Hash)
  get '/get/sid/:username/:password/:env' do
    session = get_login_session params['username'], params['password'], params['env']
    logger.info "get params: #{params.inspect}\nget session: #{session}"
    session
  end

  # post a message to QQ group
  # body sample: {"message": "hello", "group": 482279953} or {"message": "hello"}
  post '/post/qq' do
    data = JSON.parse request.body.read
    res = post_message_to_qq_group data['message'], data['group']
    logger.info "send message to QQ group: #{data.inspect}\n result: #{res}"
    res
  end

  # send a mail to rev
  # body sample: {"rev": "user@a.com", "data": 'context'}
  post '/post/mail' do
    data = JSON.parse request.body.read
    res = post_mail data['rev'], data['body']
    logger.info "send email to rev: #{data.inspect}\n result: #{res}"
    res
  end

  # run monitor
  # /monitor/all
  # [
  #   [
  #     @project,[@case, @url, @status, @body], [@case, @url, @status, @body],...
  #   ],
  #   [
  #     @project,[@case, @url, @status, @body], [@case, @url, @status, @body],...
  #   ],
  #   ...
  # ]

  get '/monitor/all' do
    res = Check.new
    res.result_request
    @pass = res.pass_cases
    @fail = res.fail_cases
    erb :report
  end

  get '/blms' do
    markdown :blms
  end

  reports = {}
  # curl -u user:passwd -X 'POST' -d '{error description}' http://0.0.0.0:9292/issue
  post '/issue' do
    issue_id = ''
    random = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    5.times do
      issue_id << random.sample
    end

    # report = request.body.read.force_encoding("ASCII-8BIT").encode('UTF-8', undef: :replace, replace: '')
    report = JSON.parse request.body.read
    reports.merge!(issue_id => report['msg'])
    issue_id
  end

  # curl -u user:passwd -X 'DELETE' http://0.0.0.0:9292/issue/q3A5l
  delete '/issue/:issue_id' do
    reports.delete params[:issue_id]
  end

  # curl -u user:passwd -X 'DELETE' http://0.0.0.0:9292/issues/clean
  delete '/issues/clean' do
    reports = {}
  end

  # trigger OCTOPUS project dm/alert api:
  # curl -d '{ "auth_token": "bigqa", "text": "Hey" }' http://0.0.0.0:30030/widgets/alert
  scheduler.every '5s', :first_in => 2, allow_overlapping: false do
    p reports
    rskey = reports.keys
    if rskey.length > 0
      # reports.keys.each do |key|
      rskey.each_index do |i|
        # data = "[ Issue_ID: #{key} ]<br>#{reports[key]}"
        data = "[ #{i + 1} / #{rskey.length} , Issue_ID: #{rskey[i]} ]<br>#{reports[rskey[i]]}"
        Octopus.new.post_octopus('alert', data)
        sleep 5
      end
    else
      data = "Pass"
      Octopus.new.post_octopus('alert', data)
    end
  end
end
