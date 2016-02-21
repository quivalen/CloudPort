module Build::Globals

  def ssh_port_offset
    CloudPort::Application.config.ssh_port_offset
  end

  def build_root
    CloudPort::Application.config.build_root
  end

  def ptu_repo_url
    CloudPort::Application.config.ptu_repo_url
  end

  def ptu_repo_tar
    CloudPort::Application.config.ptu_repo_tar
  end

  def ptu_tailor_command
    CloudPort::Application.config.ptu_tailor_command
  end

end
