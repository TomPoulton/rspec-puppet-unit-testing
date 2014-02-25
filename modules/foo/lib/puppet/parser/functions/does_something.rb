module Puppet::Parser::Functions
  newfunction(:does_something, :type => :rvalue) do |args|

    things = args[0]

    fqdn = lookupvar('fqdn')
    hostname = function_get_hostname([fqdn])

    # Other really complex stuff happens here, honest!

    return things
  end
end
