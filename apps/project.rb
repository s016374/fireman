require 'dotenv/load'
require 'logger'
require 'http'
require_relative 'dm'

module Project
  class DMProject
    attr_reader :project, :qa, :errors, :pass_cases, :fail_cases

    def initialize
      @project = self.class.to_s
      @qa = ENV['YANGWAN']
      @base_url = ENV['DM_URL']
      @pass_cases = []
      @fail_cases = []
    end

    def logging
      logger = Logger.new STDOUT
      logger.formatter = proc do |severity, time, progname, msg|
        "#{severity}|#{time}|#{progname} -- #{msg} \n"
      end
      logger.info "\nClass:#{self.class}:\nCase:#{@case}\nUrl:#{@url}\nStatus:#{@status}\nBody:#{@body}\nCookie:#{@cookie}\n"
    end

    def result_request
      self.methods.grep(/case_/).each do |func|
        if send func
          @pass_cases << [ @case, @url, @status, @body ]
        else
          @fail_cases << [ @case, @url, @status, @body ]
        end
      end
      @fail_cases.empty?
    end
  end

  class BondWeb < DMProject
    def initialize
      super
      @qa = ENV['SHENYANG']
    end

    def case_1
      @case = '违约概率排行'
      @url = @base_url + '/bond-web/api/bond/analysis/pdRank/indus?page=1&limit=5&sort=pdSortRRs%3Adesc'
      res = HTTP["Accept" => "Application/json", "userid" => "516733"]
          .get(@url)
      @status = res.status.to_s
      @body = res.body.to_s
      logging
      @status == '200 OK' && @body =~ /"message":"success"/
    end

    def case_2
      @case = '查询-地区信息'
      @url = @base_url + '/bond-web/api/bondCity/bondArea?type=2'
      res = HTTP["Accept" => "Application/json", "userid" => "516733"]
          .get(@url)
      @status = res.status.to_s
      @body = res.body.to_s
      logging
      @status == '200 OK' && @body =~ /"message":"success"/
    end
  end

  class BondPortfolio < DMProject
    def initialize
      super
      @qa = ENV['SHENYANG']
    end

    def case_1
      @case = '[投组] 获取投组列表'
      @url = @base_url + '/bond-portfolio-service/api/bond/portfolio/users/516733/groups'
      res = HTTP["Accept" => "Application/json"]
          .get(@url)
      @status = res.status.to_s
      @body = res.body.to_s
      logging
      @status == '200 OK' && @body =~ /"message":"success"/
    end

    def case_2
      @case = '[投组] 获取投组雷达根节点/子节点列表'
      @url = @base_url + '/bond-portfolio-service/api/bond/portfolio/radar/nodes/0'
      res = HTTP["Accept" => "Application/json"]
          .get(@url)
      @status = res.status.to_s
      @body = res.body.to_s
      logging
      @status == '200 OK' && @body =~ /"message":"success"/
    end
  end

  class OnlineWeb < DMProject
    def initialize
      super
      @qa = ENV['LINA']
    end

    def case_1
      @case = '线上-我的报价-已成交'
      @url =  @base_url + '/online-web/api/quotes/dealtQuotes?pageSize=20&pageNum=1'
      @cookie = DM::TestHelper.get_login_session(ENV['PROD_USER'], ENV['PROD_PASSWORD'], 'prod', false)
      res = HTTP["Accept" => "*/*"]
          .cookies(@cookie)
          .get(@url)
      @status = res.status.to_s
      @body = res.body.to_s
      logging
      @status == '200 OK' && @body =~ /"message":"success"/
    end

    def case_2
      @case = '线上-我的报价-匹配中'
      @url =  @base_url + '/online-web/api/quotes/matchingQuotes?pageSize=20&pageNum=1'
      @cookie = DM::TestHelper.get_login_session(ENV['PROD_USER'], ENV['PROD_PASSWORD'], 'prod', false)
      res = HTTP["Accept" => "*/*"]
          .cookies(@cookie)
          .get(@url)
      @status = res.status.to_s
      @body = res.body.to_s
      logging
      @status == '200 OK' && @body =~ /"message":"success"/
    end
  end

  class OfflineWeb < DMProject
    def initialize
      super
      @qa = ENV['LINA']
    end

    def case_1
      @case = '获取用户已成交的自己报价'
      @url =  @base_url + '/offline-web/api/completedQuotes?pageSize=20&pageNum=1'
      @cookie = DM::TestHelper.get_login_session(ENV['PROD_USER'], ENV['PROD_PASSWORD'], 'prod', false)
      res = HTTP["Accept" => "*/*"]
          .cookies(@cookie)
          .get(@url)
      @status = res.status.to_s
      @body = res.body.to_s
      logging
      @status == '200 OK' && @body =~ /"message":"success"/
    end

    def case_2
      @case = '获取用户匹配中的自己报价'
      @url =  @base_url + '/offline-web/api/matchingQuotes?pageSize=20&pageNum=1'
      @cookie = DM::TestHelper.get_login_session(ENV['PROD_USER'], ENV['PROD_PASSWORD'], 'prod', false)
      res = HTTP["Accept" => "*/*"]
          .cookies(@cookie)
          .get(@url)
      @status = res.status.to_s
      @body = res.body.to_s
      logging
      @status == '200 OK' && @body =~ /"message":"success"/
    end
  end

  class DepositWeb < DMProject
    def initialize
      super
      @qa = ENV['LINA']
    end

    def case_1
      @case = '获取一组报价基本信息'
      @url =  @base_url + '/deposit-web/internalApi/quoteGroups/www'
      @cookie = DM::TestHelper.get_login_session(ENV['PROD_USER'], ENV['PROD_PASSWORD'], 'prod', false)
      res = HTTP["Accept" => "*/*"]
          .cookies(@cookie)
          .get(@url)
      @status = res.status.to_s
      @body = res.body.to_s
      logging
      @status == '200 OK' && @body =~ /"message":"success"/
    end

    def case_2
      @case = '通过groupKey 获取同组的所有报价'
      @url =  @base_url + '/deposit-web/internalApi/quoteGroups/qqq/quotes'
      @cookie = DM::TestHelper.get_login_session(ENV['PROD_USER'], ENV['PROD_PASSWORD'], 'prod', false)
      res = HTTP["Accept" => "*/*"]
          .cookies(@cookie)
          .get(@url)
      @status = res.status.to_s
      @body = res.body.to_s
      logging
      @status == '200 OK' && @body =~ /"message":"success"/
    end
  end

  class FinanceWeb < DMProject
    def initialize
      super
      @qa = ENV['LINA']
    end

    def case_1
      @case = '获取一条报价'
      @url =  @base_url + '/finance-web/internalApi/quotes/111'
      @cookie = DM::TestHelper.get_login_session(ENV['PROD_USER'], ENV['PROD_PASSWORD'], 'prod', false)
      res = HTTP["Accept" => "*/*"]
          .cookies(@cookie)
          .get(@url)
      @status = res.status.to_s
      @body = res.body.to_s
      logging
      @status == '200 OK' && @body =~ /"message":"success"/
    end

    def case_2
      @case = '获取最近market走势图'
      @url =  @base_url + '/finance-web/api/market/financeMarket/quoteGroup/qew/assetCatId'
      @cookie = DM::TestHelper.get_login_session(ENV['PROD_USER'], ENV['PROD_PASSWORD'], 'prod', false)
      res = HTTP["Accept" => "*/*"]
          .cookies(@cookie)
          .get(@url)
      @status = res.status.to_s
      @body = res.body.to_s
      logging
      @status == '200 OK' && @body =~ /"message":"success"/
    end
  end

  class IrsWeb < DMProject
    def initialize
      super
      @qa = ENV['LINA']
    end

    def case_1
      @case = 'IRS-查询报价'
      @url =  @base_url + '/irs-web/internalApi/quotes/1111'
      @cookie = DM::TestHelper.get_login_session(ENV['PROD_USER'], ENV['PROD_PASSWORD'], 'prod', false)
      res = HTTP["Accept" => "*/*"]
          .cookies(@cookie)
          .get(@url)
      @status = res.status.to_s
      @body = res.body.to_s
      logging
      @status == '200 OK' && @body =~ /"message":"success"/
    end

    def case_2
      @case = '用户IRS权限列表'
      @url =  @base_url + '/irs-web/api/funcs/all'
      @cookie = DM::TestHelper.get_login_session(ENV['PROD_USER'], ENV['PROD_PASSWORD'], 'prod', false)
      res = HTTP["Accept" => "*/*"]
          .cookies(@cookie)
          .get(@url)
      @status = res.status.to_s
      @body = res.body.to_s
      logging
      @status == '200 OK' && @body =~ /"message":"success"/
    end
  end

  class DepositApp < DMProject
    def initialize
      super
      @qa = ENV['LINA']
    end

    def case_1
      @case = '大厅存单-高级筛选-选项json'
      @url =  @base_url + '/deposit-app/app/api/advancedFiltrate/options'
      @cookie = DM::TestHelper.get_login_session(ENV['PROD_USER'], ENV['PROD_PASSWORD'], 'prod', false)
      res = HTTP["Accept" => "*/*"]
          .cookies(@cookie)
          .get(@url)
      @status = res.status.to_s
      @body = res.body.to_s
      logging
      @status == '200 OK' && @body =~ /"message":"success"/
    end
  end

  class FinanceApp < DMProject
    def initialize
      super
      @qa = ENV['LINA']
    end

    def case_1
      @case = '大厅理财-高级筛选-选项json'
      @url =  @base_url + '/finance-app/app/api/advancedFiltrate/options'
      @cookie = DM::TestHelper.get_login_session(ENV['PROD_USER'], ENV['PROD_PASSWORD'], 'prod', false)
      res = HTTP["Accept" => "*/*"]
          .cookies(@cookie)
          .get(@url)
      @status = res.status.to_s
      @body = res.body.to_s
      logging
      @status == '200 OK' && @body =~ /"message":"success"/
    end
  end



  class OfflineApp < DMProject
    def initialize
      super
      @qa = ENV['LINA']
    end

    def case_1
      @case = '大厅线下-高级筛选-选项json'
      @url =  @base_url + '/offline-app/app/api/advancedFiltrate/options'
      @cookie = DM::TestHelper.get_login_session(ENV['PROD_USER'], ENV['PROD_PASSWORD'], 'prod', false)
      res = HTTP["Accept" => "*/*"]
          .cookies(@cookie)
          .get(@url)
      @status = res.status.to_s
      @body = res.body.to_s
      logging
      @status == '200 OK' && @body =~ /"message":"success"/
    end
  end


  class BondPortfolioService < DMProject
    def initialize
      super
      @qa = ENV['LINA']
    end

    def case_1
      @case = '[指标] 获取单支债券的财务指标列表'
      @url =  @base_url + '/bond-portfolio-service/api/bond/portfolio/favorite/2222/radars/fina?userId=1111'
      @cookie = DM::TestHelper.get_login_session(ENV['PROD_USER'], ENV['PROD_PASSWORD'], 'prod', false)
      res = HTTP["Accept" => "application/json"]
          .get(@url)
      @status = res.status.to_s
      @body = res.body.to_s
      logging
      @status == '200 OK' && @body =~ /"message":"success"/
    end

    def case_2
      @case = '[指标] 获取单支债券的财务指标列表'
      @url =  @base_url + '/bond-portfolio-service/api/bond/portfolio/favorite/407515/radars/fina?userId=516733'
      @cookie = DM::TestHelper.get_login_session(ENV['PROD_USER'], ENV['PROD_PASSWORD'], 'prod', false)
      res = HTTP["Accept" => "application/json"]
          .get(@url)
      @status = res.status.to_s
      @body = res.body.to_s
      logging
      @status == '200 OK' && @body =~ /"message":"success"/
    end
  end

  class AuthService < DMProject
    def initialize
      super
      @qa = ENV['LINA']
    end

    def case_1
      @case = '通过sessionId判断用户是否登录中'
      @url =  @base_url + '/auth-service/web/api/verified/session/wewr'
      @cookie = DM::TestHelper.get_login_session(ENV['PROD_USER'], ENV['PROD_PASSWORD'], 'prod', false)
      res = HTTP["Accept" => "*/*"]
      .cookies(@cookie)
          .get(@url)
      @status = res.status.to_s
      @body = res.body.to_s
      logging
      @status == '200 OK' && @body =~ /"message":"success"/
    end

    def case_2
      @case = '通过sessionId获取user信息'
      @url =  @base_url + '/auth-service/web/api/verified/session/www/user'
      @cookie = DM::TestHelper.get_login_session(ENV['PROD_USER'], ENV['PROD_PASSWORD'], 'prod', false)
      res = HTTP["Accept" => "*/*"]
      .cookies(@cookie)
          .get(@url)
      @status = res.status.to_s
      @body = res.body.to_s
      logging
      @status == '200 OK' && @body =~ /"message":"success"/
    end
  end

  class MetaService < DMProject
    def initialize
      super
      @qa = ENV['LINA']
    end

    def case_1
      @case = '获取用户的所有权限'
      @url =  @base_url + '/meta-service/user/id/500003/permissions'
      @cookie = DM::TestHelper.get_login_session(ENV['PROD_USER'], ENV['PROD_PASSWORD'], 'prod', false)
      res = HTTP["Accept" => "*/*"]
      .cookies(@cookie)
          .get(@url)
      @status = res.status.to_s
      @body = res.body.to_s
      logging
      @status == '200 OK' && @body =~ /"message":"success"/
    end

    def case_2
      @case = '获取用户的密码'
      @url =  @base_url + '/meta-service/user/qa_test/password'
      @cookie = DM::TestHelper.get_login_session(ENV['PROD_USER'], ENV['PROD_PASSWORD'], 'prod', false)
      res = HTTP["Accept" => "*/*"]
      .cookies(@cookie)
          .get(@url)
      @status = res.status.to_s
      @body = res.body.to_s
      logging
      @status == '200 OK' && @body =~ /"message":"success"/
    end
  end
end
