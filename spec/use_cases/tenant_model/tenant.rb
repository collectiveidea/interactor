# # Check out these methods:
# #  - contextual_email_template
# #  - user_statistics
# #  - unmapped_statistics
# #  - web_to_csv
# #  - sales_tag_to_csv
# #  - links_urls_to_csv
# #  - calculate_company_lifetime_values
# #  - dirty_update
# class Tenant < ActiveRecord::Base
#   extend RailsUpgrade

#   default_scope { order(name: :asc) }

#   belongs_to :enterprise, **belongs_to_required
#   validates :enterprise, presence: { message: "must exist" } if rails4?

#   has_and_belongs_to_many :groups
#   has_many :account_history_data, inverse_of: :tenant, class_name: "AccountHistoryData"
#   has_many :action_logs, inverse_of: :tenant
#   has_many :activities, inverse_of: :tenant
#   has_many :addresses, inverse_of: :tenant
#   has_many :adjustments, inverse_of: :tenant
#   has_many :api_logs, inverse_of: :tenant
#   has_many :assets, inverse_of: :tenant
#   has_many :background_jobs, inverse_of: :tenant
#   has_many :backups, inverse_of: :tenant
#   has_many :budgets
#   has_many :business_plans
#   has_many :campaigns, inverse_of: :tenant
#   has_many :campaign_calendar_entries, inverse_of: :tenant
#   has_many :campaign_counts, inverse_of: :tenant
#   has_many :cash_sales
#   has_many :comments, inverse_of: :tenant
#   has_many :companies, inverse_of: :tenant
#   has_many :contacts, inverse_of: :tenant
#   has_many :contact_groups, inverse_of: :tenant
#   has_many :contact_lists, inverse_of: :tenant
#   has_many :contact_list_counts, inverse_of: :tenant
#   has_many :contact_list_exclusions, inverse_of: :tenant
#   has_many :deployments, inverse_of: :tenant
#   has_many :emails, inverse_of: :tenant
#   has_many :email_credentials, inverse_of: :tenant
#   has_many :email_templates, inverse_of: :tenant
#   has_many :email_validations, inverse_of: :tenant
#   has_many :estimates, inverse_of: :tenant
#   has_many :estimate_elements, inverse_of: :tenant
#   has_many :etl_settings, inverse_of: :tenant
#   has_many :events, inverse_of: :tenant
#   has_many :event_stats, inverse_of: :tenant
#   has_many :filter_defaults, inverse_of: :tenant
#   has_many :hidden_email_templates, inverse_of: :tenant
#   has_many :hidden_holidays, inverse_of: :tenant
#   has_many :holidays, inverse_of: :tenant
#   has_many :identities, inverse_of: :tenant
#   has_many :imports
#   has_many :inquiries, inverse_of: :tenant
#   has_many :interest_contexts, inverse_of: :tenant
#   has_many :invoices, inverse_of: :tenant
#   has_many :invoice_elements, inverse_of: :tenant
#   has_many :locations, inverse_of: :tenant
#   has_many :logs
#   has_many :meetings, inverse_of: :tenant
#   has_many :metric_results
#   has_many :metrics
#   has_many :next_activities, inverse_of: :tenant
#   has_many :notes, inverse_of: :tenant
#   has_many :shipments, inverse_of: :tenant
#   has_many :orders, inverse_of: :tenant
#   has_many :invoiced_orders, inverse_of: :tenant, class_name: "Order" # mbe / for dev
#   has_many :phone_calls
#   has_many :pings, inverse_of: :tenant
#   has_many :pending_attachments, inverse_of: :tenant
#   has_many :phone_calls, inverse_of: :tenant
#   has_many :portal_comments, inverse_of: :tenant
#   has_many :production_locations, inverse_of: :tenant
#   has_many :proofs, inverse_of: :tenant
#   has_many :reports, inverse_of: :tenant
#   has_many :sales, inverse_of: :tenant
#   has_many :sales_base_taxes, inverse_of: :tenant
#   has_many :sales_categories, inverse_of: :tenant
#   has_many :sales_reps, inverse_of: :tenant
#   has_many :sales_rep_updates, inverse_of: :tenant
#   has_many :sales_summaries, inverse_of: :tenant
#   has_many :sales_summary_pickups, inverse_of: :tenant
#   has_many :salestargets, inverse_of: :tenant
#   has_many :saved_reports, inverse_of: :tenant
#   has_many :sms_templates, inverse_of: :tenant
#   has_many :statistics, inverse_of: :tenant
#   has_many :tags, inverse_of: :tenant
#   has_many :tag_categories, inverse_of: :tenant
#   has_many :taken_bys, inverse_of: :tenant
#   has_many :taken_by_updates, inverse_of: :tenant
#   has_many :targets, inverse_of: :tenant
#   has_many :tasks, dependent: :destroy
#   # has_many :task_types, inverse_of: :tenant # TODO investigate/refactor
#   has_many :unsubscribes, inverse_of: :tenant
#   has_many :workflows, inverse_of: :tenant
#   has_many :holidays
#   # has_many :task_types
#   has_many :lead_types
#   has_many :prospect_status_items
#   has_many :notes
#   has_many :meetings
#   has_many :wips
#   has_many :company_metrics

