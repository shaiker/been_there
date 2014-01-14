require 'active_support/core_ext'
require 'active_support'
require 'csv'
class AccessLogCsvParser


  TITLES = ["ip", "date", "time", "http_action", "response_code", "object", "object_id", "action"]

  LINE_STRUCTURE = { 
    ip: 0, 
    donno1: 1,
    donno2: 2,
    datetime: 3,
    timezone_diff: 4,
    http_action: 5,
    request_url: 6,
    http_version: 7,
    response_code: 8
  }

  def parse(log_file, params_list_file, csv_output)
    @params_list_file = params_list_file
    @csv_output = (csv_output + "/logs_#{Time.now.strftime("%d-%m-%Y")}.csv").gsub("//", "/")
    lines_hashes = []
    log_lines = File.read(log_file).split("\n")
    log_lines.each do |line|
      parsed_line = parse_line(line)
      update_params_list(parsed_line[:params].keys)
      lines_hashes << parsed_line.with_indifferent_access
    end
    export_csv lines_hashes
  end

  def export_csv(hashes)
    CSV.open(@csv_output,"w") do |row|
      row << TITLES + params_list
      hashes.each do |hash|
        cur_row = []
        TITLES.each { |title| cur_row << hash[title] || "" }
        params_list.each { |param| cur_row << hash[:params][param] || "" }

        row << cur_row.map { |val| val.to_s.gsub("\"", "") }
      end
    end
  end

  def parse_line(line)
    split_line = line.split(" ")
    line_hash = {}
    line_hash[:ip] = split_line[LINE_STRUCTURE[:ip]]
    line_time = get_time(split_line[LINE_STRUCTURE[:datetime]])
    line_hash[:date] = line_time[:date] 
    line_hash[:time] = line_time[:time]
    line_hash[:http_action] = split_line[LINE_STRUCTURE[:http_action]]
    line_hash[:response_code] = split_line[LINE_STRUCTURE[:response_code]]

    request_hash = parse_request(split_line[LINE_STRUCTURE[:request_url]])

    return line_hash.merge(request_hash)
  end

  def params_list
    @params_list ||= File.read(@params_list_file).split("\n")
  end

  def update_params_list(current_params)
    current_params.map!(&:to_s)
    new_params_list = params_list | current_params
    if new_params_list.size > params_list.size
      @params_list = new_params_list
      File.write(@params_list_file, new_params_list.join("\n"))
    end
  end

  def get_time(raw_time)
    matches = raw_time.match(/(\d\d\/\w\w\w\/\d\d\d\d):(\d\d:\d\d:\d\d)/)
    return { date: matches[1], time: matches[2] }
  end

  def parse_request(url)
    path, qs = url.split("?")
    qs ||= ""
    matches = path.match(/\/(\w+)\/?(\d*)\/?(\w*)/) || []
    qs_tuples = qs.split("&")
    return {
      object: matches[1],
      object_id: matches[2],
      action: matches[3].present? ? matches[3] : "index",
      params: qs_tuples.each_with_object({}) { |tuple, hash| hash[tuple.split("=")[0].to_sym] = tuple.split("=")[1] }.with_indifferent_access
    }
  end

end

#AccessLogCsvParser.new.parse("/Users/shai/Desktop/kokavo_log_example.log", "/Users/shai/Desktop/params_list.txt", "/Users/shai/Desktop/csvs")
AccessLogCsvParser.new.parse(ARGV[0], ARGV[1], ARGV[2])
