class AgentsController < ApplicationController
	before_filter :login_required
  before_filter :login_from_cookie
	
  # GET /agents
  # GET /agents.xml
  def index
    if params[:filter_type].nil?
      @filter = {}
      @title = "All Agents"
      @agents = Agent.paginate :page => params[:page], :order => "id DESC"
    else
      @filter = {:type => params[:filter_type], :id => params[:filter_id], :name => params[:filter_name]}
      @title = "Agents For #{@filter[:type]}: #{@filter[:name]}"  
      case @filter[:type]
        when 'User'
					@agents = current_user.agents.paginate :page => params[:page], :order => "id DESC"
        when 'Game'
				  game = Game.find(@filter[:id])
					@agents = game.agents.paginate :page => params[:page], :order => "id DESC"
      end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @agents }
    end
  end

  # GET /agents/1
  # GET /agents/1.xml
  def show
    @agent = Agent.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @agent }
    end
  end

  # GET /agents/new
  # GET /agents/new.xml
  def new
    @agent = Agent.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @agent }
    end
  end

  # GET /agents/1/edit
  def edit
    @agent = Agent.find(params[:id])
  end

  # POST /agents
  # POST /agents.xml
  def create
    @agent = Agent.new(params[:agent])
		for agent_game in params[:newagent_game]
			next if agent_game[:game_id].empty?
			next if @agent.games.find_by_id(agent_game[:game_id])
			@agent.games << Game.find(agent_game[:game_id])  #agents_games xref not saved to db because @agent isn't yet
		end
		respond_to do |format|
		  if current_user.agents << @agent  # saves agent and agents_games to db
				format.html do
			    flash[:notice] = 'Agent was successfully created.'
          redirect_to :action => 'show', :id => @agent
				end
				format.xml  { render :xml => @agent, :status => :created, :location => @agent }
		  else
			  format.html { render :action => 'new' }
				format.xml  { render :xml => @agent.errors, :status => :unprocessable_entity }
		  end
		end
  end

  # PUT /agents/1
  # PUT /agents/1.xml
  def update
		@agent = Agent.find(params[:id])
    @agent.agents_games.each do |ag|
      if params[:agent_game][ag.game_id.to_s][:game_id] == ''
        AgentsGame.delete_all "game_id = #{ag.game_id} AND agent_id = #{ag.agent_id}"
      end
    end   
		for agent_game in params[:newagent_game]
      next if agent_game[:game_id].empty?
      next if @agent.games.find_by_id(agent_game[:game_id])
      @agent.games << Game.find(agent_game[:game_id])  # saves new agents_games to db
    end
		respond_to do |format|
      if @agent.update_attributes(params[:agent])
				format.html do
          flash[:notice] = "Agent was successfully updated."
          redirect_to :action => 'show', :id => @agent
				end
				format.xml  { head :ok }
      else
        format.html { render :action => 'edit' }
				format.xml  { render :xml => @agent.errors, :status => :unprocessable_entity }
      end
		end
  end

  # DELETE /agents/1
  # DELETE /agents/1.xml
  def destroy
    @agent = Agent.find(params[:id])
	  if(@agent.game_results.nil? or @agent.game_results.empty?)
		  AgentsGame.delete_all "agent_id= #{@agent.id}"
      flash[:notice] = 'Agent successfully destroyed.'
	    @agent.destroy
	  else
	    flash[:notice] = 'Agent not destroyed because it has result records.'
	  end
    redirect_to :action => 'index', :filter_type => params[:filter_type], :filter_id => params[:filter_id], :filter_name => params[:filter_name]
#    respond_to do |format|
#      format.html { redirect_to(agents_url) }
#      format.xml  { head :ok }
#    end
  end
end
