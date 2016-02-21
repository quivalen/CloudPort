module Build::Tips

  def os
    unless @os
      name = self.class.operating_systems[operating_system]
      bits = self.class.cpu_architectures[cpu_architecture]

      @os = "#{name} (#{bits})"
    end

    @os
  end

  def tip
    if windows?
      return "Unbelievable, all you need to do is just download and run application we have built!"
    end

    "Download application. Set executable bit with \"chmod +x #{binary_file_name}\" and run it!"
  end

end
