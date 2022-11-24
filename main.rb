# frozen_string_literal: true

require 'midi-smtp-server'

# Server class
class SendmailProxy < MidiSmtpServer::Smtpd

  # get each message after DATA <message> .
  def on_message_data_event(ctx)
    # Output for debug
    logger.debug("mail received at: [#{ctx[:server][:local_ip]}:#{ctx[:server][:local_port]}] from: [#{ctx[:envelope][:from]}] for recipient(s): [#{ctx[:envelope][:to]}]...")

    # handle incoming mail, just show the message source
    logger.debug(ctx[:message][:data])
  end

end

# Create a new server instance for listening at localhost interfaces 127.0.0.1:2525
# and accepting a maximum of 4 simultaneous connections per default
server = SendmailProxy.new

# save flag for Ctrl-C pressed
flag_status_ctrl_c_pressed = false

# try to gracefully shutdown on Ctrl-C
trap('INT') do
  # print an empty line right after ^C
  puts
  # notify flag about Ctrl-C was pressed
  flag_status_ctrl_c_pressed = true
  # signal exit to app
  exit 0
end

# Output for debug
server.logger.info("Starting SendmailProxy [#{MidiSmtpServer::VERSION::STRING}|#{MidiSmtpServer::VERSION::DATE}] (Basic usage) ...")

# setup exit code
at_exit do
  # check to shutdown connection
  if server
    # Output for debug
    server.logger.info('Ctrl-C interrupted, exit now...') if flag_status_ctrl_c_pressed
    # info about shutdown
    server.logger.info('Shutdown SendmailProxy...')
    # stop all threads and connections gracefully
    server.stop
  end
  # Output for debug
  server.logger.info('SendmailProxy down!')
end

# Start the server
server.start

# Run on server forever
server.join
