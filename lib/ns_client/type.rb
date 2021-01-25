require 'protos/notification/sms/sms_pb'
require 'protos/notification/push/android_pb'
require 'protos/notification/push/ios_pb'
require 'protos/notification/slack/slack_pb'

module NsClient
  module Type
    TOPICS = {
      sms: 'notification.fct.sms',
      push_android: 'notification.fct.push_android',
      push_ios: 'notification.fct.push_ios',
      slack: 'notification.fct.slack',
      email: 'notification.fc.email'
    }.freeze

    PATHS = {
      sms: '/notification/sms',
      push_android: '/notification/push/android',
      push_ios: '/notification/push/ios',
      slack: '/notification/slack',
      email: '/notification/email'
    }.freeze

    REQUESTS = {
      sms: Protos::Notification::Sms::Request,
      push_android: Protos::Notification::Push::Android::Request,
      push_ios: Protos::Notification::Push::Ios::Request,
      slack: Protos::Notification::Slack::Request,
      email: 'TODO'
    }.freeze

  end
end