require "net/http"
require "uri"

class Notification < ActiveRecord::Base
  attr_accessible :generated_by_user_id, :notification_type
  belongs_to :image
  belongs_to :generated_by_user, class_name: "User"

  before_create :determine_push_type
  after_create :send_push

  TYPES = { been_there: 1, comment: 2 }
  PUSH = { no_push: -1, silent: 0, loud: 1 }

  def as_json(options = nil)
    {
      id: id,
      user: generated_by_user.as_json(options),
      image: image.as_json(options),
      type: TYPES.key(notification_type),
      digested: digested,
      opened: opened
    }
  end


  def pn_hash
    hash = {
      campaign_id: APP_CONFIG["appoxee"]["campaign_id"],
      application_id: APP_CONFIG["appoxee"]["application_id"],      
      name: "Been There",
      description: "Notification",
      type: 1,
      content_type: 1,
      push_body: "",
      push_badge: image.user.new_notifications_count,
      schedule_type: 0,
      timezone: "GMT",
      # overdue: 0,
      # schedule_date: Time.now.to_i,
      expire_date: 10.days.from_now.to_i,
      expire_timezone: "GMT",
      segments: [
        {
            name: "User", 
            description: "to a specific user",
            rules: [
                { 
                  field: "alias", 
                  operator: "=", 
                  operand: [ image.user.id.to_s ] 
                }
            ]
        }
      ]
    }  

    hash.merge!( { sound: "Blop", push_body: push_message } ) if push_type == PUSH[:loud]
    return hash
  end

  def push_message
    #TODO a more informative message
    msg = if push_type == PUSH[:silent]
      been_theres = image.been_theres.count
      comments = image.comments.count
      if been_theres > 0
        bt_verb = been_theres > 1 ? "Been Theres" : "Been There"
      end
      if comments > 0
        cm_verb = comments > 1 ? "comments" : "comment"
      end
      if been_theres > 0 && comments > 0
        "You got #{been_theres} '#{bt_verb}' and #{comments} #{cm_verb} on one of your photos"
      elsif been_theres > 0
        "You got #{been_theres} '#{bt_verb}' on one of your photos"
      else #if comments > 0
        "You got #{comments} #{cm_verb} on one of your photos"
      end
    else
      name = generated_by_user.anonymous? ? "Someone" : generated_by_user.name
      if notification_type == TYPES[:been_there]
        "#{name} clicked 'Been There' on your photo"
      else
        "#{name} commented on your photo"
      end
    end
    return msg
  end

  def send_push
    if push_type != PUSH[:no_push] 
      url = URI.parse('http://saas.appoxee.com/api/v3/message?finalize=1')
      initheader = {
        "Content-Type" => "application/json",
        "X-ACCOUNT_CODE" => "inbalee",
        "X-USERNAME" => ???????,
        "X-PASSWORD" => ???????
      }
      req = Net::HTTP::Post.new(url.request_uri, initheader)
      req.body = pn_hash.to_json

      response = Net::HTTP.new(url.host, url.port).request(req) if !Rails.env.development?
    end
  end
  
  private
  def determine_push_type
    last_loud = Notification.where(image_id: image.user.images.map(&:id), push_type: PUSH[:loud]).order("id DESC").limit(1).first
    self.push_type = if last_loud.present? && last_loud.created_at > 3.days.ago
      PUSH[:silent]
    else
      PUSH[:loud]
    end
  end

end

git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch app/models/notification.rb' --prune-empty --tag-name-filter cat -- --all
