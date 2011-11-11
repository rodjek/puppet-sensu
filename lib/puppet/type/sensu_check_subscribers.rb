Puppet::Type.newtype(:sensu_check_subscribers) do
  @doc = ""

  ensurable do
    newvalue :present do
      provider.create
    end

    newvalue :absent do
      provider.destroy
    end

    defaultto :present
  end

  newparam :check do
    desc "The name of the Sensu check"

    isnamevar
  end

  newproperty :subscribers do
    desc "The list of subscriptions"
  end
end
