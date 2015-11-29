unless Dir.exist?(CloudPort::Application.config.build_root)
  FileUtils.mkdir_p(CloudPort::Application.config.build_root)
end
