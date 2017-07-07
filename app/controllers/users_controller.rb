class UsersController < ApplicationController


  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]   # solo gli utenti loggati possono accedere alle azioni edit ed update, ossia possono modificare il proprio profilo
  before_action :correct_user, only: [:edit, :update]     # un utente non può modificare le info di un altro utente, perciò deve esse il CORRETTO utente
  before_action :admin_user, only: :destroy  #si deve essere admin per eliminare un altro utente
  
  
  def new
	@user = User.new
  end
  
  def show
	@user = User.find(params[:id])
  end
  
  def create
	@user = User.new(user_params)   #invece di usare (params[:user]) che passava tutti i parametri, non sicuro!
	if @user.save
		log_in @user  #al momento della registrazione l'utente viene direttamente loggato
		remember user #metodo definito in session_helper
		flash[:success] = "Welcome to Recipely!"  #success è una convezione di Rails per indicare esito positivo
		redirect_to @user  #non faccio (non c'è proprio(?)) una views per la create, reindirizzo alla pagina utente!
	else
		render 'new'
	end
  end
  
  
  
  def edit
	@user = User.find(params[:id])
  end
  
  def update
	@user = User.find(params[:id])
	if @user.update_attributes(user_params)   #se l'aggiornamento del profilo va a buon fine...
		flash[:success] = "Profile updated"
		redirect_to @user
	else
		render 'edit'
	end
  end
  
  
  def index
	@users = User.paginate(page: params[:page])  #variabile che contiene tutti gli utenti del database, utilizzo il metodo paginate per dividerli in più pagine
  end
  
  
  def destroy
	User.find(params[:id]).destroy
	flash[:success] = "User deleted"
	redirect_to users_url
  end



  private
  
	def user_params                  #metodo convenzionale, restituisce una versione dell’hash params con i soli attributi consentiti
		params.require(:user).permit(:name, :email, :password, :password_confirmation)
	end
	#NB ad esempio non è presente l'attributo "admin" in quanto non è sicuro che tale attributo possa venir modificato via web!
	
	
	# Before filters
	# Confirms a logged-in user.
	def logged_in_user
		unless logged_in?
			store_location  
			#METODO definito in sessions_helper con cui mi salvo l'URL a cui l'utente non autorizzato stava cercando di accedere, così poi lo reindirizzo lì una volta loggato
			flash[:danger] = "Please log in."
			redirect_to login_url
		end
    end
    
    # Confirms the correct user.
	def correct_user
		@user = User.find(params[:id])
		redirect_to(root_url) unless current_user?(@user)
	end
	
	# Confirms an admin user.
	def admin_user
		redirect_to(root_url) unless current_user.admin?  #NB il metodo "admin?" è stato aggiunto direttamente da Rails quando alla creazione ha visto che admin è un booleano
	end
	
end