#   has_many :next_activities
#   has_many :sales_tag_by_months

#   scope :real, -> { enabled.where(training: false, demo: false) }
#   scope :enabled, -> { where(inital_import_complete: true) }
#   scope :disabled, -> { where(inital_import_complete: false) }

#   scope :mbe, -> { joins(:enterprise).where(enterprises: {platform_type: "mbe"}) }
#   scope :printsmith, -> { joins(:enterprise).where(enterprises: {platform_type: "printsmith"}) }

#   # scope :mbehub_connected, -> {
#   #   mbehub.where.not(mbe_username: [nil, ""]).
#   #   where.not(mbe_password: [nil, ""]).
#   #   where.not(mbe_tenant_id: nil).
#   #   where.not(mbe_multistore_id: nil).
#   #   where.not(mbe_store_id: nil)
#   # }

#   validate do |tenant|
#     begin
#       Mail::Address.new("#{tenant.marketing_name} <test@test.com>").format
#     rescue Mail::Field::ParseError
#       tenant.errors[:base] << "Marketing name contains invalid characters"
#     end
#   end

#   def needs_taken_by_mappings
#     if taken_by_for_locations
#       if locations.where(location_id: nil).count > 0
#         return true
#       else
#         return false
#       end
#     else
#       if taken_bys.where(user_id: nil).count > 0
#         return true
#       else
#         return false
#       end
#     end
#   end

#   # TODO: @refactor https://app.clickup.com/t/4azpgb
#   def connection
#     @_connection ||= PG.connect( to_db_connection )
#   end

#   def ngrok_connector
#     "#{ngrok_uuid}.#{PrintSpeak::Application.ngrok_domain}"
#   end

#   def display_name
#     tenant_picker_name.blank? ? name : tenant_picker_name
#   end

#   def to_s
#     name
#   end

#   # TODO: @refactor can a gem do this?
#   def estimate_name_enforce?
#     estimate_name_enforce
#   end

#   # TODO: @refactor can a gem do this?
#   def invoice_name_enforce?
#     invoice_name_enforce
#   end

#   # TODO: @refactor can a gem do this?
#   def shipment_name_enforce?
#     false
#   end

#   def preferred_estimate_name
#     return estimate_name if estimate_name_enforce?
#     estimate_name_default
#   end

#   def preferred_invoice_name
#     return invoice_name if invoice_name_enforce?
#     invoice_name_default
#   end

#   def preferred_shipment_name
#     return ""
#   end

#   # TODO: @decorator @presenter
#   def estimate_name_default_friendly
#     URI.unescape(estimate_name_default) if estimate_name_default
#   end

#   def estimate_name_list_friendly
#     return estimate_name_list.split(",").map { |z| "#{URI.unescape(z)}" } if estimate_name_list
#     return ""
#   end

#   def estimate_name_friendly
#     return URI.unescape(estimate_name) if estimate_name
#     return ""
#   end

#   def invoice_name_default_friendly
#     URI.unescape(invoice_name_default) if invoice_name_default
#   end

#   def invoice_name_list_friendly
#     return invoice_name_list.split(",").map { |z| "#{URI.unescape(z)}" } if invoice_name_list
#     return ""
#   end

#   def invoice_name_friendly
#     return URI.unescape(invoice_name) if invoice_name
#     return ""
#   end

#   def use_printsmith_api_v3?
#     return true if (printsmith_api_version == "v3.0" || printsmith_api_version == "no such service" || printsmith_api_version.blank?) && enforce_old_printsmith_api == false
#     return false
#   end

#   def sms_allowed?
#     return true if self.sms_send_number.present? && self.use_sms.present?
#     return false
#   end

#   def last_successful_import_date(resource_type)
#     send(resource_type).order("updated_at DESC").first.try(:updated_at) || Date.new(1900, 1, 1)
#   end

