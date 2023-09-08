# Preview all emails at http://localhost:3000/rails/mailers/contact_mailer
class ContactMailerPreview < ActionMailer::Preview
  def contact_mail
    contact = Contact.new(
      name: "tester",
      email: "tester@example.com",
      content: "お問い合わせです。"
    )

    ContactMailer.contact_mail(contact)
  end
end
