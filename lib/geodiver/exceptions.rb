# This file defines all possible exceptions that can be thrown by
# GeoDiver on startup.
#
# Exceptions only ever inform another entity (downstream code or users) of an
# issue. Exceptions may or may not be recoverable.
#
# Error classes should be seen as: the error code (class name), human readable
# message (to_s method), and necessary attributes to act on the error.
#
# We define as many error classes as needed to be precise about the issue, thus
# making it easy for downstream code (bin/geodiver or config.ru) to act
# on them.

module GeoDiver
  # Error in config file.
  class CONFIG_FILE_ERROR < StandardError
    def initialize(ent, err)
      @ent = ent
      @err = err
    end

    attr_reader :ent, :err

    def to_s
      <<MSG
Error reading config file: #{ent}.
#{err}
MSG
    end
  end

  ## NUM THREADS ##

  # Raised if num_threads set by the user is incorrect.
  class NUM_THREADS_INCORRECT < StandardError
    def to_s
      'Number of threads should be a number greater than or equal to 1.'
    end
  end

  ## RCORE##

  # Raised if RCore cannot be used to generate the exemplar results
  class RCORE_FAILURE < StandardError
    def to_s
      'There seems to be an error in running the R core.'
    end
  end


  ## ENOENT ##

  # Name borrowed from standard Errno::ENOENT, this class serves as a template
  # for defining errors that mean "expected to find <entity> at <path>, but
  # didn't".
  #
  # ENOENT is raised if and only if an entity was set, either using CLI or
  # config file. For instance, it's compulsory to set database_dir. But ENOENT
  # is not raised if database_dir is not set. ENOENT is raised if database_dir
  # was set, but does not exist.
  class ENOENT < StandardError
    def initialize(des, ent)
      @des = des
      @ent = ent
    end

    attr_reader :des, :ent

    def to_s
      "Could not find #{des}: #{ent}"
    end
  end
end