#   def ngrok_config_yml
#     <<~EOY
#       pprof_addr: 127.0.0.1:4041
#       server_addr: #{PrintSpeak::Application.ngrok_tunnel}
#       authtoken: #{ngrok_authtoken}
#       tunnels:
#         db:
#           proto: pg
#           addr: #{printsmith_local_port || "5432"}
#           remote_addr: #{ngrok_remote_addr}
#           crt: c:\\ngrok\\#{ngrok_uuid}.crt
#           key: c:\\ngrok\\#{ngrok_uuid}.key.insecure
#         admin:
#           proto: http
#           bind_tls: false
#           addr: 9191
#           hostname: #{ngrok_connector}
#     EOY
#   end

#   def change_to_time_zone(time)
#     time.asctime.in_time_zone(time_zone)
#   end

#   # These will be replaced with a day or month depending on if the tenant is set for day or month first
#   # %%DM the day or month zero padded (%d or %m)
#   # %%_DM the day or month blank padded (%e or %_m)
#   # %%-DM the day or month no padded (%-d or %-m)
#   def local_strftime(time, format = "%%DM-%%DM-%Y", default_value = "Invalid")
#     result = default_value

#     day = !display_month_first
#     format = day_month_replacement(format, day)
#     day = !day
#     format = day_month_replacement(format, day)
#     result =   time.in_time_zone(time_zone).strftime(format) unless time.nil?

#     result
#   end

#   def day_month_replacement(format = "", day = true)
#     result = format
#     match = format.match(/%%([_-]?)DM/)
#     if match
#       variation = match.captures.first
#       case variation
#       when "-"
#         result = format.sub(match.to_s, day ? "%-d" : "%-m")
#       when "_"
#         result = format.sub(match.to_s, day ? "%e" : "%-m")
#       else
#         result = format.sub(match.to_s, day ? "%d" : "%m")
#       end
#     end
#     result
#   end

#   def date_format(stftime_format = true)
#     if stftime_format
#       display_month_first ? "%m-%d-%Y" : "%d-%m-%Y"
#     else
#       display_month_first ? "MM-DD-YYYY" : "DD-MM-YYYY"
#     end
#   end

#   def parse_datetime(datetime)
#     result = nil

#     begin
#       if display_month_first
#         result = DateTime.strptime(datetime, "%m-%d-%Y %l:%M %p")
#       else
#         result = DateTime.strptime(datetime, "%d-%m-%Y %l:%M %p")
#       end
#     rescue
#     end

#     result
#   end

#   def parse_date(date)
#     result = nil

#     begin
#       if display_month_first
#         result = DateTime.strptime(date, "%m-%d-%Y").to_date
#       else
#         result = DateTime.strptime(date, "%d-%m-%Y").to_date
#       end
#     rescue
#     end

#     result
#   end

#   def backup_config
#     if self.backup_api_key.blank?
#       self.backup_api_key = SecureRandom.hex(32)
#       self.save
#     end
#     backup_password = self.backup_api_key
#     backup_password = Rails.application.secrets.build_update_http_basic_password if backup_password.blank?

#     config = Hash.new
#     config["Times"] = [{Hour: 22, Minute: 30, Second: 0}]
#     config["TenantId"] = id
#     config["Updater"] = {Url: Rails.application.routes.url_helpers.url_for(controller: :builds, action: :update, only_path: false), User: "update", Password: backup_password}
#     config["NotifyAPI"] = Rails.application.routes.url_helpers.url_for(controller: :backups, action: :create, only_path: false)
#     config["LocalPath"] = local_path
#     config["PgDumpPath"] = pgdump_path
#     config["BackupFolder"] = backup_path
#     config["RetryInterval"] = 60
#     config["MaxAgeInDays"] = 30
#     config["Database"] = {Host: "127.0.0.1", Port: printsmith_local_port || "5432", Name: printsmith_database, User: printsmith_username, Password: printsmith_password}
#     config["S3"] = {Region: s3_region, Bucket: s3_bucket, AccessKey: s3_access_key, ClientSecret: s3_client_secret}
#     config["HoneybadgerKey"] = Rails.env.production? ? "1912fcf8" : ""
#     config
#   end

#   def cogs_color(cogs)
#     result = "grey"
#     if cogs <= self.cog_green_threshold
#       result = "green"
#     elsif cogs > self.cog_green_threshold && cogs <= self.cog_orange_threshold
#       result = "orange"
#     elsif cogs > self.cog_orange_threshold
#       result = "red"
#     end
#     result
#   end

