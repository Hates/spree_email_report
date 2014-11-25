Spree::Admin::ReportsController.class_eval do
  helper 'spree/base'

  before_action do
    self.class.add_available_report!(:emails_report)
  end

  def emails
    @search = nil

    params[:q] = {} unless params[:q]

    if params[:q][:completed_at_gt].blank?
      params[:q][:completed_at_gt] = Time.zone.now.beginning_of_month
    else
      params[:q][:completed_at_gt] = Time.zone.parse(params[:q][:completed_at_gt]).beginning_of_day rescue Time.zone.now.beginning_of_month
    end

    if params[:q] && !params[:q][:completed_at_lt].blank?
      params[:q][:completed_at_lt] = Time.zone.parse(params[:q][:completed_at_lt]).end_of_day rescue Time.zone.now.end_of_month
    end

    params[:q][:s] ||= "completed_at desc"

    @search = Spree::Order.complete.ransack(params[:q])
    @orders = @search.result

    @taxons = email_taxons
    @countries = email_countries

    @emails = @orders.pluck(:email).uniq
  end

  private

  def email_taxons
    Spree::Taxon.all.sort_by(&:name)
  end

  def email_countries
    Spree::Country.all.sort_by(&:name)
  end

end
