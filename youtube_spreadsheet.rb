#!/usr/bin/env ruby
require "bundler"
Bundler.require

def set(ws, task, text)
  ws[task.status_row, task.status_col] = text
end

if File.exist? "access_token"
  access_token = File.read("access_token")
else
  client = Google::APIClient.new
  auth = client.authorization
  auth.client_id = "209536288277-t42nqjknqj1h80bu5k48q59262ftm7fo.apps.googleusercontent.com"
  auth.client_secret = "m0fQD_jXZRYbbvEh9kKn8Tz0"
  auth.scope =
    "https://www.googleapis.com/auth/drive " +
    "https://spreadsheets.google.com/feeds/"
  auth.redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
  print("1. Open this page:\n%s\n\n" % auth.authorization_uri)
  print("2. Enter the authorization code shown in the page: ")
  auth.code = $stdin.gets.chomp
  auth.fetch_access_token!
  access_token = auth.access_token
  File.write("access_token", access_token, mode: "w")
end

session = GoogleDrive.login_with_oauth(access_token)
puts "Loaded Session"

if File.exist? "spreadsheet_url"
  spreadsheet_url = File.read("spreadsheet_url")
else
  puts "Please enter the Spreadsheet URL:"
  spreadsheet_url = $stdin.gets.chomp
  File.write("spreadsheet_url", spreadsheet_url, mode: "w")
end

spreadsheet = session.spreadsheet_by_url spreadsheet_url
puts "Loaded Spreadsheet"
ws = spreadsheet.worksheets[0]
puts "Loaded Worksheet"

Task = Struct.new("Task", :url, :status_row, :status_col)

loop do
  tasks = []
  for row in 1..ws.num_rows
    for col in 1..ws.num_cols
      cell = ws[row, col]
      if cell.include?("youtube.com") || cell.include?("youtu.be")
        tasks << Task.new(cell, row, col + 1)
      end
    end
  end

  puts "Generated Tasks"

  tasks.select! do |task|
    ws[task.status_row, task.status_col] != "Done"
  end

  tasks.each { |task| set ws, task, "Queued" }

  tasks.each do |task|
    puts "Downloading #{task.url}"
    set ws, task, "Downloading"
    ws.save
    puts `youtube-dl -o "out/%(title)s.%(ext)s" -x #{task.url}`
    puts
    set ws, task, "Done"
  end
  ws.save

  sleep 300
  ws.synchronize
end