#   def cogs_panel_color(cogs)
#     result = "default"
#     if cogs <= self.cog_green_threshold
#       result = "success"
#     elsif cogs > self.cog_green_threshold && cogs <= self.cog_orange_threshold
#       result = "orange"
#     elsif cogs > self.cog_orange_threshold
#       result = "danger"
#     end
#     result
#   end

#   def default_identity
#     Identity.where(tenant_id: id, default: true).first
#   end

#   def due_campaigns
#     due_campaigns = []
#     scheduled_campaigns = Campaign.require_selected_enterprise(self).without_hidden(self).scheduled(self).where(enterprise_id: self.enterprise_id).where("(tenant_id = ? OR global = ?)", self.id, true).to_a
#     scheduled_campaigns.each do |campaign|
#       due_campaigns << campaign if campaign.due_today(self)
#     end

#     return due_campaigns
#   end

#   def due_campaigns_color
#     result = "primary"

#     red = false
#     green = false

#     self.due_campaigns.each do |campaign|
#       if campaign.schedule_auto_send && !campaign.awaiting_approval(self)
#         green = true
#       else
#         red = true
#       end
#     end

#     if red && green
#       result = "orange"
#     elsif red
#       result = "red"
#     elsif green
#       result = "green"
#     end

#     result
#   end

#   def financial_months
#     (1..12).to_a.rotate(financial_year_start_month - 1)
#   end

#   # GET THE RIGHT YEAR GIVEN A CURRENT MONTH AND A SET FINANCIAL YEARR
#   def financial_year_of(month, year)
#     # CONDITIONS
#     # AU[7,6] .. for values between 1-6
#     not_overlaping_months_in_year = (month < financial_year_start_month and financial_year_start_month > financial_year_end_month)
#     # US[1,12] .. for all values
#     straight_months_in_year = (month >= financial_year_start_month and financial_year_start_month < financial_year_end_month)

#     if not_overlaping_months_in_year or straight_months_in_year
#       year
#     else
#       year-1
#     end
#   end

#   def financial_year_from_date(date)
#     # NOT WORKING
#     FinancialYear.new(self).year(Time.new(date.year, date.month, date.day, 0, 0, 0, Time.now.in_time_zone(time_zone).strftime("%:z")).to_date)
#   end

#   def current_budget(year = nil)
#     if year.present?
#       budgets.where(financial_year: FinancialYear.new(self).year(Time.new(year, 1, 1, 0, 0, 0, Time.now.in_time_zone(time_zone).strftime("%:z")).to_date)).first
#     else
#       budgets.where(financial_year: FinancialYear.new(self).year(Time.now.in_time_zone(time_zone).to_date)).first
#     end
#   end

#   def setup_ngrok
#     auth = {username: Rails.application.secrets.ngrok_username, password: Rails.application.secrets.ngrok_password}

#     if self.ngrok_uuid.blank?
#       self.ngrok_uuid = SecureRandom.uuid
#       self.save
#     end

#     if self.ngrok_authtoken.blank?
#       url    = "https://api.ngrok.com/credentials"
#       body   = {"description" => "Print Speak API"}
#       result = HTTParty.post(url, basic_auth: auth, headers: {"Ngrok-Version" => "0"} ,body: body).parsed_response
#       self.ngrok_authtoken = result["token"]
#       self.save
#     end

#     if self.ngrok_remote_addr.blank?
#       url    = "https://api.ngrok.com/reserved_addrs"
#       body   = {"region" => RegionConfig.require_value("region")}
#       result = HTTParty.post(url, basic_auth: auth, headers: {"Ngrok-Version" => "0"} ,body: body).parsed_response
#       self.ngrok_remote_addr = result["addr"]
#       self.save
#     end

#     root_ca = OpenSSL::X509::Certificate.new(File.read("#{Rails.root}/.ca/ca.crt"))

#     needs_cert = self.ngrok_crt.blank? || self.ngrok_key.blank?
#     if !needs_cert
#       begin
#         cert = OpenSSL::X509::Certificate.new(self.ngrok_crt)
#         key = OpenSSL::PKey::RSA.new(self.ngrok_key)
#         needs_cert = true unless cert.check_private_key(key) && cert.verify(root_ca.public_key)
#       rescue
#         needs_cert = true
#       end
#     end

#     if needs_cert
#       root_key = OpenSSL::PKey::RSA.new(Rails.application.secrets.ngrok_ca_key)

