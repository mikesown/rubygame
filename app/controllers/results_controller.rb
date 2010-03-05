class ResultsController < ApplicationController
  before_filter :login_required, :except => [:index]
  before_filter :login_from_cookie
	
	# GET /results
  # GET /results.xml
  def index
    if params[:filter_type].nil?
      @filter = {}
      @title = "All Results"
      @results = Result.paginate :page => params[:page], :order => "id DESC"
    else
      @filter = {:type => params[:filter_type], :id => params[:filter_id], :name => params[:filter_name]}
      @title = "Results For #{@filter[:type]}: #{@filter[:name]}"  
      case @filter[:type]
        when 'Agent'
					agent = Agent.find(@filter[:id])
					@results = agent.game_results.paginate :page => params[:page], :order => "id DESC"
        when 'Game'
				  game = Game.find(@filter[:id])
          @results = game.results.paginate :page => params[:page], :order => "id DESC"
        when 'User'
          @results = current_user.results.paginate :page => params[:page], :order => "id DESC"
      end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @results }
    end
  end

  # GET /results/1
  # GET /results/1.xml
  def show
    @result = Result.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @result }
    end
  end

  # GET /results/new
  # GET /results/new.xml
  def new
    redirect_to :controller=>'games', :action => 'index' and return if !params[:id]
    @game = Game.find(params[:id])
  end

  # GET /results/1/edit
  # users editing results not allowed

  # POST /results
  # POST /results.xml
  def create
    
    @result = Result.new(params[:result])
    @result.result = "Pending"
    params[:player].each do |id, player|
      if player[:id] == ""
        if Player.find(id).required?
          flash[:notice] = 'Must add all required players'
          redirect_to :action => 'new', :id=>@result.game
          return
        end
      else
        participant = @result.participants.build :player_id=>id, :agent_id=>player[:id]
      end
    end
    #myWorker = GameWorker.new
    #myWorker.playGame(@result, current_user)
    hash = {:result => @result, :current_user => current_user}
    GameWorker.async_playGame(hash)
    
    respond_to do |format|
      # save match to db
      if current_user.results << @result
				format.html do
          flash[:notice] = @result.result.is_a?(String) ? @result.result : "Result was successfully created"
          redirect_to :action => 'show', :id => @result
				end
				format.xml  { render :xml => @result, :status => :created, :location => @result }
      else
				format.html do
          flash[:notice] = "Result could not be created"
          render :action => 'new'
				end
				format.xml  { render :xml => @result.errors, :status => :unprocessable_entity }
      end
	  end
  end

  # PUT /results/1
  # PUT /results/1.xml
  # users editing results not allowed

  # DELETE /results/1
  # DELETE /results/1.xml
  def destroy
    @result = Result.find(params[:id])
    Participant.delete_all "result_id = #{@result.id}"
    @result.destroy
    respond_to do |format|
      format.html do
				flash[:notice] = "Result successfully destroyed"
        redirect_to :action => 'index', :filter_type => params[:filter_type], :filter_id => params[:filter_id], :filter_name => params[:filter_name]
	    end
      format.xml  { head :ok }
    end
  end
end
