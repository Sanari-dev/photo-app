class RegistrationsController < Devise::RegistrationsController 

  def create
    build_resource(sign_up_params)

    resource.class.transaction do
      resource.save
      yield resource if block_given?
      if resource.persisted?
        @payment = Payment.new({email: params["user"]["email"], token: params[:payment]["transaction_id"], user_id: resource.id})
        flash[:error] = "Please check registration errors" unless @payment.valid?

        begin
          @payment.process_payment(params[:payment]["transaction_status"])
          @payment.save
        rescue Exception => e
          flash[:error] = e.message
          resource.destroy
          puts 'Payment failed'
          render :new and return
        end

        if resource.active_for_authentication?
          set_flash_message :notice, :signed_up if is_flashing_format?
          sign_up(resource_name, resource)
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message :notice, "sign_up_but_#{resource.inactive_message}" if is_flashing_format?
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    end
  end

  def new
    result = Midtrans.create_snap_token(
      transaction_details: {
        order_id: generate_order_id,
        gross_amount: 15000,
        secure: true
      }
    )
    @token = result.token

    build_resource
    yield resource if block_given?
    respond_with resource
  end

  protected
  
  def generate_order_id
    "sinatra-example-#{Time.now.to_i}"
  end
  
end