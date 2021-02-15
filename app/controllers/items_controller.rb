class ItemsController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def index
    Rails.logger.debug params.to_json
    order = ""
    params[:sort_by]&.each_with_index do |sort, index|
      order += sort
      order += (params[:sort_desc][index] != "true" ? " asc" : " desc")
    end
    @items = Item.order(order).page(params[:page]).per(params[:per_page])
    render json: { items: @items, total_count: @items.total_count }
  end

  def show
    @item = Item.find(params[:id])
    render json: @item
  end

  def update
    item = Item.find(params[:id])
    item.update(item_params)
    render json: item
  end

  def create
    item = Item.create(item_params)
    render json: item
  end

  def destroy
    item = Item.find(params[:id])
    item.destroy
    render json: {}
  end

  private

  def item_params
    params.require(:item).permit(:name, :quantity, :status)
  end
end
