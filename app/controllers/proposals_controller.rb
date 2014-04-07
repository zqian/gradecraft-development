class ProposalsController < ApplicationController
  # GET /proposals
  # GET /proposals.xml
  def index
    @proposals = Proposal.all
    respond_with(@proposals)
  end

  # GET /proposals/1
  # GET /proposals/1.xml
  def show
    @proposal = Proposal.find(params[:id])
    respond_with(@proposal)
  end

  # GET /proposals/new
  # GET /proposals/new.xml
  def new
    @proposal = Proposal.new
    respond_with(@proposal)
  end

  # GET /proposals/1/edit
  def edit
    @proposal = Proposal.find(params[:id])
  end

  # POST /proposals
  # POST /proposals.xml
  def create
    @proposal = Proposal.new(params[:proposal])
    flash[:notice] = 'Proposal was successfully created.' if @proposal.save
    respond_with(@proposal)
  end

  # PUT /proposals/1
  # PUT /proposals/1.xml
  def update
    @proposal = Proposal.find(params[:id])
    flash[:notice] = 'Proposal was successfully updated.' if @proposal.update(params[:proposal])
    respond_with(@proposal)
  end

  # DELETE /proposals/1
  # DELETE /proposals/1.xml
  def destroy
    @proposal = Proposal.find(params[:id])
    @proposal.destroy
    respond_with(@proposal)
  end
end