#       key = OpenSSL::PKey::RSA.new(4096)
#       cert = OpenSSL::X509::Certificate.new
#       cert.version = 2
#       cert.serial = "0x#{self.ngrok_uuid.tr('-', '')}".hex
#       cert.subject = OpenSSL::X509::Name.parse("/C=USA/O=etcd-ca/OU=#{ngrok_uuid}/CN=127.0.0.1")
#       cert.issuer = root_ca.subject
#       cert.public_key = key.public_key
#       cert.not_before = Time.now
#       cert.not_after = root_ca.not_after
#       ef = OpenSSL::X509::ExtensionFactory.new
#       ef.subject_certificate = cert
#       ef.issuer_certificate = root_ca
#       cert.add_extension(ef.create_extension("extendedKeyUsage", "clientAuth,serverAuth", false))
#       cert.add_extension(ef.create_extension("subjectKeyIdentifier", "hash", false))
#       cert.add_extension(ef.create_extension("authorityKeyIdentifier", "keyid:always", false))
#       cert.add_extension(ef.create_extension("subjectAltName", "IP: 127.0.0.1", false))
#       cert.sign(root_key, OpenSSL::Digest.new("SHA256"))

#       self.ngrok_crt = cert.to_pem
#       self.ngrok_key = key.to_pem
#     end

#     self.save
#   end

#   def admin_test_emails
#     users.where(role: "Admin").pluck(:test_email).map{|s| s unless s.try(:strip).blank?}.compact.uniq
#   end

#   def users
#     enterprise.users.where(tenant_id: id)
#   end

#   def primary_users
#     users.where("users.parent_id = users.id")
#   end

#   def visible_users
#     if enterprise.show_multi_users
#       users.where(role: ["User", "Admin"])
#     else
#       primary_users.where(role: ["User", "Admin"])
#     end
#   end

#   def user_inboxes(users = nil)
#     result = EmailInbox.none

#     users = self.primary_users if users.nil?
#     if users && users.count > 0
#       query = %Q{
#         SELECT id, address, users, users_array->>'user_id' AS user_id
#         FROM inboxes, json_array_elements(users::json) users_array
#         WHERE json_typeof(users::json) = 'array'
#         AND users_array->>'user_id' IN (#{users.pluck(:id).map{|s| "'#{s}'"}.to_csv})
#         AND users_array->>'tenant_id' = '#{self.id}'
#       }
#       result = EmailInbox.find_by_sql(query)
#     end

#     result
#   end

#   def test_emails
#     result = []

#     result = test_email.split(",").map{|s| s.try(:strip)}.compact.uniq unless test_email.try(:strip).blank?

#     result = admin_test_emails if result.count == 0

#     result
#   end

#   def banner
#     Asset.where(id: self.banner_id, enterprise_id: self.enterprise_id, category: "Banner").first
#   end

#   def wanted_skip_weekend
#     date_after_days_skip_weekend(self.wanted_days || 0)
#   end

#   def reorder_skip_weekend
#     date_after_days_skip_weekend(self.reorder_days)
#   end

#   def contextual_email_template(klass)
#     template_ids = EmailTemplate.by_tenant(self).pluck(:id)
#     result = 0

#     if klass == Estimate
#       result = self.estimate_email_template
#       result = self.enterprise.default_estimate_emailt_id if result.nil? || result == 0
#     elsif klass == Order
#       result = self.order_email_template
#       result = self.enterprise.default_order_emailt_id if result.nil? || result == 0
#     elsif klass == Sale
#       result = self.sale_email_template
#       result = self.enterprise.default_sale_emailt_id if result.nil? || result == 0
#     elsif klass == Contact
#       result = self.contact_email_template
#       result = self.enterprise.default_contact_emailt_id if (result.nil? || result == 0)
#     elsif klass == Company
#       result = self.company_email_template
#       result = self.enterprise.default_company_emailt_id if result.nil? || result == 0
#     elsif klass == Inquiry
#       result = self.inquiry_email_template
#       result = self.enterprise.default_inquiry_emailt_id if result.nil? || result == 0
#     end

#     result = 0 unless template_ids.include?(result)

#     result = self.enterprise.default_email_template_id if result.nil? || result == 0

#     result

#   end

#   def contacts_matching_email(email_address)
#     clean_email = Email.clean_email(email_address)

#     result = Contact.none
#     if !clean_email.blank?
#       result = Contact.where(tenant_id: self.id).where("LOWER(TRIM(contacts.email)) = ?", clean_email)
#     end

#     result
#   end

#   def unsubscribe_email_addresses(addresses, type, data: {}, ignore_id: 0)
#     if !addresses.try(:count).nil? && addresses.try(:count) > 0
#       addresses.each do |address|
#         contacts = Contact.where(tenant_id: self.id).where("LOWER(TRIM(email)) = ?", address.downcase) unless address.blank?
#         contacts.each do |contact|
#           next if contact.id == ignore_id
#           contact.unsubscribe(type, data: data, propagate: false)
#         end
#       end
#     end
#   end

