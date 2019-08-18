class EditorMailer < ApplicationMailer

  def website_published_email
    website = params[:website]
    editor_info = params[:editor_info]
    @email_address = editor_info["email"]
    @editor_name = editor_info["displayName"]
    @website_name = website.project_name
    mail(to: @email_address, cc: "sharon@nomadiclabs.ca", subject: "#{@website_name} has been published!")
  end

end
