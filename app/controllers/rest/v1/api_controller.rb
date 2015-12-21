module Rest
  module V1
    class ApiController < ApplicationController
      skip_before_filter :verify_authenticity_token
      before_filter :authenticate_header, only: [:upload_outpost_json_file, :register, :add_email_queue]

      def sso
        token = Token.new(email: params[:email], password: params[:password])
        render json: token.authenticate
      end

      def upload_outpost_json_file
        json_content = request.body.read

        return api_respond 'Body\'s json content is missing or empty' if json_content == '{}'

        auth_token = $auth_tokens.detect { |a_t| a_t[:token] == @session_token }
        user = User.find_by(email: auth_token[:email])
        upload_result = Outpost.upload_file(json_content, user)
        api_respond upload_result[:message], upload_result[:status]
      end

      def register
        data = params[:api]
        response = Outpost.register data
        api_respond response[:message], response[:status]
      end

      def add_email_queue
        obj = EmailQueue.add_queue params[:run_id], params[:email_list]

        return api_respond 'Successfully created email queue!', true if obj.is_a? EmailQueue
        api_respond 'Error occurred when creating email queue!'
      end

      private

      def authenticate_header
        @session_token = request.headers['HTTP_TC_SESSION_TOKEN']
        return api_respond 'Not Authorized' unless @session_token

        auth_token = $auth_tokens.detect { |a_t| a_t[:token] == @session_token } unless $auth_tokens.blank?
        return api_respond unless auth_token

        token = Token.new auth_token
        api_respond if token.expired?
      end

      def api_respond(message = 'Token not exist or expired', status = false)
        render json: { status: status, message: message }
      end
    end
  end
end