#   def user_statistics(statistic_for, start_date, end_date)
#     user_type = "user"
#     name_select = "users.first_name, users.last_name"
#     stats = self.primary_users
#     if self.sales_rep_for_locations && !statistic_for.index(/location/).nil?
#       user_type = "location"
#       name_select = "locations.name"
#       stats = self.locations
#     end

#     if Platform.is_mbe?(self)
#       stats.select("#{user_type}s.id, #{name_select}, COALESCE(SUM(statistics.invoiced_sales),0) AS total, rank() OVER (ORDER BY COALESCE(SUM(statistics.invoiced_sales),0) DESC, #{user_type}s.id ASC) AS position").
#           joins("LEFT OUTER JOIN statistics ON #{user_type}s.id = statistics.#{user_type}_id AND statistics.tenant_id = #{self.id} AND statistics.date BETWEEN '#{start_date.to_date}' AND '#{end_date.to_date}' AND statistics.statistic_for = '#{statistic_for}'").
#           group("#{user_type}s.id").
#           reorder("position ASC")
#     else
#       stats.select("#{user_type}s.id, #{name_select}, COALESCE(SUM(statistics.total),0) AS total, rank() OVER (ORDER BY COALESCE(SUM(statistics.total),0) DESC, #{user_type}s.id ASC) AS position").
#           joins("LEFT OUTER JOIN statistics ON #{user_type}s.id = statistics.#{user_type}_id AND statistics.tenant_id = #{self.id} AND statistics.date BETWEEN '#{start_date.to_date}' AND '#{end_date.to_date}' AND statistics.statistic_for = '#{statistic_for}'").
#           group("#{user_type}s.id").
#           reorder("position ASC")
#     end
#   end

#   def unmapped_statistics(statistic_for, start_date, end_date)
#     user_type = "user"
#     ids = self.primary_users.pluck(:id)
#     if self.sales_rep_for_locations && !statistic_for.index(/location/).nil?
#       user_type = "location"
#       ids = self.locations.pluck(:id)
#     end

#     result = Statistic.none
#     if ids.count > 0
#       result = Statistic.where(tenant_id: self.id, statistic_for: statistic_for, date: start_date..end_date).where("statistics.#{user_type}_id NOT IN (?) or statistics.#{user_type}_id IS NULL", ids)
#     end

#     result
#   end

#   def task_types
#     TaskType.tenant(self)
#   end

#   def admin_addresses
#     addresses = []
#     admin_users = self.primary_users.where(role: "Admin")
#     admin_users.each do |admin_user|
#       email_addr = admin_user.email
#       email_addr = admin_user.default_alias if !admin_user.default_alias.blank?
#       addresses << email_addr if !email_addr.blank?
#     end
#     addresses
#   end

#   def full_address
#     %Q{#{ApplicationController.helpers.combined_address(self.address_1, self.address_2)}, #{self.suburb} #{self.state}, #{self.postcode} }
#   end

#   def date_after_days_skip_weekend(days_number)
#     now = Time.zone.now.in_time_zone(self.time_zone)
#     date_helper = DateHelper.new(@start_date, @end_date, self)

#     initial_days_number = days_number
#     business_days = date_helper.business_days_between(now, now + initial_days_number.days)


#     while business_days <= initial_days_number
#       days_number += 1
#       business_days = date_helper.business_days_between(now, now + days_number.days)
#     end

#     # LOOP +1 RETURNING DATE UNTIL IT IS NOT A HOLIDAY
#     end_date_is_holiday = true

#     while end_date_is_holiday
#       holiday = Holiday.tenant(self).where('holiday_dates.date': now + days_number.days)

#       holiday.present? ? days_number += 1 : end_date_is_holiday = false
#     end

#     return now + days_number.days
#   end

#   def self.web_to_csv(data)
#     CSV.generate(col_sep: self.enterprise.csv_col_sep) do |csv|
#       desired_columns = ["Centre", "No. of Companies", "Orders #", "Sales", "Orders LY#", "Sales LY", "Avg. Order"]
#       csv << desired_columns
#       data.map do |tenant|
#         csv << [
#           "#{ tenant[:tenant_name] }",
#           "#{ tenant[:companies].try(:count) || 0 }",
#           "#{ tenant[:companies].map{ |c| c['invoice_count'].to_i }.sum }",
#           "$#{ tenant[:companies].map{ |c| c['invoice_value'].to_f }.sum }",
#           "#{ tenant[:companies].map{ |c| c['invoice_count_ly'].to_i }.sum }",
#           "$#{ tenant[:companies].map{ |c| c['invoice_value_ly'].to_f }.sum }",
#           "$#{ tenant[:companies].map{ |c| c['invoice_value'].to_f }.sum / tenant[:companies].map{ |c| c['invoice_count'].to_i }.sum }",
#         ]
#       end
#     end
#   end

