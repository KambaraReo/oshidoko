require 'rails_helper'

RSpec.describe "Samples", type: :request do
  describe "GET /samples/index" do
    it "returns a successful response" do
      get samples_index_path
      expect(response).to have_http_status(200)
    end
  end
end
