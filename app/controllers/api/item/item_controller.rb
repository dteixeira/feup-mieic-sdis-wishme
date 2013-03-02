class Imgur2
  def upload img
    url = URI.parse 'http://api.imgur.com/2/upload.json'
    JSON.parse Net::HTTP.start(url.host) { |http|
      post = Net::HTTP::Post.new url.path
      post.set_form_data('key'   => key,
                         'image' => img,
                         'type'  => 'base64')
      http.request(post).body
    }
  end
end

class Api::Item::ItemController < Api::BaseApiController

  before_filter :ensure_api_access

  def create
    begin
      hash = params[:image][:base64]
    rescue
      hash = nil
    end
    begin
      list = @user.lists.where('sha1_id' => params[:item][:list]).first
      params[:item].except! :list
      item = ::Item.new params[:item]
      item.list = list
      if hash
        client = Imgur2.new '12f6747516365761a8a4b2e5fd98f068'
        resp = client.upload hash
        item.img_hash = resp['upload']['image']['hash']
      else
        item.img_hash = nil
      end
      item.save!
      resp = build_item_response item
      render :json => {
        :success => true,
        :list => resp
      }
    rescue
      item_failure I18n.t('item.failure.params_failure')
    end
  end

  def delete
    begin
      item = @user.items.where(:sha1_id => params[:item][:sha1_id]).first
      item.destroy
      resp = build_item_response item
      render :json => {
        :success => true,
        :list => resp
      }
    rescue
      item_failure I18n.t('item.failure.params_failure')
    end
  end

  def update
    begin
      item = @user.items.where(:sha1_id => params[:item][:sha1_id]).first
      item.update_attributes (params[:item]).except(:sha1_id, :id, :list_id)
      render :json => {
        :success => true,
        :list => build_item_response(item)
      }
    rescue
      item_failure I18n.t('item.failure.params_failure')
    end
  end

  private
  def item_failure msg
    render :json => {
      :success => false,
      :message => msg
    }
  end

  def build_item_response item
    list = item.list
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
