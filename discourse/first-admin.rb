# frozen_string_literal: true
# Runs once on the first boot of the Railway template (see first-admin-run).

# Railway terminates TLS at its edge, so links in emails and redirects must use https.
SiteSetting.force_https = true if ENV["RAILWAY_PUBLIC_DOMAIN"].present?

if User.real.where(admin: true).exists?
  puts "railway-first-admin: an admin already exists, nothing to do"
  exit 0
end

email = ENV["DISCOURSE_DEVELOPER_EMAILS"].to_s.split(",").first.to_s.strip
password = ENV["ADMIN_PASSWORD"].to_s
abort "railway-first-admin: DISCOURSE_DEVELOPER_EMAILS is empty" if email.empty?
abort "railway-first-admin: ADMIN_PASSWORD must be at least 15 characters" if password.length < 15

user = User.find_by_email(email) || User.new(email: email)
user.username = UserNameSuggester.suggest(email) if user.username.blank?
user.name = user.username if user.name.blank?
user.password = password
user.active = true
user.approved = true
user.save!
user.activate
user.grant_admin!
user.change_trust_level!(TrustLevel[4])
user.email_tokens.update_all(confirmed: true)

puts "railway-first-admin: created admin #{user.username} <#{email}>"
