require 'dotenv/load'
require 'http'
require 'mail'
require_relative 'project'

module DM
  module TestHelper
    module_function

    def get_login_session(username, password, env, is_sid=true)
      if env =~ /prod/
        url = ENV['DM_URL'] + '/auth-service/signin'
      elsif env =~ /qa/
        url = ENV['DM_QA_URL'] + '/auth-service/signin'
      else
        return 'plz + /env (prod, qa)'
      end
      res = HTTP.get(url)
      csrf = res.to_s.split('name="_csrf" value="').last.split('"/>').first
      sid = res.cookies.inspect.to_s.split('"sid", value="').last.split('",').first
      res = HTTP[content_type: 'application/x-www-form-urlencoded']
                .cookies('sid' => sid, 'uid' => ENV['TEST_UID'], 'UM_distinctid' => ENV['TEST_UM_DISTINCTID'])
                .post(url, :body => "_csrf=#{csrf}&username=#{username}&password=#{password}")
      sid = res.cookies.inspect.to_s
      return 'auth error' if sid.include? '@jar={}'
      sid = sid.split('"sid", value="').last.split('",').first
      return sid if is_sid
      { sid: sid, uid: ENV['TEST_UID'], UM_distinctid: ENV['TEST_UM_DISTINCTID'] }
    end

    def post_message_to_qq_group(message, group)
      group ||= ENV['QQ_GROUP']
      data = {:group_id => group, :message => message, :is_raw => 'False'}
      res = HTTP['User-Agent':'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36','Content-Type': 'application/json']
                .post(ENV['QQ_URL'], json: data)
      res.to_s
    end

    def post_mail(rev, body)
      Mail.defaults do
        delivery_method :smtp, {
          :address => 'smtp.gmail.com',
          :port => 587,
          :user_name => ENV['GMAIL_SMTP_USER'],
          :password => ENV['GMAIL_SMTP_PASSWORD'],
          :authentication => :plain,
          :enable_starttls_auto => true
        }
      end

      Mail.deliver do
        content_type 'text/html; charset=UTF-8'
        from 'innodealing.qa@gmail.com'
        to "#{rev}"
        subject "Fireman Notice"
        body "#{body}"
      end
    end
  end

  module Monitor
    # Dashing project Octopus
    class Octopus
      def post_octopus(widget, report)
        data = {:auth_token => ENV['OCTOPUS_AUTH_TOKEN'], :text => report}
        HTTP.post(ENV['OCTOPUS_URL'] + "/widgets/#{widget}", json: data)
      end
    end

    # abstract factory
    class DMService
      def initialize(service)
        @service = service
      end

      def exec!
        @service.result_request
      end

      def project
        @service.project
      end

      def qa
        @service.qa
      end

      def pass_cases
        @service.pass_cases
      end

      def fail_cases
        @service.fail_cases
      end
    end

    # all services api testcases
    # implement HTTP request by ghost method
    class Check
      attr_reader :pass_cases, :fail_cases

      def initialize()
        @pass_cases = []
        @fail_cases = []
        # init mult-services: @services = [ DMService.new(BondWeb.new), DMService.new(BondIntergration.new), ... ]
        # monitor projects
        @services = [
          DMService.new(Project::BondWeb.new),
          DMService.new(Project::BondPortfolio.new),
          DMService.new(Project::OnlineWeb.new),
          DMService.new(Project::OfflineWeb.new),
          DMService.new(Project::DepositWeb.new),
          DMService.new(Project::FinanceWeb.new),
          DMService.new(Project::IrsWeb.new),
          DMService.new(Project::DepositApp.new),
          DMService.new(Project::FinanceApp.new),
          DMService.new(Project::OfflineApp.new),
          DMService.new(Project::BondPortfolioService.new),
          DMService.new(Project::AuthService.new),
          DMService.new(Project::MetaService.new)
        ]
      end

      def http_request
        @services.each do |service|
          next if service.exec!
          assert = Assert.new(service)
          assert.notice_observers
        end
      end

      def result_request
        @services.each do |service|
          service.exec!
          @pass_cases << service.project << service.pass_cases unless service.pass_cases.empty?
          @fail_cases << service.project << service.fail_cases unless service.fail_cases.empty?
        end
      end
    end

    # Subject is observed by class Notice
    class Assert
      attr_accessor :project, :qa, :fail_cases, :observers
      def initialize(service)
        @observers = [ Notice.new(QQ.create), Notice.new(Mail.create) ]
        @project = service.project
        @qa = service.qa
        @fail_cases = service.fail_cases
      end

      def attach_observer(observer)
        @observers << observer
      end

      def remove_observer(observer)
        @observers.delete observer
      end

      def status
        @observers.length
      end

      def notice_observers
        @observers.each do |observer|
          # call Notice#notice
          observer.notice(@project, @qa, @fail_cases)
        end
      end
    end

    # Observer
    # Strategy
    # Notice.new(Mail.new).noice
    # or Noice.new(Mail.new, QQ.new, Record.new).notic
    class Notice
      def initialize(way)
        @way = way
      end

      def notice(project, qa, errors)
        msg = "<p>Error:#{project}</p>"
        errors.each do |c, url, status, body|
          msg += "<p>case=#{c}</p><p>url=#{url}</p><p>status=#{status}</p><p>body=#{body}</p>"
        end
        @way.exec! qa, msg
      end
    end

    # notice by send mail to sb.
    class Mail
      include TestHelper

      private_class_method :new

      def self.create(*args, &blk)
        @@ins ||= new(*args, &blk)
      end

      def exec!(rev ,msg)
        post_mail(rev, msg)
      end
    end

    # notice by send message to QQ group
    class QQ
      include TestHelper

      private_class_method :new

      def self.create(*args, &blk)
        @@ins ||= new(*args, &blk)
      end

      def exec!(rev, msg)
        post_message_to_qq_group "@#{rev}", nil
        msg[3, msg.length-7].split('</p><p>').each do |m|
          post_message_to_qq_group m, nil
        end
      end
    end

    # record error history to DB
    class Record
      include TestHelper

      private_class_method :new

      def self.create(*args, &blk)
        @@ins ||= new(*args, &blk)
      end

      def exec!(*args)
        # TODO
      end
    end

  end
end
