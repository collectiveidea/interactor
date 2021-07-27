# frozen_string_literal: true

module Presenters
  def show
    @shipment = @tenant.shipments.find(params[:id])
    @sale_rep = @shipment.sales_rep
    sales_reps # from SalesRepUpdateable returns @sales_reps

    if params[:refresh_pdf] == "true" || (@shipment.needs_pdf && @shipment.pdf_error_count == 0)
      Utils::Pdf.new(@tenant, Shipment, nil).perform_single(@shipment.id)
      @shipment.reload
    end

    redirect_to(shipments_path) unless @shipment

    if @shipment
      @shipment_activities = @shipment.activities.where.not(activity_for: Activity.default_excluded_activities).limit(20)
    end
  end

  def usage
    presenter = ShipmentShowPresenter.present(tenant:   @tenant,
                                              shipment: @tenant.shipments.find(params[:id]))

    if presenter.success?
      @model = @model.model
      render
    end
  end

  class ShipmentShowPresenter < BasePresenter
    delegate :tenant, :shipment, to: :context

    def present
      guard(:tenant, :shipment)

      # Model
      OpenStruct.new({
        order_template_id: ContextualEmailTemplateId.call(tenant: tenant, type: Order),
        all: :other,
        fields: :needed,
        by: :view,
        are: :listed_here
      })
    end
  end
end
