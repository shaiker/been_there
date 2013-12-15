class TipsController < ApplicationController

  def get_tip
    render json: {
      title: "Tip Tip Tip",
      text: "some text here...",
      category: "Food",
      image_url: "http://d2ms2r4k9boggo.cloudfront.net/uploads/image/user_98/normal_u98_27224.jpeg",
      image_id: 301,
      url: "http://www.google.com"
    }
  end

  def show
  end
  

end
