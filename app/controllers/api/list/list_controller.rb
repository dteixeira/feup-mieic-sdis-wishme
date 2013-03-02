class Api::List::ListController < Api::BaseApiController

  before_filter :ensure_api_access

  def show
    begin
      list = @user.lists.where(:sha1_id => params[:list][:sha1_id]).first
      render :json => {
        :success => true,
        :list => build_list_response(list)
      }
    rescue
      list_failure I18n.t('list.failure.params_failure')
    end
  end

  def show_all
    lists = []
    @user.lists.each do |l|
      lists.push build_list_response(l)
    end
    render :json => {
      :success => true,
      :lists => lists
    }
  end

  def update
    begin
      list = @user.lists.where(:sha1_id => params[:list][:sha1_id]).first
      list.update_attributes (params[:list]).except(:sha1_id, :id, :user_id)
      render :json => {
        :success => true,
        :list => build_list_response(list)
      }
    rescue
      list_failure I18n.t('list.failure.params_failure')
    end
  end

  def delete
    begin
      list = @user.lists.where(:sha1_id => params[:list][:sha1_id]).first
      list.destroy
      render :json => {
        :success => true
      }
    rescue
      list_failure I18n.t('list.failure.params_failure')
    end
  end

  def clean
    begin
      list = @user.lists.where(:sha1_id => params[:list][:sha1_id]).first
      list.items.each do |i|
        i.destroy
      end
      list = @user.lists.where(:sha1_id => params[:list][:sha1_id]).first
      render :json => {
        :success => true,
        :list => build_list_response(list)
      }
    rescue
      list_failure I18n.t('list.failure.params_failure')
    end
  end

  def create
    begin
      list = ::List.new params[:list]
      list.user = @user
      list.save!
      render :json => {
        :success => true,
        :list => build_list_response(list)
      }
    rescue
      list_failure I18n.t('list.failure.params_failure')
    end
  end

  private
  def list_failure msg
    render :json => {
      :success => false,
      :message => msg
    }
  end

  def build_list_response list
    items = []
    list.items.each do |i|
      items.push ({
        :name => i.name,
        :description => i.description,
        :private => i.private,
        :sha1_id => i.sha1_id,
        :category => i.category_id,
        :img_hash => i.img_hash
      })
    end
    {
      :name => list.name,
      :description => list.description,
      :private => list.private,
      :sha1_id => list.sha1_id,
      :items => items
    }
  end

end
