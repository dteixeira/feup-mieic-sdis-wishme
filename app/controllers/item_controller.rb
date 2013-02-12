class ItemController < ApplicationController
  def show
    @item = Item.find_by_sha1_id(params[:sha1_id])
  end
end
