Spree::Admin::ReportsController.class_eval do
  helper 'spree/base'

  before_action do
    self.class.add_available_report!(:emails_report)
  end

  def emails
    params[:q] = {} unless params[:q]

    if params[:q][:completed_at_gt].blank?
      params[:q][:completed_at_gt] = Time.zone.now.beginning_of_month
    else
      params[:q][:completed_at_gt] = Time.zone.parse(params[:q][:completed_at_gt]).beginning_of_day rescue Time.zone.now.beginning_of_month
    end

    if params[:q] && !params[:q][:completed_at_lt].blank?
      params[:q][:completed_at_lt] = Time.zone.parse(params[:q][:completed_at_lt]).end_of_day rescue Time.zone.now.end_of_month
    end

    if params[:q][:line_items_product_taxons_id_in].present?
      @search_taxon = Spree::Taxon.find(params[:q][:line_items_product_taxons_id_in])
      params[:q][:line_items_product_taxons_id_in] = Spree::Taxon.where("lft >= ? AND rgt <= ?", @search_taxon.lft, @search_taxon.rgt).pluck(:id)
    end

    if params[:q][:ship_address_country_id_eq].present?
      @search_country = Spree::Country.find(params[:q][:ship_address_country_id_eq])
    end

    params[:q][:s] ||= "completed_at desc"

    @search = Spree::Order.complete.ransack(params[:q])
    @orders = @search.result
    @emails = @orders.pluck(:email).uniq

    @taxons = email_taxons
    @countries = email_countries

    if params[:csv].present?
      csv_output = CSV.generate do |csv|
        csv << ["Email"]
        @emails.each do |email|
          csv << [email]
        end
      end

      send_data csv_output,
        type: 'text/csv; charset=iso-8859-1; header=present',
        disposition: "attachment; filename=emails.csv"
    end
  end

  private

  def email_taxons
    Spree::Taxon.all.sort_by(&:name)
  end

  def email_countries
    Spree::Country.all.sort_by(&:name)
  end

end
