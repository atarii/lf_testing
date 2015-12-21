class OutpostController < ApplicationController
  def upload_result
    @silo = params[:silo]

    return unless params['commit'] && params[:outpost_json]

    json_content = params[:outpost_json].read
    upload_result = Outpost.upload_file json_content, nil, request.url.split('/')[-1]
    @message = upload_result[:status]? ModelCommon.success_message(upload_result[:message]) : ModelCommon.error_message(upload_result[:message])

    render 'upload_result'
  end

  def refresh
    Outpost.outpost_status

    render json: { status: 'done' }
  end
end
