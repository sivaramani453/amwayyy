function check_file_closure(slog,filebeat_input_log)               # checking input for file closure to avoid last string hanging in buffer
{
  if (slog ~ filebeat_input_log)     # checking if filebeat-in log file is read
  {
        if ($0~/Closing because close_inactive/) # if input file is closed, output last buffered line from this file and clear buffer
        {
                m = match($0, "File is inactive:")
                n = match($0, "Closing because close_inactive")
                closed_log = substr($0,m+18,n-m-20)
                gsub(/\\/,"\\\\",closed_log)
                if (closed_log in message)
                        outmulti(closed_log)
                for (key in field)
                        delete field[key]
                delete timestamp[closed_log]
        }
        next
  }
}
