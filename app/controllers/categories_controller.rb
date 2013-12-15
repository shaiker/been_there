class CategoriesController < ApplicationController

  def index
    # render json: Category.all
    render json: [
      { id: 1, name: "eat" },
      { id: 2, name: "sleep" },
      { id: 3, name: "rave" },
      { id: 4, name: "repeat" }
    ]
  end

end
