# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  # Generated controller for Etd
  class EtdsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Scholar::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Etd

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::EtdPresenter

    def show
      super
      permalink_message = I18n.t('permanent_link_label')
      @permalinks_presenter = PermalinksPresenter.new(main_app.common_object_path(locale: nil), permalink_message)
    end
  end
end
