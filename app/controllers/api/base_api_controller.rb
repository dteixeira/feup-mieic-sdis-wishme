class Api::BaseApiController < ApplicationController

  respond_to :json
  include Api::RegistrationsHelper

end
