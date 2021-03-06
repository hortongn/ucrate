# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog searching', type: :feature do
  let(:user) { create(:user) }
  let!(:collection_type) { create(:collection_type, id: 1) }
  let!(:collection_type_2) { create(:collection_type, id: 2) }

  before do
    allow(User).to receive(:find_by_user_key).and_return(stub_model(User, twitter_handle: 'bob'))
    sign_in user
    visit '/catalog'
  end

  context 'with works and collections' do
    let!(:jills_work) do
      create(:public_work, title: ["Jill's Research"], subject: ['jills_subject', 'shared_subject'])
    end

    let!(:jacks_work) do
      create(:public_work, title: ["Jack's Research"], subject: ['jacks_subject', 'shared_subject'])
    end

    let!(:collection) { create(:public_collection, collection_type_gid: collection_type.gid, subject: ['collection_subject', 'shared_subject']) }

    it 'performing a search' do
      within('#search-form-header') do
        fill_in('search-field-header', with: 'shared_subject')
        click_button('Go')
      end

      expect(page).to have_content('Search Results')
      expect(page).to have_content(jills_work.title.first)
      expect(page).to have_content(jacks_work.title.first)
      expect(page).to have_content(collection.title.first)
    end
  end

  context 'with public works and private collections', clean_repo: true do
    let!(:collection) { create(:private_collection) }

    let!(:jills_work) do
      create(:public_work, title: ["Jill's Research"], subject: ['jills_subject'], member_of_collections: [collection])
    end

    it "hides collection facet values the user doesn't have access to view when performing a search" do
      within('#search-form-header') do
        fill_in('search-field-header', with: 'jills_subject')
        click_button('Go')
      end

      expect(page).to have_content('Search Results')
      expect(page).to have_content(jills_work.title.first)
      expect(page).not_to have_content(collection.title.first)
      expect(page).not_to have_css('.blacklight-member_of_collection_ids_ssim')
    end

    context 'as an admin' do
      let(:admin_user) { create :admin }

      before do
        admin = Role.create(name: "admin")
        admin.users << admin_user
        admin.save
        sign_in admin_user
        visit '/catalog'
      end

      it "shows collection facet values the user has access to view when performing a search" do
        within('#search-form-header') do
          fill_in('search-field-header', with: 'jills_subject')
          click_button('Go')
        end

        expect(page).to have_content('Search Results')
        expect(page).to have_content(jills_work.title.first)
        find('.blacklight-member_of_collection_ids_ssim').click
        expect(page).to have_content(collection.title.first)
      end
    end
  end
end