#   def self.sales_tag_to_csv(data)
#     CSV.generate(col_sep: self.enterprise.csv_col_sep) do |csv|
#       desired_columns = ["Centre", "No. of Companies", "# of Invoices", "Tagged Sales", "# of Invoices LY", "Tagged Sales LY", "Avg. Order"]
#       csv << desired_columns
#       data.map do |tenant|
#         csv << [
#           "#{ tenant[:tenant_name] }",
#           "#{ tenant[:total_company_count] }",
#           "#{ tenant[:total_invoice_count] }",
#           "$#{ tenant[:total_sales] }",
#           "#{ tenant[:total_invoice_count_ly] }",
#           "$#{ tenant[:total_sales_ly] }",
#           "$#{ tenant[:avg_order] }",
#         ]
#       end
#     end
#   end

#   def self.links_urls_to_csv(data)
#     CSV.generate(col_sep: self.enterprise.csv_col_sep) do |csv|
#       columns = ["id", "number", "name", "blog", "facebook", "twitter", "instagram", "pinterest", "youtube", "linked_in", "website_url", "request_quote_url"]
#       csv << columns
#       data.map do |tenant|
#         csv << [
#           "#{tenant.id}",
#           "#{tenant.number}",
#           "#{tenant.name}",
#           "#{tenant.blog}",
#           "#{tenant.facebook}",
#           "#{tenant.twitter}",
#           "#{tenant.instagram}",
#           "#{tenant.pinterest}",
#           "#{tenant.youtube}",
#           "#{tenant.linked_in}",
#           "#{tenant.website_url}",
#           "#{tenant.request_quote_url}",
#         ]
#       end
#     end
#   end

#   def calculate_company_lifetime_values
#     begin
#       companies = self.companies.where(needs_lifetime_value_recalc: true).order("rolling_12_month_rank asc").limit(10)

#       if self.exclude_non_sales.nil?
#         self.exclude_non_sales = false
#       end

#       companies.each do |company|
#         account_id = company.platform_id
#         account_history_ids = AccountHistoryData.where(tenant: self, source_account_id: account_id).order(platform_id: :asc).pluck(:platform_id).to_csv

#         if !account_history_ids.empty?
#           total = 0
#           total += self.connection.exec(Queries::CompanyLifetimeValueQuery.new(account_id, account_history_ids, self.exclude_non_sales).lifetime_value_1).first["sum"].to_f
#           total += self.connection.exec(Queries::CompanyLifetimeValueQuery.new(account_id, account_history_ids, self.exclude_non_sales).lifetime_value_2).first["sum"].to_f
#           total += self.connection.exec(Queries::CompanyLifetimeValueQuery.new(account_id, account_history_ids, self.exclude_non_sales).lifetime_value_3).first["sum"].to_f
#           total += self.connection.exec(Queries::CompanyLifetimeValueQuery.new(account_id, account_history_ids, self.exclude_non_sales).lifetime_value_4).first["sum"].to_f
#           total += self.connection.exec(Queries::CompanyLifetimeValueQuery.new(account_id, account_history_ids, self.exclude_non_sales).lifetime_value_5).first["sum"].to_f
#           total += self.connection.exec(Queries::CompanyLifetimeValueQuery.new(account_id, account_history_ids, self.exclude_non_sales).lifetime_value_6).first["sum"].to_f
#           total += self.connection.exec(Queries::CompanyLifetimeValueQuery.new(account_id, account_history_ids, self.exclude_non_sales).lifetime_value_7).first["sum"].to_f
#           total += self.connection.exec(Queries::CompanyLifetimeValueQuery.new(account_id, account_history_ids, self.exclude_non_sales).lifetime_value_8).first["sum"].to_f
#           total -= self.connection.exec(Queries::CompanyLifetimeValueQuery.new(account_id, account_history_ids).lifetime_value_9).first["sum"].to_f
#           company.lifetime_value = total
#         end

#         company.needs_lifetime_value_recalc = false
#         company.save
#       end
#     rescue PG::ConnectionBad => e
#       # IGNORE, COMMON FOR CONNECTIONS TO BE DOWN AS REMOTE SYSTEMS ARE UNRELIABLE
#     rescue => e
#       raise e
#     end
#   end

