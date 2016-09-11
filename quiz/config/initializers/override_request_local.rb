class ActionDispatch::Request
  def local?
     (LOCALHOST + ["213.138.73.146"]).any? { |local_ip| local_ip === remote_addr && local_ip === remote_ip }
  end
end
