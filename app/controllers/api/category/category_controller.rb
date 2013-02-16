class Api::Category::CategoryController < Api::BaseApiController

  before_filter :ensure_api_access

  def show_all
    cats = []
    ::Category.all.each { |i| cats.push({:id => i.id, :name => i.name}) }
    render :json => {
      :success => true,
      :categories => cats
    }
  end

end
