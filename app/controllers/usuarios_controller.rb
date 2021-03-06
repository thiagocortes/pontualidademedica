class UsuariosController < ApplicationController
  before_action :set_usuario, only: [:show, :edit, :update, :destroy]
  skip_before_filter :verify_authenticity_token

  def login
    @usuario = Usuario.new email: params[:email]

    respond_to do |format|
      if !session[:usuario].nil?
        format.html { redirect_to controller: "medicos" }
      else
        format.html { render nil, layout: false }
      end
    end
  end

  def autenticar
    usuario = Usuario.find_by email: params[:usuario][:email]

    valid_auth = false
    if params[:usuario][:email].empty?
      flash[:error] = "Insira seu email"
    elsif params[:usuario][:senha].empty?
      flash[:error] = "Insira sua senha"
    elsif usuario.nil? || usuario.senha != params[:usuario][:senha]
      flash[:error] = "Combinação de usuário e senha inexistente"
    else
      valid_auth = true
      entrar_com usuario
    end

    respond_to do |f|
      f.html do
        redirect_to(
          action: "login",
          email: params[:usuario][:email]
        )
      end
    end unless valid_auth
  end

  def logout
    session[:usuario] = nil
    respond_to do |format|
      format.html { redirect_to controller: "medicos" }
    end
  end

  def esqueci_a_senha
  end

  def recuperar_senha
    @usuario = Usuario.find_by email: params[:email]

    respond_to do |format|
      format.html do
        if params[:email] == ""
          flash[:error] = "Insira seu email"
          redirect_to action: "esqueci_a_senha"
        elsif @usuario.nil?
          flash[:error] = "Email não encontrado"
          redirect_to action: "esqueci_a_senha"
        else
          UsuarioMailer.recuperar_senha(@usuario).deliver
          redirect_to action: "senha_enviada"
        end
      end
    end
  end

  def senha_enviada
  end

  def show
    if true # session[:usuario].nil? || session[:usuario].id != params[:id].to_i
      render "public/404.html", status: :not_found
    end
  end

  # GET /usuarios/new
  def new
    if session[:usuario].nil?
      @usuario = Usuario.new
    else
      render "public/404.html", status: :not_found
    end
  end

  # GET /usuarios/1/edit
  def edit
    if session[:usuario].nil? || session[:usuario].id != params[:id].to_i
      render "public/404.html", status: :not_found
    end
  end

  # POST /usuarios
  def create
    @usuario = Usuario.new(usuario_params)

    if !session[:usuario].nil?
      render "public/500.html", status: :internal_server_error
    elsif @usuario.save
      entrar_com Usuario.find @usuario.id
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /usuarios/1
  # PATCH/PUT /usuarios/1.json
  def update
    if session[:usuario].nil? || session[:usuario].id != params[:id].to_i
      render "public/500.html", status: :internal_server_error
    else
      respond_to do |format|
        if @usuario.update(usuario_params)
          format.html { redirect_to @usuario, notice: 'Usuario was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @usuario.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /usuarios/1
  # DELETE /usuarios/1.json
  def destroy
    if true # Desativar a exclusão de usuário por enquanto
      render "public/500.html", status: :internal_server_error
    else
      @usuario.destroy
      respond_to do |format|
        format.html { redirect_to usuarios_url }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_usuario
      @usuario = Usuario.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def usuario_params
      params.require(:usuario).permit(:nome, :email, :senha, :redir, :senha_confirmation)
    end

    def entrar_com(usuario)
      session[:usuario] = usuario

      respond_to do |format|
        if params[:redir] == "nova_consulta"
          format.html { redirect_to controller: "consultas", action: "new" }
        else
          format.html { redirect_to controller: "medicos" }
        end
      end
    end
end
