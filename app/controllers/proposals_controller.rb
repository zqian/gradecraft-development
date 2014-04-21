class ProposalsController < ApplicationController

  #Groups create proposals that they submit until their plan is approved

  def index
    @proposals = Proposal.all
    respond_with(@proposals)
  end

  def show
    @proposal = Proposal.find(params[:id])
    respond_with(@proposal)
  end

  def new
    @proposal = Proposal.new
    respond_with(@proposal)
  end

  def edit
    @proposal = Proposal.find(params[:id])
  end

  def create
    @proposal = Proposal.new(params[:proposal])
    flash[:notice] = 'Proposal was successfully created.' if @proposal.save
    respond_with(@proposal)
  end

  def update
    @proposal = Proposal.find(params[:id])
    flash[:notice] = 'Proposal was successfully updated.' if @proposal.update(params[:proposal])
    respond_with(@proposal)
  end

  def destroy
    @proposal = Proposal.find(params[:id])
    @proposal.destroy
    respond_with(@proposal)
  end
end
