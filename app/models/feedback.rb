class Feedback < ActiveRecord::Base
  attr_accessible :text, :user_id

  belongs_to :user

  after_create :send_mail

  private

  def send_mail
    ActionMailer::Base.mail(from: "beenthere@kokavo.com",
                            to: "arik@kokavo.com, inbal@kokavo.com, shai@kokavo.com",
                            subject: "from #{user.name} (id #{user_id})",
                            body: self.text).deliver
  end
end
