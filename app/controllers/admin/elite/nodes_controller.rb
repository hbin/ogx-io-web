class Admin::Elite::NodesController < ApplicationController
  before_action :set_node, only: [:order_up, :order_down, :resume, :destroy]

  layout 'admin'

  # GET /admin/elite/nodes
  # GET /admin/elite/nodes.json
  def index
    authorize User, :manage?
    if params[:parent_id].blank?
      @all_nodes = Elite::Node.where(layer: 0)
      @all_nodes = @all_nodes.where(:board_id.in => current_user.managing_boards.collect{|board| board.id}) unless current_user.admin?
    else
      @parent = Elite::Node.find(params[:parent_id])
      @all_nodes = Elite::Node.where(parent_id: params[:parent_id])
    end
    if params[:status].to_i == 1
      @all_nodes = @all_nodes.normal
    end
    if params[:status].to_i == 2
      @all_nodes = @all_nodes.deleted
    end
    @nodes = @all_nodes.desc(:order).page(params[:page]).per(20)
  end

  def order_up
    authorize @node, :update?
    @node.order += 1
    @node.save!
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end

  def order_down
    authorize @node, :update?
    @node.order -= 1
    @node.save
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end

  def resume
    authorize @node
    @node.resume_by(current_user)
    respond_to do |format|
      format.js { render 'refresh', locals: {node: @node} }
    end
  end

  def destroy
    authorize @node
    @node.delete_by(current_user)
    respond_to do |format|
      format.js { render 'refresh', locals: {node: @node} }
    end
  end

  def set_node
    @node = Elite::Node.find(params[:id])
  end
end
