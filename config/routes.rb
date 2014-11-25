Spree::Core::Engine.routes.draw do
  get '/admin/reports/emails', to: 'admin/reports#emails', as: 'emails_report_admin_reports'
end
