class TipsController < ApplicationController

  def get_tip
    render json: Tip.first(order: "RAND()")
  end

  def show
  end
  

end
