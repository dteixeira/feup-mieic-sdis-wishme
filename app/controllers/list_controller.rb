class ListController < ApplicationController
  def show
    @list = List.find_by_sha1_id(params[:sha1_id])
  end
end
