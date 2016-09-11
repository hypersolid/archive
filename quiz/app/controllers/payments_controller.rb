class PaymentsController < ApplicationController
  def callback
    # block unknown IPs
    render(:nothing => true) and return if Rails.env.production? && !request.ip.in?(["198.104.132.114", "198.104.132.118", "76.7.50.73", "4.53.19.193"])

    if(params[:sn] == Playspan.config["sn"])
      # check passed params
      status = (Playspan.valid_params?(params) && params[:commtype].in?(["PAYMENT", "ADMIN_REVERSAL", "FORCED_REVERSAL"]) && params[:currency] == "GBP" ? "OK" : "ERROR")

      @payment = Payment.create!(
        :amount => params[:sepamount],
        :user_id => params[:userid],
        :status => status,
        :transaction_id => params[:pbctrans],
        :mode => params[:mirror],
        :query_string => request.request_parameters.to_s
      )

      if @payment.status == "OK"
        @payment.user.increment!(:credits, @payment.credits)
        EmailFallback.delay.proxy(:payment, @payment)
      end
    else # return OK for test service's callback
      status = "OK"
    end
    
    render :text => "[#{status}]|#{Time.now.strftime('%Y%m%d%H%M%S')}|#{params[:pbctrans]}|[N/A]"
  end

  # callback URL for the incomplete payment
  def incomplete
    redirect_to ladders_url
  end
end
