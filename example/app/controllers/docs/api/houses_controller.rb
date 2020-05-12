module Docs
  module Api
    class HousesController < ApplicationController
      def create
        render json: {
          id: 22
        }
      end

      def show
        if params[:id] == "22"
          render json: {
            id: 22,
            fake: true
          }
        else
          head :internal_server_error
        end
      end
    end
  end
end
