module AuthTrail
  class GeocodeWorker
    include Sidekiq::Worker
    sidekiq_options queue: AuthTrail.geocode_queue

    def perform(login_activity_id)
      login_activity = LoginActivity.find(login_activity_id)
      result =
        begin
          Geocoder.search(login_activity.ip).first
        rescue => e
          Rails.logger.info "Geocode failed: #{e.message}"
          nil
        end

      if result
        login_activity.update!(
          city: result.try(:city).presence,
          region: result.try(:state).presence,
          country: result.try(:country).presence
        )
      end
    end
  end
end
