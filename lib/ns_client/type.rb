module NsClient
  module Type
    TOPICS = {
      sms: 'notification.fct.sms',
      push: 'notification.fct.push',
      slack: 'notification.fct.slack',
      email: 'notification.fc.email'
    }.freeze

    PATHS = {
      sms: '/notification/sms',
      push: '/notification/push',
      slack: '/notification/slack',
      email: '/notification/email'
    }.freeze
  end
end