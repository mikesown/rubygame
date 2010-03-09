class JobComplete < ActionMailer::Base

  def complete_mail(result, recipient)
    @recipients = recipient
    @subject = "Ruby Game Job Complete"
    @from = "cs105rubygame@gmail.com"
    @headers = {}
    @body = {:recipient => recipient, :result =>result}
  end  

end
