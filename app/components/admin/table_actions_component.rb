class Admin::TableActionsComponent < ApplicationComponent
  include TableActionLink
  attr_reader :record, :options
  delegate :namespace, to: :helpers

  def initialize(record = nil, **options)
    @record = record
    @options = options
  end

  private

    def actions
      options[:actions] || [:edit, :destroy]
    end

    def edit_text
      options[:edit_text] || t("admin.actions.edit")
    end

    def edit_path
      options[:edit_path] || namespaced_polymorphic_path(namespace, record, action: :edit)
    end

    def edit_options
      { class: "edit-link" }.merge(options[:edit_options] || {})
    end

    def destroy_text
      options[:destroy_text] || t("admin.actions.delete")
    end

    def destroy_path
      options[:destroy_path] || namespaced_polymorphic_path(namespace, record)
    end

    def destroy_options
      {
        method: :delete,
        class: "destroy-link",
        data: { confirm: destroy_confirmation }
      }.merge(options[:destroy_options] || {})
    end

    def destroy_confirmation
      options[:destroy_confirmation] || t("admin.actions.confirm")
    end

    def district_streets_text
      options[:district_streets_text] || t("admin.district.streets");
    end

    def district_streets_path
      options[:district_streets_path] || namespaced_polymorphic_path(namespace, record)
    end

    def district_streets_options
      { class: "groups-link" }.merge(options[:district_streets_options] || {})
    end

    def district_zones_text
      options[:district_zones_text] || t("admin.district.zones")
    end

    def district_zones_path
      options[:district_zones_path] || namespaced_polymorphic_path(namespace, record)
    end

    def district_zones_options
      { class: "ballots-link" }.merge(options[:district_zones_options] || {})
    end
end
