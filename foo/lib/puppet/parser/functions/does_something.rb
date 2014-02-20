module Puppet::Parser::Functions
  newfunction(:does_something, :type => :rvalue) do |args|

    # Really complex stuff happens here, honest!

    return args[0]
  end
end
