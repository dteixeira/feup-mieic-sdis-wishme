class Api::BaseApiController < ApplicationController

  respond_to :json
  include Api::Users::RegistrationsHelper
  include Api::Users::SessionsHelper
  include Api::Goggles::GogglesHelper

end
