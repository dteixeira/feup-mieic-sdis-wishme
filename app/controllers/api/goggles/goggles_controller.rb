class Api::Goggles::GogglesController < Api::BaseApiController

  before_filter :ensure_api_access

  def lookup
    begin
      resp = parse_response(GogglesRequest.lookup_image params[:image][:base64])
      render :json => {
        :success => true,
        :response => resp
      }
    rescue Exception => e
      puts e.message
      render :json => {
        :success => false,
        :message => I18n.t('goggles.failure.params_failure')
      }
    end
  end

  protected
  def parse_response resp
    parsed = []
    return parsed unless resp
    resp.each do |r|
      res = {}
      res[:message] = r.message
      cat = ::Category.find_by_name(r.type.downcase.gsub(' ', '_'))
      if cat
        res[:category] = cat.id
      else
        res[:category] = ::Category.find_by_name('other').id
      end
      parsed.push res
    end
    return parsed
  end

end
