require 'protos/notification/sms/sms_pb'
require 'protos/notification/push/push_pb'
require 'protos/notification/slack/slack_pb'

module NsClient
  module Type
    TOPICS = {
      sms: 'notification.fct.sms',
      push: 'notification.fct.push',
      slack: 'notification.fct.slack',
      # email: 'notification.fc.email'
    }.freeze

    PATHS = {
      sms: '/notification/sms',
      push: '/notification/push',
      slack: '/notification/slack',
      # email: '/notification/email'
    }.freeze

    REQUESTS = {
      sms: Protos::Notification::Sms::Request,
      push: Protos::Notification::Push::Request,
      slack: Protos::Notification::Slack::Request,
      # email: 'TODO'
    }.freeze

  end
end