#   def dirty_update
#     begin
#       Printsmith::Import::Invoice.new(self, 50, self.connection).perform_dirty_update
#       Printsmith::Import::Estimate.new(self, 50, self.connection).perform_dirty_update
#       Printsmith::Import::Invoice.new(self, 50, self.connection).perform_dirty_skip_pdf_update
#       Printsmith::Import::Estimate.new(self, 50, self.connection).perform_dirty_skip_pdf_update

#     rescue ActiveRecord::StatementInvalid
#     rescue PG::UnableToSend => e
#     rescue PG::ConnectionBad => e
#     rescue => e
#       # raise error if something other then connection issue
#       raise e
#     end
#   end

#   def address_blacklist
#     blacklist = []

#     if !self.email_blacklist.blank?
#       self.email_blacklist.lines.each do |address|
#         if address.include?("@")
#           clean_address = Email.clean_email(address)
#           blacklist << clean_address if !clean_address.blank?
#         end
#       end
#     end

#     if !self.enterprise.email_blacklist.blank?
#       self.enterprise.email_blacklist.lines.each do |address|
#         if address.include?("@")
#           clean_address = Email.clean_email(address)
#           blacklist << clean_address if !clean_address.blank?
#         end
#       end
#     end

#     blacklist.compact.uniq
#   end

#   def domain_blacklist
#     blacklist = []

#     if !self.email_blacklist.blank?
#       self.email_blacklist.lines.each do |domain|
#         if !domain.include?("@")
#           blacklist << domain.strip if !domain.strip.blank?
#         end
#       end
#     end

#     if !self.enterprise.email_blacklist.blank?
#       self.enterprise.email_blacklist.lines.each do |domain|
#         if !domain.include?("@")
#           blacklist << domain.strip if !domain.strip.blank?
#         end
#       end
#     end

#     blacklist.compact.uniq
#   end

#   def prospect_statuses
#     ProspectStatus.where(lead_type_id: 0, tenant_id: self.id, prospect_status_version_id: 0).order(name: :asc).all
#   end

#   def available_lead_types
#     if self.use_new_lead
#       LeadType.by_tenant(self)
#     else
#       available_old_lead_types
#     end
#   end

#   def available_old_lead_types
#     LeadType.by_tenant_old(self)
#   end

#   def used_archived_lead_types
#     LeadType.by_tenant_archived(self)
#   end

#   def default_lead_type
#     if self.use_new_lead && self.default_lead_type_id && self.show_lead_types
#       default_lead_type = self.default_lead_type_id
#     elsif self.use_new_lead && self.available_lead_types.where(is_default: true).first
#       default_lead_type = self.available_lead_types.where(is_default: true).first.id
#     elsif !self.use_new_lead
#       default_lead_type = self.available_lead_types.where(name: "New").first.try(:id)
#     end

#     lead_type = available_lead_types.where(id: default_lead_type).first || self.available_lead_types.first
#   end

#   def platform_lead_sources
#     if !Platform.is_mbe?(self)
#       self.lead_sources
#     else
#       LeadSource.where(enterprise_id: self.enterprise_id).pluck(:name).join(",").to_s
#     end
#   end

#   def couriers
#     result = {}

#     if self.platform_data && self.platform_data["couriers"]
#       result = self.platform_data["couriers"]
#     end

#     result
#   end

#   def courier_services(courier_id)
#     self.couriers.select{|courier| courier["id"].to_i == courier_id.to_i }.first.try(:[], "services") || []
#   end

#   private

#   def to_db_connection
#     # "connect_timeout=5 user=#{printsmith_username} password=#{printsmith_password} port=#{printsmith_port} host=#{printsmith_ip} dbname=#{printsmith_database} sslmode=verify-ca sslrootcert=#{Rails.root}/.ca/ca.crt"
#     "connect_timeout=5 user=#{printsmith_username} password=#{printsmith_password} port=#{printsmith_port} host=#{printsmith_ip} dbname=#{printsmith_database} sslmode=prefer sslrootcert=#{Rails.root}/.ca/ca.crt"

#     # if Rails.env.production?
#     #   "user=#{printsmith_username} password=#{printsmith_password} port=#{printsmith_port} host=#{printsmith_ip} dbname=#{printsmith_database} sslmode=prefer sslrootcert=#{Rails.root}/.ca/ca.crt"
#     # else
#     #   "user=postgres password=PrintSmith^2012 port=5432 host=localhost dbname=printsmith_db"
#     # end
#   end
# end
