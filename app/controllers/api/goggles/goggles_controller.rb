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
      if Category.find_by_name(r.type.downcase.gsub(' ', '_'))
        res[:category] = r.type.downcase.gsub(' ', '_')
      else
        res[:category] = 'other'
      end
      res[:category] = I18n.t("category.#{res[:category]}")
      parsed.push res
    end
    return parsed
  end

end
