class ContactsController < ApplicationController
  def new
    @user = current_user
    @contact = Contact.new
  end

  def confirm
    @user = current_user
    @contact = Contact.new(contact_params)
    if @contact.invalid?
      render "new"
    end
  end

  def back
    @user = current_user
    @contact = Contact.new(contact_params)
    render "new"
  end

  def create
    @user = current_user
    @contact = Contact.new(contact_params)
    if @contact.save
      ContactMailer.contact_mail(@contact).deliver_now
      redirect_to done_contacts_path
    else
      render "new"
    end
  end

  def done
    @user = current_user
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :content)
  end
end
