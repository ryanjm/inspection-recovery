class String
  def api_date
    # Old format: 2013-04-05T13:42:15-0600:00
    # New format: 2013-04-08 19:03:00 +0000
    # 2014-03-16 23:11:47 MDT
    d = DateTime.strptime(self, '%Y-%m-%d %H:%M:%S %Z')
    d.strftime("%Y-%m-%d %H:%M:%S %z")
  end
end
