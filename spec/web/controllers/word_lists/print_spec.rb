RSpec.describe Web::Controllers::WordLists::Print, type: :action do
  let(:action) { described_class.new }
  let(:response) { action.call(params) }
  let(:params) { { 'rack.session' => session }.merge(query_params) }
  let(:query_params) { { id: word_list_id } }
  let(:word_list_id) { word_list.id }
  let(:session) { {} }
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:word_list) { create(:word_list, :with_words, user_id: word_list_user_id) }
  let(:word_list_user_id) { user.id }
  let!(:other_user_word_list) { create(:word_list, user_id: other_user.id) }
  let(:exposed_list) { action.exposures[:word_list] }

  context "when list with given id doesn't exist" do
    let(:word_list_id) { SecureRandom.uuid }

    it "renders 404" do
      expect(response[0]).to eq 404
    end
  end

  context "when non UUID id passed" do
    let(:word_list_id) { 'xd' }

    it "renders 404" do
      expect(response[0]).to eq 404
    end
  end

  context "when user is logged in" do
    let(:session) { { user_id: user.id } }

    context "when list belongs to another user" do
      let(:word_list_id) { other_user_word_list.id }

      it "shows the list" do
        expect(response[0]).to eq 200
        expect(response[1]["Content-Type"]).to eq("application/pdf")
      end
    end

    context "when list is anonymous" do
      let(:word_list_user_id) { nil }

      it "shows the list" do
        expect(response[0]).to eq 200
        expect(response[1]["Content-Type"]).to eq("application/pdf")
      end
    end

    context "when list belongs to the user" do
      it "shows the list" do
        expect(response[0]).to eq 200
        expect(response[1]["Content-Type"]).to eq("application/pdf")
      end
    end
  end

  context "when user isn't logged in" do
    context "when list belongs to a user" do
      it "shows the list" do
        expect(response[0]).to eq 200
        expect(response[1]["Content-Type"]).to eq("application/pdf")
        expect(response[2][0]).to start_with("%PDF")
      end
    end

    context "when list is anonymous" do
      let(:word_list_user_id) { nil }

      it "shows the list" do
        expect(response[0]).to eq 200
        expect(response[1]["Content-Type"]).to eq("application/pdf")
      end
    end
  end
end
