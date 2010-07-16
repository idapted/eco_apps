module Idp
  class Util
    class << self
      def copy(src, dest, force = true)
        if not force and File.exist?(dest)
          return false
        else
          FileUtils.mkdir_p(dest) unless File.exist?(dest)
          FileUtils.remove_dir(dest, true)
          FileUtils.cp_r(src, dest)
          return true
        end
      end
    end
  end
end
