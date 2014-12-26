require 'active_support/concern'
require 'active_support/inflections'

module Roar
  module Contrib
    module Decorator
      module PageRepresenter
        extend ActiveSupport::Concern

        def page_url(args)
          raise NotImplementedError
        end

        included do
          # REVIEW: Should we include Hypermedia automatically or raise
          #   an error if not included already?
          include Roar::Hypermedia

          def current_page
            represented.current_page
          end

          def next_page
            represented.next_page
          end

          # WillPaginate uses #per_page while Kaminari uses #limit_value
          def per_page
            per_page_method = represented.respond_to?(:per_page) ?
              :per_page : :limit_value

            represented.send per_page_method
          end

          # WillPaginate uses #previous_page while Kaminari uses #prev_page
          def previous_page
            previous_page_method = represented.respond_to?(:previous_page) ?
              :previous_page : :prev_page

            represented.send previous_page_method
          end

          # WillPaginate uses #total_entries while Kaminari uses #total_count
          def total_entries
            total_entries_method = represented.respond_to?(:total_entries) ?
              :total_entries : :total_count

            represented.send total_entries_method
          end

          property :total_entries, exec_context: :decorator

          link :self do |opts|
            page_url :page => current_page, :per_page => per_page
          end

          link :next do |opts|
            page_url(
              :page => next_page,
              :per_page => per_page
            ) if next_page
          end

          link :previous do |opts|
            page_url(
              :page => previous_page,
              :per_page => per_page
            ) if previous_page
          end
        end
      end
    end
  end
end
