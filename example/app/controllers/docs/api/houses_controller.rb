module Docs
  module Api
    class HousesController < ApplicationController
      def show
        render json: {
          id: params[:id]
        }
      end
    end
  end
end
