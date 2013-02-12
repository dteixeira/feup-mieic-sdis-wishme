class Api::Item::ItemController < Api::BaseApiController

  before_filter :ensure_api_access

end
