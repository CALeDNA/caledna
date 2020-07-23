# frozen_string_literal: true

module River
  class ContactsController < ApplicationController
    layout 'river/application'

    def new
      @block = PageBlock.find_by(slug: 'pour-contact')
      @contact = Contact.new
    end

    def create
      @contact = Contact.new(params[:contact])
      @contact.request = request
      if @contact.deliver
        flash.now[:success] = 'Thank you for your message!'
        redirect_to contact_us_path
      else
        flash.now[:alert] = 'Cannot send message.'
        render :new
      end
    end
  end
end
